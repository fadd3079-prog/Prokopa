import 'package:drift/drift.dart';

/// Habits table for storing habit definitions.
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  TextColumn get frequency =>
      text().withDefault(const Constant('daily'))(); // daily, weekly
  IntColumn get target => integer().withDefault(const Constant(1))();
  TextColumn get reminderTime => text().nullable()();
  TextColumn get icon =>
      text().withDefault(const Constant('check_circle'))();
  IntColumn get color =>
      integer().withDefault(const Constant(0xFF6366F1))(); // indigo
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // active, archived
}

