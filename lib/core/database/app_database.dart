import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/users_table.dart';
import 'tables/habits_table.dart';
import 'tables/habit_logs_table.dart';
import 'tables/journals_table.dart';
import 'tables/sleep_records_table.dart';
import 'tables/achievements_table.dart';
import 'daos/user_dao.dart';
import 'daos/habit_dao.dart';
import 'daos/journal_dao.dart';
import 'daos/sleep_dao.dart';
import 'daos/achievement_dao.dart';

part 'app_database.g.dart';

/// Main Drift database for HabitFlow.
///
/// Contains all tables and DAOs for the application.
@DriftDatabase(
  tables: [Users, Habits, HabitLogs, Journals, SleepRecords, Achievements],
  daos: [UserDao, HabitDao, JournalDao, SleepDao, AchievementDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing with an in-memory database.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed default achievements
        await _seedAchievements();
        // Create default user profile
        await _seedDefaultUser();
      },
    );
  }

  Future<void> _seedDefaultUser() async {
    await into(users).insert(
      UsersCompanion.insert(),
    );
  }

  Future<void> _seedAchievements() async {
    final defaultAchievements = [
      AchievementsCompanion.insert(
        name: 'First Step',
        description: const Value('Complete your first habit'),
        icon: const Value('🏆'),
        xpReward: const Value(50),
      ),
      AchievementsCompanion.insert(
        name: 'Week Warrior',
        description: const Value('Complete all habits for 7 days straight'),
        icon: const Value('⚡'),
        xpReward: const Value(200),
      ),
      AchievementsCompanion.insert(
        name: 'Streak Master',
        description: const Value('Achieve a 30-day streak on any habit'),
        icon: const Value('🔥'),
        xpReward: const Value(500),
      ),
      AchievementsCompanion.insert(
        name: 'Journal Keeper',
        description: const Value('Write 10 journal entries'),
        icon: const Value('📖'),
        xpReward: const Value(150),
      ),
      AchievementsCompanion.insert(
        name: 'Prolific Writer',
        description: const Value('Write 50 journal entries'),
        icon: const Value('✍️'),
        xpReward: const Value(400),
      ),
      AchievementsCompanion.insert(
        name: 'Sleep Tracker',
        description: const Value('Log sleep for 7 consecutive days'),
        icon: const Value('🌙'),
        xpReward: const Value(150),
      ),
      AchievementsCompanion.insert(
        name: 'Sleep Master',
        description: const Value('Maintain 7+ hours sleep for 30 days'),
        icon: const Value('😴'),
        xpReward: const Value(500),
      ),
      AchievementsCompanion.insert(
        name: 'Habit Builder',
        description: const Value('Create 5 different habits'),
        icon: const Value('🧱'),
        xpReward: const Value(100),
      ),
      AchievementsCompanion.insert(
        name: 'Centurion',
        description: const Value('Reach a 100-day streak'),
        icon: const Value('💯'),
        xpReward: const Value(1000),
      ),
      AchievementsCompanion.insert(
        name: 'Mood Explorer',
        description: const Value('Log your mood for 14 days'),
        icon: const Value('🎭'),
        xpReward: const Value(200),
      ),
    ];

    for (final achievement in defaultAchievements) {
      await into(achievements).insert(achievement);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'habitflow.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

