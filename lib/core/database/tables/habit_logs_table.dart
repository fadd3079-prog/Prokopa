import 'package:drift/drift.dart';

/// Habit logs table for tracking daily habit completions.
class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(
        // ignore: undefined_identifier
        Habits,
        // ignore: undefined_identifier
        #id,
      )();
  DateTimeColumn get date => dateTime()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

