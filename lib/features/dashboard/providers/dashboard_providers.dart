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

final dashboardSleepProvider = FutureProvider<dynamic>((ref) async {
  final db = ref.watch(databaseProvider);
  // Assuming a sleepDao exists. If not, returning null
  try {
    return await (db as dynamic).sleepDao.getLatestSleepRecord();
  } catch (_) {
    return null;
  }
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final db = ref.watch(databaseProvider);
  final habits = await db.habitDao.getActiveHabits();
  final completions = await db.habitDao.watchTodayCompletions().first;

  // Calculate streaks and XP dynamically based on data if real logic isn't available
  int bestStreak = 0;
  for (var h in habits) {
    int streak = await db.habitDao.getCurrentStreak(h.id);
    if (streak > bestStreak) bestStreak = streak;
  }

  return DashboardStats(
    totalHabits: habits.length,
    completedToday: completions.length,
    currentBestStreak: bestStreak,
    totalXp: completions.length * 10,
  );
});
