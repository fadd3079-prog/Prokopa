import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/features/analytics/widgets/mood_chart.dart';

class HabitAnalytics {
  final String title;
  final double completionRate30d;
  final int currentStreak;
  final Color color;

  HabitAnalytics({
    required this.title,
    required this.completionRate30d,
    required this.currentStreak,
    required this.color,
  });
}

class SleepAnalytics {
  final String avgDuration;
  final double avgQuality;
  final double consistency;

  SleepAnalytics({
    required this.avgDuration,
    required this.avgQuality,
    required this.consistency,
  });
}

final habitAnalyticsProvider = FutureProvider<List<HabitAnalytics>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  return [
    HabitAnalytics(
      title: 'Read Book',
      completionRate30d: 0.8,
      currentStreak: 5,
      color: Colors.blue,
    ),
    HabitAnalytics(
      title: 'Exercise',
      completionRate30d: 0.6,
      currentStreak: 2,
      color: Colors.red,
    ),
  ];
  final habits = await db.habitDao.getActiveHabits();
  if (habits.isEmpty) {
    return [
      HabitAnalytics(
        title: 'Read Book',
        completionRate30d: 0.8,
        currentStreak: 5,
        color: Colors.blue,
      ),
      HabitAnalytics(
        title: 'Exercise',
        completionRate30d: 0.6,
        currentStreak: 2,
        color: Colors.red,
      ),
    ];
  }
  final result = <HabitAnalytics>[];
  for (final habit in habits) {
    final streak = await db.habitDao.getCurrentStreak(habit.id);
    final rate = await db.habitDao.getCompletionRate(habit.id, 30);
    result.add(
      HabitAnalytics(
        title: habit.title,
        completionRate30d: rate,
        currentStreak: streak,
        color: Color(habit.color),
      ),
    );
  }
  return result;
});

final weeklyCompletionProvider = FutureProvider<Map<DateTime, int>>((
  ref,
) async {
  final now = DateTime.now();
  return {
    now.subtract(const Duration(days: 6)): 2,
    now.subtract(const Duration(days: 5)): 3,
    now.subtract(const Duration(days: 4)): 1,
    now.subtract(const Duration(days: 3)): 4,
    now.subtract(const Duration(days: 2)): 2,
    now.subtract(const Duration(days: 1)): 5,
    now: 3,
  };
});

final monthlyCompletionProvider = FutureProvider<Map<DateTime, int>>((
  ref,
) async {
  final map = <DateTime, int>{};
  final now = DateTime.now();
  for (int i = 0; i < 30; i++) {
    map[now.subtract(Duration(days: i))] = i % 5;
  }
  return map;
});

final sleepAnalyticsProvider = FutureProvider<SleepAnalytics>((ref) async {
  return SleepAnalytics(
    avgDuration: '7h 30m',
    avgQuality: 4.2,
    consistency: 0.85,
  );
});

final moodTrendProvider = FutureProvider<List<MoodTrend>>((ref) async {
  final now = DateTime.now();
  return List.generate(
    30,
    (i) => MoodTrend(
      date: now.subtract(Duration(days: 29 - i)),
      moodScore: (i % 5) + 1,
    ),
  );
});

final personalInsightProvider = FutureProvider<List<String>>((ref) async {
  return [
    'You tend to have a better mood on days when you sleep more than 7 hours.',
    'Your exercise habit has a great streak going! Keep it up!',
    'Reading before bed seems to improve your sleep quality.',
  ];
});
