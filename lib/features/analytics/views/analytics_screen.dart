import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/analytics/providers/analytics_providers.dart';
import 'package:habitflow/features/analytics/widgets/completion_chart.dart';
import 'package:habitflow/features/analytics/widgets/mood_chart.dart';
import 'package:habitflow/features/analytics/widgets/sleep_analytics_card.dart';
import 'package:habitflow/features/analytics/widgets/insight_card.dart';
import 'package:habitflow/shared/widgets/section_header.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Daily Overview'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ref.watch(dailyOverviewStatsProvider).when(
                  data: (stats) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOverviewStat('Score', '${stats.score}', context),
                      _buildOverviewStat('Completion', stats.completionRate, context),
                      _buildOverviewStat('Best Streak', '${stats.bestStreak}', context),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOverviewStat('Score', '0', context),
                      _buildOverviewStat('Completion', '0%', context),
                      _buildOverviewStat('Best Streak', '0', context),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const SectionHeader(title: 'Habit Performance'),
            SizedBox(
              height: 120,
              child: ref.watch(habitAnalyticsProvider).when(
                data: (habits) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return Card(
                        margin: const EdgeInsets.only(right: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: habit.completionRate30d,
                                    color: habit.color,
                                    backgroundColor: habit.color.withValues(alpha: 0.2),
                                  ),
                                  Text(
                                    '${(habit.completionRate30d * 100).toInt()}%',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Streak: ${habit.currentStreak}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Weekly Trends'),
            ref.watch(weeklyCompletionProvider).when(
              data: (data) => CompletionChart(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Sleep Analytics'),
            ref.watch(sleepAnalyticsProvider).when(
              data: (sleep) => SleepAnalyticsCard(
                avgDuration: sleep.avgDuration,
                avgQuality: sleep.avgQuality,
                consistencyPercentage: sleep.consistency,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Mood Trend'),
            ref.watch(moodTrendProvider).when(
              data: (data) => MoodChart(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Personal Insights'),
            ref.watch(personalInsightProvider).when(
              data: (insights) => Column(
                children: insights.map((insight) => InsightCard(text: insight)).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
