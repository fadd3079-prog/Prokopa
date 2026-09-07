import 'package:drift/drift.dart';

/// Achievements table for gamification system.
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get icon => text().withDefault(const Constant('🏆'))();
  IntColumn get xpReward => integer().withDefault(const Constant(100))();
  DateTimeColumn get unlockDate => dateTime().nullable()();
  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();
}

