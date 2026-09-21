import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/habits/dashboard_snapshot.dart';
import 'package:prokopa/src/habits/habit.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.snapshot,
    required this.onRefresh,
    this.profileName,
  });

  final DashboardSnapshot snapshot;
  final Future<void> Function() onRefresh;
  final String? profileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        ProkopaSpacing.xl,
                        ProkopaSpacing.xxl,
                        ProkopaSpacing.xl,
                        ProkopaSpacing.xxxl,
                      ),
                      child: _DashboardOverview(
                        snapshot: snapshot,
                        profileName: profileName,
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  ProkopaSpacing.xl,
                  0,
                  ProkopaSpacing.xl,
                  ProkopaSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Semantics(
                        header: true,
                        child: Text(
                          'Streak kebiasaan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (snapshot.habitProgress.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyStreaks(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    ProkopaSpacing.xl,
                    0,
                    ProkopaSpacing.xl,
                    ProkopaSpacing.huge,
                  ),
                  sliver: SliverList.separated(
                    itemCount: snapshot.habitProgress.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: ProkopaSpacing.md),
                    itemBuilder: (context, index) =>
                        _StreakRow(progress: snapshot.habitProgress[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview({required this.snapshot, this.profileName});

  final DashboardSnapshot snapshot;
  final String? profileName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profileName?.trim();
    final best = _bestProgress(snapshot.habitProgress);
    final totalRepetitions = snapshot.habitProgress.fold<int>(
      0,
      (sum, progress) => sum + progress.repetitions,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            name == null || name.isEmpty ? 'Dashboard' : 'Halo, $name',
            style: theme.textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: ProkopaSpacing.xs),
        Text(
          _formatDate(DateTime.now()),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: ProkopaSpacing.xxl),
        _CompletionCard(snapshot: snapshot),
        const SizedBox(height: ProkopaSpacing.lg),
        _BestStreakCard(progress: best),
        const SizedBox(height: ProkopaSpacing.lg),
        _OverviewCard(
          activeHabitCount: snapshot.habitProgress.length,
          totalRepetitions: totalRepetitions,
        ),
      ],
    );
  }

  HabitProgress? _bestProgress(List<HabitProgress> progressItems) {
    HabitProgress? best;
    for (final progress in progressItems) {
      if (best == null || progress.longestStreak > best.longestStreak) {
        best = progress;
      }
    }
    return best;
  }

  String _formatDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
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
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = snapshot.scheduledToday == 0
        ? 0.0
        : snapshot.completedToday / snapshot.scheduledToday;
    final percent = (progress * 100).round();
    final usesLargeText = MediaQuery.textScalerOf(context).scale(16) > 24;
    final detail = snapshot.scheduledToday == 0
        ? 'Belum ada habit terjadwal hari ini.'
        : '${snapshot.completedToday} dari ${snapshot.scheduledToday} selesai hari ini';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ProkopaSpacing.xxl),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Penyelesaian hari ini',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: ProkopaSpacing.xxl),
            Semantics(
              label: 'Penyelesaian habit hari ini, $percent persen',
              child: ExcludeSemantics(
                child: SizedBox.square(
                  dimension: usesLargeText ? 220 : 164,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 12,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        color: ProkopaPalette.success,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percent%',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontSize: 38,
                              ),
                            ),
                            Text(
                              'SELESAI',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: ProkopaSpacing.xxl),
            Text(
              detail,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BestStreakCard extends StatelessWidget {
  const _BestStreakCard({required this.progress});

  final HabitProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = progress;
    final unit = current?.isWeeklyTarget == true ? 'minggu' : 'hari';
    return Card(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetricIcon(
              icon: Icons.local_fire_department_outlined,
              color: ProkopaPalette.momentum,
              semanticLabel: 'Streak terbaik',
            ),
            const SizedBox(width: ProkopaSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STREAK TERBAIK',
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: ProkopaSpacing.sm),
                  Text(
                    current == null
                        ? 'Belum ada streak'
                        : '${current.longestStreak} $unit',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: ProkopaPalette.momentum,
                    ),
                  ),
                  if (current != null) ...[
                    const SizedBox(height: ProkopaSpacing.xs),
                    Text(
                      current.habit.draft.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.activeHabitCount,
    required this.totalRepetitions,
  });

  final int activeHabitCount;
  final int totalRepetitions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MetricIcon(
                  icon: Icons.trending_up,
                  color: theme.colorScheme.primary,
                  semanticLabel: 'Ringkasan',
                ),
                const SizedBox(width: ProkopaSpacing.md),
                Expanded(
                  child: Text('Ringkasan', style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: ProkopaSpacing.xxl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MetricValue(
                    value: '$activeHabitCount',
                    label: 'Habit aktif',
                  ),
                ),
                const SizedBox(width: ProkopaSpacing.xl),
                Expanded(
                  child: _MetricValue(
                    value: '$totalRepetitions',
                    label: 'Total penyelesaian',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({
    required this.icon,
    required this.color,
    required this.semanticLabel,
  });

  final IconData icon;
  final Color color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: ProkopaRadius.mdBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.all(ProkopaSpacing.md),
          child: ExcludeSemantics(child: Icon(icon, color: color)),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.headlineSmall),
        const SizedBox(height: ProkopaSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.progress});

  final HabitProgress progress;

  @override
  Widget build(BuildContext context) {
    final unit = progress.isWeeklyTarget ? 'minggu' : 'hari';
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Semantics(
          container: true,
          label:
              '${progress.habit.draft.title}, streak ${progress.currentStreak} $unit, rekor terpanjang ${progress.longestStreak} $unit',
          child: ExcludeSemantics(
            child: Card(
              child: Padding(
                padding: ProkopaSpacing.cardPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            progress.habit.draft.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: ProkopaSpacing.xs),
                          Text(
                            'Rekor ${progress.longestStreak} $unit',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: ProkopaSpacing.lg),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_outlined,
                          color: ProkopaPalette.momentum,
                          size: 20,
                        ),
                        const SizedBox(width: ProkopaSpacing.xs),
                        Text(
                          '${progress.currentStreak} $unit',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: ProkopaPalette.momentum,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStreaks extends StatelessWidget {
  const _EmptyStreaks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: ProkopaSpacing.cardPadding,
          child: Text(
            'Belum ada streak. Tambahkan atau aktifkan kebiasaan dari tab Habits.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
