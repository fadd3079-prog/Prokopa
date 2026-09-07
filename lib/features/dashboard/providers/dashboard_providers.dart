import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/database/app_database.dart';

class DashboardStats {
  final int totalHabits;
  final int completedToday;
  final int currentBestStreak;
  final int totalXp;

  const DashboardStats({
    required this.totalHabits,
    required this.completedToday,
    required this.currentBestStreak,
    required this.totalXp,
  });
}

final todayHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.habitDao.watchActiveHabits();
});

final todayCompletionsProvider = StreamProvider<List<HabitLog>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.habitDao.watchTodayCompletions();
});

final dashboardSleepProvider = FutureProvider<SleepRecord?>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.sleepDao.getLatestRecord();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final db = ref.watch(databaseProvider);
  final habits = await db.habitDao.getActiveHabits();
  final completions = await db.habitDao.watchTodayCompletions().first;

  int bestStreak = 0;
  for (var h in habits) {
    int streak = await db.habitDao.getCurrentStreak(h.id);
    if (streak > bestStreak) bestStreak = streak;
  }

  final totalXp = await db.achievementDao.getTotalXp();

  return DashboardStats(
    totalHabits: habits.length,
    completedToday: completions.length,
    currentBestStreak: bestStreak,
    totalXp: totalXp,
  );
});
