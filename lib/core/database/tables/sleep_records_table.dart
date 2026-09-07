import 'package:drift/drift.dart';

/// Sleep records table for tracking sleep patterns.
class SleepRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get sleepStart => dateTime()();
  DateTimeColumn get sleepEnd => dateTime()();
  RealColumn get duration => real()(); // hours
  IntColumn get quality => integer().withDefault(const Constant(3))(); // 1-5
}

