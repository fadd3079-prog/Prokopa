import 'package:flutter/material.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    super.key,
    required this.store,
    required this.wellbeingStore,
  });

  final ProgressStore store;
  final WellbeingStore wellbeingStore;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressSnapshot? _week;
  ProgressSnapshot? _month;
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
    ]);
    if (mounted) {
      setState(() {
        _week = results[0];
        _month = results[1];
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
      await showModalBottomSheet<void>(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type == 'weekly' ? 'Tinjauan minggu ini' : 'Tinjauan bulan ini',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                '${record.data['completed']} selesai dari ${record.data['planned']} terjadwal.',
              ),
              Text('${record.data['moodCount']} catatan suasana.'),
              Text('${record.data['sleepCount']} catatan tidur.'),
              const SizedBox(height: 12),
              const Text(
                'Apa yang membantu, sulit, atau ingin kamu sesuaikan?',
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _addSleep() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SleepForm(store: widget.wellbeingStore),
    );
    if (changed == true) {
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
            Text('Kalender', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _CalendarLegend(),
            const SizedBox(height: 8),
            _Calendar(snapshot: _month!),
            const SizedBox(height: 20),
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
  const _SleepForm({required this.store});

  final WellbeingStore store;

  @override
  State<_SleepForm> createState() => _SleepFormState();
}

class _SleepFormState extends State<_SleepForm> {
  late TimeOfDay _start;
  late TimeOfDay _end;
  var _quality = SleepQuality.good;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _end = now;
    _start = TimeOfDay(hour: (now.hour + 16) % 24, minute: now.minute);
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

  Future<void> _save() async {
    final now = DateTime.now();
    var start = DateTime(
      now.year,
      now.month,
      now.day,
      _start.hour,
      _start.minute,
    );
    final end = DateTime(now.year, now.month, now.day, _end.hour, _end.minute);
    if (!start.isBefore(end)) {
      start = start.subtract(const Duration(days: 1));
    }
    try {
      await widget.store.saveSleep(start: start, end: end, quality: _quality);
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
            Text('Catat tidur', style: Theme.of(context).textTheme.titleLarge),
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
