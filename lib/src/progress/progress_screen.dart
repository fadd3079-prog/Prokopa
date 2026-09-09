import 'package:flutter/material.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

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
  ProgressSnapshot? _week;
  ProgressSnapshot? _month;
  List<SleepRecord> _sleep = const [];
  List<HabitProgress> _habits = const [];
  double? _averageSleepMinutes;
  double? _averageSleepQuality;
  double? _sleepConsistency;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
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
        _week = results[0] as ProgressSnapshot;
        _month = results[1] as ProgressSnapshot;
        _sleep = results[2] as List<SleepRecord>;
        _averageSleepMinutes = results[3] as double?;
        _averageSleepQuality = results[4] as double?;
        _sleepConsistency = results[5] as double?;
        _habits = widget.habitStore == null
            ? const []
            : results[6] as List<HabitProgress>;
        _loading = false;
      });
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

  Future<void> _addSleep([SleepRecord? record]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _SleepForm(store: widget.wellbeingStore, record: record),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _deleteSleep(SleepRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus catatan tidur?'),
        content: const Text('Catatan ini akan dihapus dari perangkat ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.wellbeingStore.deleteSleep(record.id);
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Progress', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            _SummarySection(title: 'Minggu ini', snapshot: _week!),
            const SizedBox(height: 20),
            _SummarySection(title: 'Bulan ini', snapshot: _month!),
            const SizedBox(height: 20),
            Text('Kebiasaan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_habits.isEmpty)
              const Text('Belum ada kebiasaan yang dapat ditinjau.')
            else
              for (final progress in _habits)
                _HabitProgressRow(progress: progress),
            const SizedBox(height: 20),
            Text('Kalender', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _CalendarLegend(),
            const SizedBox(height: 8),
            _Calendar(snapshot: _month!),
            const SizedBox(height: 20),
            Text('Tidur', style: Theme.of(context).textTheme.titleMedium),
            if (_averageSleepMinutes != null &&
                _averageSleepQuality != null &&
                _sleepConsistency != null)
              Text(
                'Rata-rata ${_duration(_averageSleepMinutes!)} · kualitas ${_averageSleepQuality!.toStringAsFixed(1)}/4 · konsistensi ${(_sleepConsistency! * 100).round()}%',
              )
            else
              const Text('Belum ada catatan tidur.'),
            if (_sleep.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final record in _sleep.take(7))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${localDateKey(record.end)} · ${_duration(record.durationMinutes.toDouble())}',
                  ),
                  subtitle: Text(_quality(record.quality)),
                  onTap: () => _addSleep(record),
                  trailing: IconButton(
                    tooltip: 'Hapus catatan tidur',
                    onPressed: () => _deleteSleep(record),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addSleep,
              icon: const Icon(Icons.bedtime_outlined),
              label: const Text('Catat tidur'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _review('weekly'),
              child: const Text('Tinjauan minggu ini'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _review('monthly'),
              child: const Text('Tinjauan bulan ini'),
            ),
          ],
        ),
      ),
    );
  }

  String _duration(double minutes) {
    final rounded = minutes.round();
    return '${rounded ~/ 60}j ${rounded % 60}m';
  }

  String _quality(SleepQuality value) => switch (value) {
    SleepQuality.poor => 'Kurang',
    SleepQuality.fair => 'Cukup',
    SleepQuality.good => 'Baik',
    SleepQuality.excellent => 'Sangat baik',
  };
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
      contentPadding: EdgeInsets.zero,
      title: Text(progress.habit.draft.title),
      subtitle: Text(
        progress.recoveryCount == 0
            ? detail
            : '$detail · ${progress.recoveryCount} kali kembali',
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
    final averageMood = data['averageMood'] as num?;
    final averageSleepMinutes = data['averageSleepMinutes'] as num?;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.record.type == 'weekly'
                  ? 'Tinjauan minggu ini'
                  : 'Tinjauan bulan ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '${data['completed']} selesai dari ${data['planned']} terjadwal.',
            ),
            if (data['mostConsistentHabit'] != null)
              Text('Paling konsisten: ${data['mostConsistentHabit']}.')
            else
              const Text('Belum ada kebiasaan terjadwal untuk dibandingkan.'),
            if (data['hardestHabit'] != null)
              Text('Paling menantang: ${data['hardestHabit']}.')
            else
              const SizedBox.shrink(),
            Text('${data['journalCount']} catatan jurnal tersimpan.'),
            Text(
              averageMood == null
                  ? '${data['moodCount']} catatan suasana.'
                  : '${data['moodCount']} catatan suasana, rata-rata ${averageMood.toStringAsFixed(1)}/5.',
            ),
            Text(
              averageSleepMinutes == null
                  ? '${data['sleepCount']} catatan tidur.'
                  : '${data['sleepCount']} catatan tidur, rata-rata ${_duration(averageSleepMinutes)}.',
            ),
            Text('${data['recoveryCount']} kali kembali setelah jeda.'),
            const SizedBox(height: 20),
            TextField(
              controller: _reflection,
              enabled: !_saving,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText:
                    'Apa yang membantu, sulit, atau ingin kamu sesuaikan?',
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Menyimpan' : 'Simpan tinjauan'),
            ),
          ],
        ),
      ),
    );
  }

  String _duration(num minutes) {
    final rounded = minutes.round();
    return '${rounded ~/ 60}j ${rounded % 60}m';
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.title, required this.snapshot});

  final String title;
  final ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final rate = snapshot.completionRate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          '${snapshot.completed} selesai dari ${snapshot.planned} terjadwal',
        ),
        if (rate != null) ...[
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: rate,
            semanticsLabel: 'Tingkat penyelesaian',
          ),
          const SizedBox(height: 4),
          Text('${(rate * 100).round()}% penyelesaian'),
        ] else
          const Text('Belum ada pelaksanaan yang tercatat.'),
        Text('${snapshot.repetitions} repetisi'),
      ],
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Text('Selesai'),
        Text('Sebagian'),
        Text('Dilewati'),
        Text('Terlewat'),
        Text('Tanpa rencana'),
      ],
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.snapshot});

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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final day in days)
          Semantics(
            label:
                '${localDateKey(day)} ${_label(snapshot.calendar[localDateKey(day)])}',
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                color: _color(context, snapshot.calendar[localDateKey(day)]),
              ),
              child: Text('${day.day}'),
            ),
          ),
      ],
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
    'completed' => Theme.of(context).colorScheme.primaryContainer,
    'partial' => Theme.of(context).colorScheme.secondaryContainer,
    'skipped' => Theme.of(context).colorScheme.surfaceContainerHighest,
    'missed' => Theme.of(context).colorScheme.errorContainer,
    _ => Theme.of(context).colorScheme.surface,
  };
}

class _SleepForm extends StatefulWidget {
  const _SleepForm({required this.store, this.record});

  final WellbeingStore store;
  final SleepRecord? record;

  @override
  State<_SleepForm> createState() => _SleepFormState();
}

class _SleepFormState extends State<_SleepForm> {
  late TimeOfDay _start;
  late TimeOfDay _end;
  late DateTime _wakeDate;
  var _quality = SleepQuality.good;
  final _note = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    if (record != null) {
      _wakeDate = DateTime(record.end.year, record.end.month, record.end.day);
      _start = TimeOfDay.fromDateTime(record.start);
      _end = TimeOfDay.fromDateTime(record.end);
      _quality = record.quality;
      _note.text = record.note ?? '';
    } else {
      final now = TimeOfDay.now();
      _wakeDate = DateTime.now();
      _end = now;
      _start = TimeOfDay(hour: (now.hour + 16) % 24, minute: now.minute);
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (selected != null) {
      setState(() {
        if (start) {
          _start = selected;
        } else {
          _end = selected;
        }
      });
    }
  }

  Future<void> _pickWakeDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _wakeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => _wakeDate = selected);
    }
  }

  Future<void> _save() async {
    final wakeDate = _wakeDate;
    var start = DateTime(
      wakeDate.year,
      wakeDate.month,
      wakeDate.day,
      _start.hour,
      _start.minute,
    );
    final end = DateTime(
      wakeDate.year,
      wakeDate.month,
      wakeDate.day,
      _end.hour,
      _end.minute,
    );
    if (!start.isBefore(end)) {
      start = start.subtract(const Duration(days: 1));
    }
    try {
      await widget.store.saveSleep(
        id: widget.record?.id,
        start: start,
        end: end,
        quality: _quality,
        note: _note.text,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ArgumentError catch (error) {
      setState(() => _error = error.message?.toString());
    } catch (_) {
      setState(() => _error = 'Tidur belum tersimpan. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.record == null ? 'Catat tidur' : 'Ubah catatan tidur',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListTile(
              title: const Text('Tanggal bangun'),
              trailing: Text(localDateKey(_wakeDate)),
              onTap: _pickWakeDate,
            ),
            ListTile(
              title: const Text('Mulai tidur'),
              trailing: Text(_start.format(context)),
              onTap: () => _pick(true),
            ),
            ListTile(
              title: const Text('Bangun'),
              trailing: Text(_end.format(context)),
              onTap: () => _pick(false),
            ),
            DropdownButtonFormField<SleepQuality>(
              initialValue: _quality,
              decoration: const InputDecoration(labelText: 'Kualitas'),
              items: SleepQuality.values
                  .map(
                    (quality) => DropdownMenuItem(
                      value: quality,
                      child: Text(_qualityLabel(quality)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _quality = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Catatan opsional'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Simpan tidur'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _qualityLabel(SleepQuality quality) => switch (quality) {
    SleepQuality.poor => 'Kurang',
    SleepQuality.fair => 'Cukup',
    SleepQuality.good => 'Baik',
    SleepQuality.excellent => 'Sangat baik',
  };
}
