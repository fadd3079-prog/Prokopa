import 'package:drift/drift.dart';
import 'habits_table.dart';

/// Habit logs table for tracking daily habit completions.
class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}
