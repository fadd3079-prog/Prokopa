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
                child: _DashboardHeader(
                  snapshot: snapshot,
                  profileName: profileName,
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.snapshot, this.profileName});

  final DashboardSnapshot snapshot;
  final String? profileName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = snapshot.scheduledToday == 0
        ? 0.0
        : snapshot.completedToday / snapshot.scheduledToday;
    final name = profileName?.trim();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            ProkopaSpacing.xl,
            ProkopaSpacing.xxl,
            ProkopaSpacing.xl,
            ProkopaSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text('Dashboard', style: theme.textTheme.headlineLarge),
              ),
              const SizedBox(height: ProkopaSpacing.xs),
              Text(
                name == null || name.isEmpty
                    ? 'Ringkasan kebiasaanmu hari ini.'
                    : 'Ringkasan kebiasaan $name hari ini.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: ProkopaSpacing.xxl),
              _CompletionCard(snapshot: snapshot, progress: progress),
              const SizedBox(height: ProkopaSpacing.xxxl),
              Semantics(
                header: true,
                child: Text(
                  'Streak kebiasaan',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: ProkopaSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.snapshot, required this.progress});

  final DashboardSnapshot snapshot;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = snapshot.scheduledToday == 0
        ? 'Belum ada habit terjadwal hari ini.'
        : '${snapshot.completedToday} dari ${snapshot.scheduledToday} selesai hari ini';
    return Card(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penyelesaian hari ini', style: theme.textTheme.titleMedium),
            const SizedBox(height: ProkopaSpacing.lg),
            Text(label, style: theme.textTheme.headlineSmall),
            const SizedBox(height: ProkopaSpacing.lg),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: ProkopaRadius.smBorder,
              semanticsLabel: 'Penyelesaian habit hari ini',
            ),
          ],
        ),
      ),
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
                            'Rekor terpanjang ${progress.longestStreak} $unit',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: ProkopaSpacing.lg),
                    Text(
                      '${progress.currentStreak} $unit',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.end,
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
