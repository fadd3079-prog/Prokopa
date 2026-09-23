import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_components.dart';
import 'package:prokopa/src/app/app_date_controller.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/mood_record.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    super.key,
    required this.store,
    required this.wellbeingStore,
    this.habitStore,
    this.dateController,
    this.onSettings,
    this.refreshVersion = 0,
  });

  final ProgressStore store;
  final WellbeingStore wellbeingStore;
  final HabitStore? habitStore;
  final AppDateController? dateController;
  final VoidCallback? onSettings;
  final int refreshVersion;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final AppDateController _dateController;
  late final bool _ownsDateController;
  ProgressSnapshot? _month;
  List<HabitProgress> _habits = const [];
  List<SleepRecord> _sleep = const [];
  List<MoodRecord> _moods = const [];
  var _loading = true;
  var _loadVersion = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ownsDateController = widget.dateController == null;
    _dateController = widget.dateController ?? AppDateController();
    _dateController.addListener(_reload);
    _reload();
  }

  @override
  void didUpdateWidget(covariant ProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _reload();
    }
  }

  @override
  void dispose() {
    _dateController.removeListener(_reload);
    if (_ownsDateController) {
      _dateController.dispose();
    }
    super.dispose();
  }

  Future<void> _reload() async {
    final version = ++_loadVersion;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final start = _dateController.displayedMonth;
      final end = DateTime(start.year, start.month + 1, 0);
      final results = await Future.wait<Object>([
        widget.store.snapshot(start, end),
        widget.wellbeingStore.listSleep(from: start, to: end),
        widget.wellbeingStore.listMood(from: start, to: end),
        if (widget.habitStore != null) widget.habitStore!.progress(now: end),
      ]);
      if (!mounted || version != _loadVersion) {
        return;
      }
      setState(() {
        _month = results[0] as ProgressSnapshot;
        _sleep = results[1] as List<SleepRecord>;
        _moods = results[2] as List<MoodRecord>;
        _habits = widget.habitStore == null
            ? const []
            : (results[3] as List<HabitProgress>)
                  .where((item) => item.habit.state == HabitState.active)
                  .toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted && version == _loadVersion) {
        setState(() {
          _loading = false;
          _error = 'Stats belum dapat dimuat. Coba lagi.';
        });
      }
    }
  }

  Future<void> _review() async {
    final start = _dateController.displayedMonth;
    final now = DateTime.now();
    final monthEnd = DateTime(start.year, start.month + 1, 0);
    final end = monthEnd.isAfter(now) ? now : monthEnd;
    try {
      final record = await widget.store.saveReview(
        type: 'monthly',
        start: start,
        end: end,
      );
      if (!mounted) {
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _MonthlyReviewSummary(record: record),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tinjauan belum dapat dibuka.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 48),
            children: [
              AppPageHeader(
                title: 'Stats',
                subtitle:
                    'Ringkasan kebiasaan untuk ${formatMonth(_dateController.displayedMonth)}',
                onSettings: widget.onSettings ?? () {},
              ),
              const SizedBox(height: 24),
              MonthNavigator(controller: _dateController, onChanged: _reload),
              const SizedBox(height: 24),
              if (_loading)
                const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Memuat statistik',
                    ),
                  ),
                )
              else if (_error case final error?)
                _StatsError(message: error, onRetry: _reload)
              else ...[
                _SummaryGrid(snapshot: _month!, habits: _habits, sleep: _sleep),
                const SizedBox(height: 16),
                _DailyCompletionChart(snapshot: _month!),
                const SizedBox(height: 16),
                _SleepChart(records: _sleep),
                const SizedBox(height: 16),
                _MoodCompletionChart(snapshot: _month!, records: _moods),
                const SizedBox(height: 16),
                _StatsHeatmap(snapshot: _month!),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _review,
                  child: const Text('Tinjauan bulan ini'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.snapshot,
    required this.habits,
    required this.sleep,
  });

  final ProgressSnapshot snapshot;
  final List<HabitProgress> habits;
  final List<SleepRecord> sleep;

  @override
  Widget build(BuildContext context) {
    final completion = ((snapshot.completionRate ?? 0) * 100).round();
    final best = snapshot.dailyPlanned.entries.fold<(String, double)?>(null, (
      current,
      entry,
    ) {
      final rate = (snapshot.dailyCompleted[entry.key] ?? 0) / entry.value;
      return current == null || rate > current.$2 ? (entry.key, rate) : current;
    });
    final activeDays = snapshot.dailyCompleted.values
        .where((count) => count > 0)
        .length;
    final averageSleep = sleep.isEmpty
        ? null
        : sleep.fold<int>(0, (sum, item) => sum + item.durationMinutes) /
              sleep.length /
              60;
    final items = [
      ('$completion%', 'Rata-rata selesai', AppColors.indigo600),
      (
        best == null ? '–' : '${DateTime.parse(best.$1).day}',
        best == null
            ? 'Hari terbaik'
            : 'Hari terbaik (${(best.$2 * 100).round()}%)',
        AppColors.emerald700,
      ),
      ('$activeDays', 'Hari aktif', AppColors.amber700),
      (
        averageSleep == null ? '–' : '${averageSleep.toStringAsFixed(1)}j',
        'Rata-rata tidur',
        AppColors.violet600,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 30, color: item.$3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DailyCompletionChart extends StatelessWidget {
  const _DailyCompletionChart({required this.snapshot});

  final ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final days = snapshot.end.day;
    final values = List<double>.generate(days, (index) {
      final key = localDateKey(
        DateTime(snapshot.start.year, snapshot.start.month, index + 1),
      );
      final planned = snapshot.dailyPlanned[key] ?? 0;
      return planned == 0 ? 0 : (snapshot.dailyCompleted[key] ?? 0) / planned;
    });
    return _ChartCard(
      title: 'Tingkat Penyelesaian Harian',
      empty: snapshot.dailyPlanned.isEmpty,
      emptyText: 'Belum ada aktivitas untuk digambar pada bulan ini.',
      semanticsLabel: 'Grafik tingkat penyelesaian harian',
      painter: _LineChartPainter(
        values: values,
        lineColor: AppColors.indigo500,
        fillColor: AppColors.indigo100,
      ),
    );
  }
}

class _SleepChart extends StatelessWidget {
  const _SleepChart({required this.records});

  final List<SleepRecord> records;

  @override
  Widget build(BuildContext context) {
    final ordered = [...records]..sort((a, b) => a.end.compareTo(b.end));
    final values = ordered.map((item) => item.durationMinutes / 60).toList();
    return _ChartCard(
      title: 'Durasi Tidur',
      empty: values.isEmpty,
      emptyText: 'Belum ada catatan tidur pada bulan ini.',
      semanticsLabel: 'Grafik durasi tidur dalam jam',
      painter: _LineChartPainter(
        values: values,
        lineColor: AppColors.purple500,
        fillColor: AppColors.purple200,
      ),
    );
  }
}

class _MoodCompletionChart extends StatelessWidget {
  const _MoodCompletionChart({required this.snapshot, required this.records});

  final ProgressSnapshot snapshot;
  final List<MoodRecord> records;

  @override
  Widget build(BuildContext context) {
    final values = <double>[];
    for (final valence in MoodValence.values) {
      final dates = records
          .where((item) => item.valence == valence)
          .map((item) => localDateKey(item.recordedAt))
          .toSet();
      final rates = dates.map((date) {
        final planned = snapshot.dailyPlanned[date] ?? 0;
        return planned == 0
            ? 0.0
            : (snapshot.dailyCompleted[date] ?? 0) / planned;
      }).toList();
      values.add(
        rates.isEmpty ? 0 : rates.reduce((a, b) => a + b) / rates.length,
      );
    }
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood dan Penyelesaian',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Rata-rata penyelesaian berdasarkan mood yang dicatat.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          if (records.isEmpty)
            Text(
              'Belum ada mood yang tercatat pada bulan ini.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Semantics(
              label: 'Grafik batang mood dan tingkat penyelesaian',
              child: ExcludeSemantics(
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      values: values,
                      color: AppColors.emerald500,
                      gridColor: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sangat buruk'),
              Text('Netral'),
              Text('Sangat baik'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.empty,
    required this.emptyText,
    required this.semanticsLabel,
    required this.painter,
  });

  final String title;
  final bool empty;
  final String emptyText;
  final String semanticsLabel;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          if (empty)
            Text(emptyText, style: Theme.of(context).textTheme.bodySmall)
          else
            Semantics(
              label: semanticsLabel,
              child: ExcludeSemantics(
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CustomPaint(painter: painter),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var index = 0; index <= 4; index++) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (values.isEmpty) {
      return;
    }
    final maxValue = math.max(1.0, values.fold<double>(0, math.max));
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? 0.0
          : size.width * index / (values.length - 1);
      final y = size.height - size.height * values[index] / maxValue;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = fillColor.withValues(alpha: 0.45));
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.fillColor != fillColor;
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.color,
    required this.gridColor,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var index = 0; index <= 4; index++) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final slot = size.width / values.length;
    final width = math.min(36.0, slot * 0.55);
    for (var index = 0; index < values.length; index++) {
      final height = size.height * values[index].clamp(0, 1);
      final left = slot * index + (slot - width) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, size.height - height, width, height),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rect, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _StatsHeatmap extends StatelessWidget {
  const _StatsHeatmap({required this.snapshot});

  final ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final start = DateTime(snapshot.start.year, snapshot.start.month);
    final end = DateTime(start.year, start.month + 1, 0);
    final leading = start.weekday - 1;
    final total = leading + end.day;
    final trailing = (7 - total % 7) % 7;
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heatmap Aktivitas · ${formatMonth(start)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 6.0;
              final size = (constraints.maxWidth - gap * 6) / 7;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var index = 0; index < total + trailing; index++)
                    if (index < leading || index >= leading + end.day)
                      SizedBox.square(dimension: size)
                    else
                      _StatsHeatmapCell(
                        date: DateTime(
                          start.year,
                          start.month,
                          index - leading + 1,
                        ),
                        count:
                            snapshot.dailyCompleted[localDateKey(
                              DateTime(
                                start.year,
                                start.month,
                                index - leading + 1,
                              ),
                            )] ??
                            0,
                        max: math.max(
                          1,
                          snapshot.dailyCompleted.values.fold<int>(0, math.max),
                        ),
                        size: size,
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsHeatmapCell extends StatelessWidget {
  const _StatsHeatmapCell({
    required this.date,
    required this.count,
    required this.max,
    required this.size,
  });

  final DateTime date;
  final int count;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ratio = count / max;
    final color = count == 0
        ? Theme.of(context).colorScheme.surfaceContainer
        : ratio <= 0.25
        ? AppColors.emerald200
        : ratio <= 0.5
        ? AppColors.emerald300
        : ratio <= 0.75
        ? AppColors.emerald400
        : AppColors.emerald500;
    return Semantics(
      label: '${date.day} ${fullMonths[date.month - 1]}, $count selesai',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.smBorder,
          ),
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: Text(
                '${date.day}',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontSize: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyReviewSummary extends StatelessWidget {
  const _MonthlyReviewSummary({required this.record});

  final ReviewRecord record;

  @override
  Widget build(BuildContext context) {
    final data = record.data;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tinjauan Bulanan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              '${data['completed']} selesai dari ${data['planned']} aktivitas terjadwal.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${data['journalCount']} catatan jurnal · ${data['sleepCount']} catatan tidur',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
