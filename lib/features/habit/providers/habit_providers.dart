import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';

final activeHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.habitDao.watchActiveHabits();
});

final habitDetailProvider = FutureProvider.family<Habit, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.habitDao.getHabit(id);
});

class HabitStreak {
  final int current;
  final int longest;
  HabitStreak(this.current, this.longest);
}

final habitStreakProvider = FutureProvider.family<HabitStreak, int>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  final current = await db.habitDao.getCurrentStreak(id);
  final longest = await db.habitDao.getLongestStreak(id);
  return HabitStreak(current, longest);
});

final habitCompletionRateProvider = FutureProvider.family<double, int>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  // Assuming a method exists to calculate this, else mocking for now
  try {
    return await db.habitDao.getCompletionRate(id, 30);
  } catch (_) {
    return 0.0;
  }
});
