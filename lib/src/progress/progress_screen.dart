import 'package:flutter/material.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';
import 'package:prokopa/src/app/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    super.key,
    required this.store,
    required this.wellbeingStore,
    this.habitStore,
  });

  final ProgressStore store;
  final WellbeingStore wellbeingStore;
  final HabitStore? habitStore;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressSnapshot? _month;
  List<HabitProgress> _habits = const [];
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(
        Duration(days: now.weekday - DateTime.monday),
      );
      final monthStart = DateTime(now.year, now.month);
      final results = await Future.wait([
        widget.store.snapshot(weekStart, now),
        widget.store.snapshot(monthStart, now),
        widget.wellbeingStore.listSleep(),
        widget.wellbeingStore.averageSleepDuration(),
        widget.wellbeingStore.averageSleepQuality(),
        widget.wellbeingStore.sleepConsistency(),
        if (widget.habitStore != null) widget.habitStore!.progress(),
      ]);
      if (mounted) {
        setState(() {
          _month = results[1] as ProgressSnapshot;
          _habits = widget.habitStore == null
              ? const []
              : results[6] as List<HabitProgress>;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Statistik belum dapat dimuat. Coba lagi.';
        });
      }
    }
  }

  Future<void> _review(String type) async {
    final now = DateTime.now();
    final start = type == 'weekly'
        ? now.subtract(Duration(days: now.weekday - DateTime.monday))
        : DateTime(now.year, now.month);
    final record = await widget.store.saveReview(
      type: type,
      start: start,
      end: now,
    );
    if (mounted) {
      final changed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            _ReviewEditor(store: widget.store, record: record),
      );
      if (changed == true) {
        await _reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    if (_error case final error?) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: ProkopaSpacing.cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: ProkopaSpacing.lg),
                FilledButton(
                  onPressed: () {
                    setState(() => _loading = true);
                    _reload();
                  },
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: ProkopaSpacing.xxl),
          children: [
            Padding(
              padding: ProkopaSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Statistik',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: ProkopaSpacing.xs),
                  Text(
                    'Ringkasan kebiasaan untuk ${_monthLabel(DateTime.now())}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ProkopaSpacing.xxl),
            Padding(
              padding: ProkopaSpacing.screenPadding,
              child: _SummaryCard(
                snapshot: _month!,
                activeHabitCount: _habits.length,
              ),
            ),
            const SizedBox(height: ProkopaSpacing.xxxl),
            Padding(
              padding: ProkopaSpacing.screenPadding,
              child: Text(
                'Aktivitas bulan ini',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: ProkopaSpacing.lg),
            _CalendarFullWidth(snapshot: _month!),
            const SizedBox(height: ProkopaSpacing.xxxl),
            Padding(
              padding: ProkopaSpacing.screenPadding,
              child: Text(
                'Konsistensi Kebiasaan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: ProkopaSpacing.sm),
            if (_habits.isEmpty)
              const Padding(
                padding: ProkopaSpacing.screenPadding,
                child: Text('Belum ada kebiasaan yang dapat ditinjau.'),
              )
            else
              for (final progress in _habits)
                _HabitProgressRow(progress: progress),
            const SizedBox(height: ProkopaSpacing.xxxl),
            Padding(
              padding: ProkopaSpacing.screenPadding,
              child: OutlinedButton(
                onPressed: () => _review('monthly'),
                child: const Text('Tinjauan bulan ini'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.snapshot, required this.activeHabitCount});

  final ProgressSnapshot snapshot;
  final int activeHabitCount;

  @override
  Widget build(BuildContext context) {
    final completion = ((snapshot.completionRate ?? 0) * 100).round();
    final activeDays = snapshot.calendar.values.where((state) {
      return state == 'completed' || state == 'partial';
    }).length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaledBody = MediaQuery.textScalerOf(context).scale(14);
        final useTwoColumns = constraints.maxWidth >= 340 && scaledBody <= 21;
        final itemWidth = useTwoColumns
            ? (constraints.maxWidth - ProkopaSpacing.md) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: ProkopaSpacing.md,
          runSpacing: ProkopaSpacing.md,
          children: [
            SizedBox(
              width: itemWidth,
              child: _MetricCard(
                value: '$completion%',
                label: 'Rata-rata selesai',
                icon: Icons.donut_large,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricCard(
                value: '$activeDays',
                label: 'Hari aktif',
                icon: Icons.calendar_today_outlined,
                color: ProkopaPalette.success,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricCard(
                value: '${snapshot.repetitions}',
                label: 'Penyelesaian',
                icon: Icons.check_circle_outline,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricCard(
                value: '$activeHabitCount',
                label: 'Habit aktif',
                icon: Icons.track_changes_outlined,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: label,
              image: true,
              child: ExcludeSemantics(child: Icon(icon, color: accent)),
            ),
            const SizedBox(height: ProkopaSpacing.lg),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(color: accent),
            ),
            const SizedBox(height: ProkopaSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarFullWidth extends StatelessWidget {
  const _CalendarFullWidth({required this.snapshot});

  final ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    var day = DateTime(
      snapshot.start.year,
      snapshot.start.month,
      snapshot.start.day,
    );
    while (!day.isAfter(snapshot.end)) {
      days.add(day);
      day = day.add(const Duration(days: 1));
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = screenWidth - 40;
    final cellSize = (availableWidth - (6 * 8)) / 7;

    return Padding(
      padding: ProkopaSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _WeekdayLabel('Sen'),
              _WeekdayLabel('Sel'),
              _WeekdayLabel('Rab'),
              _WeekdayLabel('Kam'),
              _WeekdayLabel('Jum'),
              _WeekdayLabel('Sab'),
              _WeekdayLabel('Min'),
            ],
          ),
          const SizedBox(height: ProkopaSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < (snapshot.start.weekday - 1); i++)
                SizedBox(width: cellSize, height: cellSize),
              for (final day in days)
                Semantics(
                  label:
                      '${localDateKey(day)} ${_label(snapshot.calendar[localDateKey(day)])}',
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: ProkopaRadius.mdBorder,
                      border: Border.all(
                        color: _borderColor(
                          context,
                          snapshot.calendar[localDateKey(day)],
                        ),
                        width: 1.5,
                      ),
                      color: _color(
                        context,
                        snapshot.calendar[localDateKey(day)],
                      ),
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _textColor(
                          context,
                          snapshot.calendar[localDateKey(day)],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(String? state) => switch (state) {
    'completed' => 'Selesai',
    'partial' => 'Sebagian',
    'skipped' => 'Dilewati',
    'missed' => 'Terlewat',
    _ => 'Tanpa rencana',
  };

  Color _color(BuildContext context, String? state) => switch (state) {
    'completed' => ProkopaPalette.success,
    'partial' => ProkopaPalette.momentum,
    'skipped' => Theme.of(context).colorScheme.surfaceContainerHighest,
    'missed' => Colors.transparent,
    _ => Theme.of(context).colorScheme.surface,
  };

  Color _borderColor(BuildContext context, String? state) => switch (state) {
    'completed' => ProkopaPalette.success,
    'partial' => ProkopaPalette.momentum,
    'skipped' => Theme.of(context).colorScheme.surfaceContainerHighest,
    'missed' => Theme.of(context).colorScheme.outlineVariant,
    _ => Theme.of(context).colorScheme.surfaceContainerHighest,
  };

  Color _textColor(BuildContext context, String? state) => switch (state) {
    'completed' => Colors.white,
    'partial' => ProkopaPalette.textPrimary,
    'skipped' => Theme.of(context).colorScheme.onSurfaceVariant,
    'missed' => Theme.of(context).colorScheme.onSurfaceVariant,
    _ => Theme.of(context).colorScheme.onSurface,
  };
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = screenWidth - 40;
    final cellSize = (availableWidth - (6 * 8)) / 7;

    return SizedBox(
      width: cellSize,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _HabitProgressRow extends StatelessWidget {
  const _HabitProgressRow({required this.progress});

  final HabitProgress progress;

  @override
  Widget build(BuildContext context) {
    final detail = progress.isWeeklyTarget
        ? '${progress.weekCompleted}/${progress.weekTarget} minggu ini · ${progress.repetitions} repetisi · ${progress.currentStreak} minggu beruntun'
        : '${progress.repetitions} repetisi · streak ${progress.currentStreak} · terpanjang ${progress.longestStreak}';
    return ListTile(
      contentPadding: ProkopaSpacing.screenPadding,
      title: Text(
        progress.habit.draft.title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        progress.recoveryCount == 0
            ? detail
            : '$detail · ${progress.recoveryCount} kali kembali',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _ReviewEditor extends StatefulWidget {
  const _ReviewEditor({required this.store, required this.record});

  final ProgressStore store;
  final ReviewRecord record;

  @override
  State<_ReviewEditor> createState() => _ReviewEditorState();
}

class _ReviewEditorState extends State<_ReviewEditor> {
  late final TextEditingController _reflection;
  String? _adjustment;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reflection = TextEditingController(text: widget.record.reflection ?? '');
    _adjustment = widget.record.data['adjustment'] as String?;
  }

  @override
  void dispose() {
    _reflection.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.store.saveReview(
        type: widget.record.type,
        start: widget.record.start,
        end: widget.record.end,
        reflection: _reflection.text,
        adjustment: _adjustment,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Tinjauan belum tersimpan. Coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.record.data;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          32,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.record.type == 'weekly'
                  ? 'Tinjauan minggu ini'
                  : 'Tinjauan bulan ini',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: ProkopaSpacing.xl),
            Text(
              '${data['completed']} selesai dari ${data['planned']} terjadwal.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: ProkopaSpacing.md),
            TextField(
              controller: _reflection,
              enabled: !_saving,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Apa yang membantu, sulit, atau ingin kamu sesuaikan?',
                filled: true,
              ),
            ),
            const SizedBox(height: ProkopaSpacing.lg),
            DropdownButtonFormField<String?>(
              initialValue: _adjustment,
              decoration: const InputDecoration(
                labelText: 'Langkah berikutnya',
              ),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Belum dipilih'),
                ),
                DropdownMenuItem(
                  value: 'keep',
                  child: Text('Pertahankan yang membantu'),
                ),
                DropdownMenuItem(
                  value: 'change_schedule',
                  child: Text('Ubah jadwal kebiasaan'),
                ),
                DropdownMenuItem(
                  value: 'reduce_target',
                  child: Text('Kurangi target kebiasaan'),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _adjustment = value),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: ProkopaSpacing.xxxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: ProkopaSpacing.sm),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Menyimpan' : 'Simpan tinjauan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
