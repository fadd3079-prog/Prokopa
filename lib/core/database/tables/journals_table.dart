import 'package:drift/drift.dart';

/// Journals table for storing daily journal entries.
class Journals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get content => text()();
  IntColumn get mood => integer().withDefault(const Constant(3))(); // 1-5
  IntColumn get energyLevel =>
      integer().withDefault(const Constant(3))(); // 1-5
  TextColumn get type =>
      text().withDefault(const Constant('evening'))(); // morning, evening
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

