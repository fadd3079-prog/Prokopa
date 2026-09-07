import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habits_table.dart';
import '../tables/habit_logs_table.dart';

part 'habit_dao.g.dart';

/// Data access object for habit CRUD and completion tracking.
@DriftAccessor(tables: [Habits, HabitLogs])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  // ── Habit CRUD ──

  /// Get all active habits.
  Future<List<Habit>> getActiveHabits() {
    return (select(habits)..where((t) => t.status.equals('active'))).get();
  }

  /// Watch all active habits reactively.
  Stream<List<Habit>> watchActiveHabits() {
    return (select(habits)..where((t) => t.status.equals('active'))).watch();
  }

  /// Get a single habit by ID.
  Future<Habit> getHabit(int id) {
    return (select(habits)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Create a new habit and return its ID.
  Future<int> createHabit(HabitsCompanion habit) {
    return into(habits).insert(habit);
  }

  /// Update an existing habit.
  Future<bool> updateHabit(int id, HabitsCompanion companion) {
    return (update(habits)..where((t) => t.id.equals(id))).write(companion).then((rows) => rows > 0);
  }

  /// Delete a habit and its logs.
  Future<void> deleteHabit(int id) async {
    await (delete(habitLogs)..where((t) => t.habitId.equals(id))).go();
    await (delete(habits)..where((t) => t.id.equals(id))).go();
  }

  /// Archive a habit.
  Future<void> archiveHabit(int id) {
    return (update(habits)..where((t) => t.id.equals(id)))
        .write(const HabitsCompanion(status: Value('archived')));
  }

  // ── Completion Tracking ──

  /// Toggle habit completion for a given date.
  Future<void> toggleCompletion(int habitId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final existing = await _getLog(habitId, normalizedDate);

    if (existing != null) {
      await (update(habitLogs)..where((t) => t.id.equals(existing.id)))
          .write(HabitLogsCompanion(completed: Value(!existing.completed)));
    } else {
      await into(habitLogs).insert(HabitLogsCompanion.insert(
        habitId: habitId,
        date: normalizedDate,
        completed: const Value(true),
      ));
    }
  }

  /// Check if a habit is completed for a given date.
  Future<bool> isCompleted(int habitId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final log = await _getLog(habitId, normalizedDate);
    return log?.completed ?? false;
  }

  /// Get all completion logs for a habit.
  Future<List<HabitLog>> getLogsForHabit(int habitId) {
    return (select(habitLogs)
          ..where((t) => t.habitId.equals(habitId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Watch today's completions for all habits.
  Stream<List<HabitLog>> watchTodayCompletions() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    return (select(habitLogs)
          ..where(
              (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end))
          ..where((t) => t.completed.equals(true)))
        .watch();
  }

  /// Get completions for a date range.
  Future<List<HabitLog>> getCompletionsInRange(
      int habitId, DateTime start, DateTime end) {
    return (select(habitLogs)
          ..where((t) =>
              t.habitId.equals(habitId) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end) &
              t.completed.equals(true)))
        .get();
  }

  // ── Streak Calculation ──

  /// Calculate the current streak for a habit.
  Future<int> getCurrentStreak(int habitId) async {
    final logs = await (select(habitLogs)
          ..where((t) => t.habitId.equals(habitId) & t.completed.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();

    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (final log in logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (logDate == checkDate || logDate == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = logDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate the longest streak for a habit.
  Future<int> getLongestStreak(int habitId) async {
    final logs = await (select(habitLogs)
          ..where((t) => t.habitId.equals(habitId) & t.completed.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();

    if (logs.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < logs.length; i++) {
      final prev = DateTime(logs[i - 1].date.year, logs[i - 1].date.month, logs[i - 1].date.day);
      final curr = DateTime(logs[i].date.year, logs[i].date.month, logs[i].date.day);
      final diff = curr.difference(prev).inDays;

      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }

    return longest;
  }

  /// Get completion rate for the last N days.
  Future<double> getCompletionRate(int habitId, int days) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days));
    final logs = await getCompletionsInRange(habitId, start, DateTime.now());
    return logs.isEmpty ? 0.0 : logs.length / days;
  }

  // ── Private Helpers ──

  Future<HabitLog?> _getLog(int habitId, DateTime date) async {
    final end = date.add(const Duration(days: 1));
    final results = await (select(habitLogs)
          ..where((t) =>
              t.habitId.equals(habitId) &
              t.date.isBiggerOrEqualValue(date) &
              t.date.isSmallerThanValue(end)))
        .get();
    return results.isEmpty ? null : results.first;
  }
}

