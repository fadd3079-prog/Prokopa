import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:prokopa/src/app/app_components.dart';
import 'package:prokopa/src/app/app_date_controller.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/habits/dashboard_snapshot.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/progress/progress_store.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.snapshot,
    required this.dateController,
    required this.onRefresh,
    required this.onSettings,
    required this.onToggleHabit,
    required this.onManageHabit,
    required this.onManageHabits,
    required this.onOpenSleep,
    required this.onOpenJournal,
    this.profileName,
  });

  final DashboardSnapshot snapshot;
  final AppDateController dateController;
  final Future<void> Function() onRefresh;
  final VoidCallback onSettings;
  final ValueChanged<TodayHabit> onToggleHabit;
  final ValueChanged<Habit> onManageHabit;
  final VoidCallback onManageHabits;
  final VoidCallback onOpenSleep;
  final VoidCallback onOpenJournal;
  final String? profileName;

  @override
  Widget build(BuildContext context) {
    final name = profileName?.trim();
    final title = name == null || name.isEmpty ? 'Dashboard' : 'Halo, $name';
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 48),
            children: [
              AppPageHeader(
                title: title,
                subtitle: formatFullDate(DateTime.now()),
                onSettings: onSettings,
              ),
              const SizedBox(height: 24),
              MonthNavigator(controller: dateController, onChanged: onRefresh),
              const SizedBox(height: 12),
              HistoricalMonthBanner(controller: dateController),
              if (!dateController.isCurrentMonth)
                const SizedBox(height: 24)
              else
                const SizedBox(height: 12),
              _ProgressCard(snapshot: snapshot),
              const SizedBox(height: 16),
              _BestStreakCard(items: snapshot.habitProgress),
              const SizedBox(height: 16),
              _OverviewCard(snapshot: snapshot),
              const SizedBox(height: 16),
              _HeatmapCard(snapshot: snapshot.month),
              const SizedBox(height: 16),
              _TodayHabitsCard(
                habits: snapshot.todayHabits,
                onToggle: onToggleHabit,
                onManage: onManageHabit,
                onManageAll: onManageHabits,
              ),
              const SizedBox(height: 16),
              _SleepCard(snapshot: snapshot, onTap: onOpenSleep),
              const SizedBox(height: 16),
              _JournalCard(snapshot: snapshot, onTap: onOpenJournal),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final progress = snapshot.scheduledToday == 0
        ? 0.0
        : snapshot.completedToday / snapshot.scheduledToday;
    final percent = (progress * 100).round();
    return BentoCard(
      child: Column(
        children: [
          _ProgressRing(progress: progress, percent: percent),
          const SizedBox(height: 16),
          Text(
            '${snapshot.completedToday} dari ${snapshot.scheduledToday} kebiasaan',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            snapshot.scheduledToday == 0
                ? 'Tidak ada kebiasaan terjadwal hari ini'
                : 'selesai hari ini',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.percent});

  final double progress;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Progress hari ini, $percent persen selesai',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: 140,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: reduceMotion ? Duration.zero : AppMotion.ring,
            curve: AppMotion.curve,
            builder: (context, value, _) => Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  color: value >= 1
                      ? AppColors.emerald500
                      : AppColors.indigo500,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(value * 100).round()}%',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 30),
                      ),
                      Text(
                        'SELESAI',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(letterSpacing: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BestStreakCard extends StatelessWidget {
  const _BestStreakCard({required this.items});

  final List<HabitProgress> items;

  @override
  Widget build(BuildContext context) {
    final best = items.fold<HabitProgress?>(null, (current, item) {
      return current == null || item.longestStreak > current.longestStreak
          ? item
          : current;
    });
    final value = best?.longestStreak ?? 0;
    final unit = best?.isWeeklyTarget == true ? 'minggu' : 'hari';
    return BentoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MetricIcon(
            icon: Icons.local_fire_department_outlined,
            color: AppColors.amber700,
            background: AppColors.amber50,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STREAK TERBAIK',
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(letterSpacing: 1, color: AppColors.amber700),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$value',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 30, color: AppColors.amber700),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.amber700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  best == null
                      ? 'Belum ada streak yang tercatat'
                      : best.habit.draft.title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _MetricIcon(
                icon: Icons.trending_up,
                color: AppColors.indigo600,
                background: AppColors.indigo50,
              ),
              const SizedBox(width: 12),
              Text(
                'OVERVIEW',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetricValue(
                  value: '${snapshot.habitProgress.length}',
                  label: 'Kebiasaan aktif',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricValue(
                  value: '${snapshot.month?.completed ?? 0}',
                  label: 'Selesai bulan ini',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.mdBorder,
        ),
        child: SizedBox.square(
          dimension: 40,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge
              ?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.snapshot});

  final ProgressSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final current = snapshot;
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ExcludeSemantics(
                child: Icon(Icons.calendar_month_outlined, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  current == null ? 'Aktivitas' : formatMonth(current.start),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (current == null)
            Text(
              'Belum ada aktivitas pada periode ini.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            _Heatmap(snapshot: current),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.snapshot});

  final ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(snapshot.start.year, snapshot.start.month);
    final monthEnd = DateTime(snapshot.start.year, snapshot.start.month + 1, 0);
    final leading = monthStart.weekday - DateTime.monday;
    final used = leading + monthEnd.day;
    final trailing = (7 - used % 7) % 7;
    final totalCells = used + trailing;
    const labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final cell = (constraints.maxWidth - gap * 6) / 7;
        return Column(
          children: [
            Row(
              children: [
                for (var index = 0; index < labels.length; index++) ...[
                  SizedBox(
                    width: cell,
                    child: Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(fontSize: 10),
                    ),
                  ),
                  if (index != labels.length - 1) const SizedBox(width: gap),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var index = 0; index < totalCells; index++)
                  if (index < leading || index >= leading + monthEnd.day)
                    SizedBox.square(dimension: cell)
                  else
                    _HeatmapCell(
                      date: DateTime(
                        monthStart.year,
                        monthStart.month,
                        index - leading + 1,
                      ),
                      count:
                          snapshot.dailyCompleted[localDateKey(
                            DateTime(
                              monthStart.year,
                              monthStart.month,
                              index - leading + 1,
                            ),
                          )] ??
                          0,
                      max: math.max(
                        1,
                        snapshot.dailyCompleted.values.fold<int>(0, math.max),
                      ),
                      size: cell,
                      index: index,
                    ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Sedikit', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(width: 6),
                for (final color in const [
                  AppColors.neutral100,
                  AppColors.emerald200,
                  AppColors.emerald300,
                  AppColors.emerald400,
                  AppColors.emerald500,
                ]) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const SizedBox.square(dimension: 12),
                  ),
                  const SizedBox(width: 4),
                ],
                Text('Banyak', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.date,
    required this.count,
    required this.max,
    required this.size,
    required this.index,
  });

  final DateTime date;
  final int count;
  final int max;
  final double size;
  final int index;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final future = date.isAfter(today);
    final isToday = date == today;
    final ratio = count / max;
    final color = future
        ? Theme.of(context).colorScheme.surfaceContainerLow
        : count == 0
        ? Theme.of(context).colorScheme.surfaceContainer
        : ratio <= 0.25
        ? AppColors.emerald200
        : ratio <= 0.5
        ? AppColors.emerald300
        : ratio <= 0.75
        ? AppColors.emerald400
        : AppColors.emerald500;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Duration(milliseconds: 220 + index * 12);
    return Semantics(
      label: '${date.day} ${fullMonths[date.month - 1]}, $count selesai',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: duration,
        curve: Curves.easeOutBack,
        builder: (context, value, child) => Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.scale(scale: value, child: child),
        ),
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.smBorder,
              border: Border.all(
                color: isToday
                    ? AppColors.indigo500
                    : future
                    ? Theme.of(context).colorScheme.outlineVariant
                    : Colors.transparent,
                width: isToday ? 2 : 1,
              ),
            ),
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: count > 0 && ratio > 0.5
                        ? AppColors.neutral900
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayHabitsCard extends StatelessWidget {
  const _TodayHabitsCard({
    required this.habits,
    required this.onToggle,
    required this.onManage,
    required this.onManageAll,
  });

  final List<TodayHabit> habits;
  final ValueChanged<TodayHabit> onToggle;
  final ValueChanged<Habit> onManage;
  final VoidCallback onManageAll;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        children: [
          Row(
            children: [
              const ExcludeSemantics(
                child: Icon(Icons.checklist_rounded, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kebiasaan Hari Ini',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: onManageAll, child: const Text('Kelola')),
            ],
          ),
          const SizedBox(height: 8),
          if (habits.isEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Tidak ada kebiasaan terjadwal hari ini.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            for (var index = 0; index < habits.length; index++) ...[
              _DashboardHabitRow(
                today: habits[index],
                sortOrder: index.toDouble(),
                onTap: () => onToggle(habits[index]),
                onLongPress: () => onManage(habits[index].habit),
              ),
              if (index != habits.length - 1) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _DashboardHabitRow extends StatelessWidget {
  const _DashboardHabitRow({
    required this.today,
    required this.sortOrder,
    required this.onTap,
    required this.onLongPress,
  });

  final TodayHabit today;
  final double sortOrder;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final complete = today.isComplete;
    return Semantics(
      button: true,
      label: today.habit.draft.title,
      value: complete ? 'Selesai' : 'Belum selesai',
      hint: 'Ketuk untuk mengubah status. Tekan lama untuk mengelola.',
      sortKey: OrdinalSortKey(sortOrder),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppRadius.mdBorder,
        child: Ink(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: complete
                ? AppColors.emerald50
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: complete
                  ? AppColors.emerald100
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: ExcludeSemantics(
            child: Row(
              children: [
                Icon(
                  complete
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: complete
                      ? AppColors.emerald700
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    today.habit.draft.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      decoration: complete ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({required this.snapshot, required this.onTap});

  final DashboardSnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sleep = snapshot.sleep;
    final detail = sleep == null
        ? 'Ketuk untuk mencatat tidur'
        : '${sleep.durationMinutes ~/ 60}j ${sleep.durationMinutes % 60}m';
    return Semantics(
      button: true,
      label: 'Sleep Tracker, $detail',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? const [AppColors.indigo50, AppColors.purple50]
                  : const [Color(0xFF24214A), Color(0xFF34204F)],
            ),
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.purple200),
          ),
          child: ExcludeSemantics(
            child: Row(
              children: [
                const _MetricIcon(
                  icon: Icons.bedtime_outlined,
                  color: AppColors.violet600,
                  background: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Tracker',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.snapshot, required this.onTap});

  final DashboardSnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final journal = snapshot.journal;
    final preview = journal == null || journal.bodyPreview.trim().isEmpty
        ? 'Belum ada catatan untuk hari ini.'
        : journal.bodyPreview.trim();
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ExcludeSemantics(
                child: Icon(Icons.menu_book_outlined, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Journal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: onTap, child: const Text('Tulis')),
            ],
          ),
          const SizedBox(height: 8),
          Text(preview, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
