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

class DailyOverviewStats {
  final int score;
  final String completionRate;
  final int bestStreak;

  const DailyOverviewStats({
    required this.score,
    required this.completionRate,
    required this.bestStreak,
  });
}

final dailyOverviewStatsProvider = FutureProvider<DailyOverviewStats>((ref) async {
  final db = ref.watch(databaseProvider);
  final habits = await db.habitDao.getActiveHabits();
  final completions = await db.habitDao.watchTodayCompletions().first;

  int bestStreak = 0;
  for (final h in habits) {
    final streak = await db.habitDao.getCurrentStreak(h.id);
    if (streak > bestStreak) bestStreak = streak;
  }

  final rate = habits.isEmpty ? 0.0 : (completions.length / habits.length);
  final score = ((rate * 70) + (bestStreak > 0 ? 30 : 0)).round().clamp(0, 100);

  return DailyOverviewStats(
    score: score,
    completionRate: '${(rate * 100).toInt()}%',
    bestStreak: bestStreak,
  );
});

final habitAnalyticsProvider = FutureProvider<List<HabitAnalytics>>((ref) async {
  final db = ref.watch(databaseProvider);
  final habits = await db.habitDao.getActiveHabits();
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

final weeklyCompletionProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = today.subtract(const Duration(days: 6));
  final end = today.add(const Duration(days: 1));

  final logs = await db.habitDao.getAllCompletionsInRange(start, end);

  final map = <DateTime, int>{};
  for (int i = 0; i < 7; i++) {
    final day = start.add(Duration(days: i));
    final count = logs
        .where((l) =>
            l.date.year == day.year &&
            l.date.month == day.month &&
            l.date.day == day.day)
        .length;
    map[day] = count;
  }
  return map;
});

final monthlyCompletionProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = today.subtract(const Duration(days: 29));
  final end = today.add(const Duration(days: 1));

  final logs = await db.habitDao.getAllCompletionsInRange(start, end);

  final map = <DateTime, int>{};
  for (int i = 0; i < 30; i++) {
    final day = start.add(Duration(days: i));
    final count = logs
        .where((l) =>
            l.date.year == day.year &&
            l.date.month == day.month &&
            l.date.day == day.day)
        .length;
    map[day] = count;
  }
  return map;
});

final sleepAnalyticsProvider = FutureProvider<SleepAnalytics>((ref) async {
  final db = ref.watch(databaseProvider);
  final avgDuration = await db.sleepDao.getAverageDuration(30);
  final avgQuality = await db.sleepDao.getAverageQuality(30);
  final consistency = await db.sleepDao.getSleepConsistency(30);

  final hours = avgDuration.floor();
  final minutes = ((avgDuration - hours) * 60).round();
  final durationFormatted = avgDuration > 0
      ? (minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h')
      : '0h';

  return SleepAnalytics(
    avgDuration: durationFormatted,
    avgQuality: avgQuality > 0 ? avgQuality : 0.0,
    consistency: consistency * 100.0,
  );
});

final moodTrendProvider = FutureProvider<List<MoodTrend>>((ref) async {
  final db = ref.watch(databaseProvider);
  final journals = await db.journalDao.getRecentJournals(30);
  if (journals.isEmpty) {
    return [];
  }
  return journals
      .map((j) => MoodTrend(date: j.date, moodScore: j.mood))
      .toList();
});

final personalInsightProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(databaseProvider);
  final insights = <String>[];

  final habits = await db.habitDao.getActiveHabits();
  int maxStreak = 0;
  String topHabit = '';
  for (final habit in habits) {
    final streak = await db.habitDao.getCurrentStreak(habit.id);
    if (streak > maxStreak) {
      maxStreak = streak;
      topHabit = habit.title;
    }
  }

  if (maxStreak >= 3) {
    insights.add(
        'Awesome momentum! Your streak on "$topHabit" is currently $maxStreak days.');
  }

  final avgSleep = await db.sleepDao.getAverageDuration(14);
  final avgMood = await db.journalDao.getAverageMood(14);

  if (avgSleep >= 7.0) {
    insights.add(
        'Great rest! You have averaged ${avgSleep.toStringAsFixed(1)} hours of sleep over the past 2 weeks.');
  } else if (avgSleep > 0 && avgSleep < 6.5) {
    insights.add(
        'Tip: Sleeping closer to 7-8 hours may boost your daily focus and habit consistency.');
  }

  if (avgMood >= 4.0) {
    insights.add(
        'Your reflection mood has been notably positive recently! Keep up the good routines.');
  }

  if (insights.isEmpty) {
    insights.add(
        'Log your habits, journals, and sleep daily to unlock personalized lifestyle insights.');
  }

  return insights;
});
