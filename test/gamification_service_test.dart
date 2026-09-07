import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/services/gamification_service.dart';

void main() {
  late AppDatabase db;
  late GamificationService gamificationService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Manually trigger migration to seed default achievements
    await db.customStatement('SELECT 1');
    // Ensure default achievements are seeded
    final achievements = await db.achievementDao.getAllAchievements();
    if (achievements.isEmpty) {
      await db.into(db.achievements).insert(
            AchievementsCompanion.insert(
              name: 'First Step',
              description: const Value('Complete your first habit'),
              xpReward: const Value(50),
            ),
          );
      await db.into(db.achievements).insert(
            AchievementsCompanion.insert(
              name: 'Week Warrior',
              description: const Value('Complete all habits for 7 days straight'),
              xpReward: const Value(200),
            ),
          );
      await db.into(db.achievements).insert(
            AchievementsCompanion.insert(
              name: 'Habit Builder',
              description: const Value('Create 5 different habits'),
              xpReward: const Value(100),
            ),
          );
    }
    gamificationService = GamificationService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('GamificationService Tests', () {
    test('unlocks First Step upon first completion', () async {
      final habitId = await db.habitDao.createHabit(
        HabitsCompanion.insert(
          title: 'Morning Yoga',
          category: const Value('fitness'),
        ),
      );

      // Initially First Step is locked
      expect(await db.achievementDao.isUnlocked('First Step'), isFalse);

      // Complete habit
      await db.habitDao.toggleCompletion(habitId, DateTime.now());

      // Evaluate achievements
      final unlocked = await gamificationService.evaluateHabitAchievements();
      expect(unlocked, contains('First Step'));
      expect(await db.achievementDao.isUnlocked('First Step'), isTrue);

      final totalXp = await db.achievementDao.getTotalXp();
      expect(totalXp, greaterThanOrEqualTo(50));
    });

    test('unlocks Habit Builder when 5 habits are created', () async {
      for (int i = 0; i < 5; i++) {
        await db.habitDao.createHabit(
          HabitsCompanion.insert(
            title: 'Habit $i',
            category: const Value('general'),
          ),
        );
      }

      final unlocked = await gamificationService.evaluateHabitAchievements();
      expect(unlocked, contains('Habit Builder'));
      expect(await db.achievementDao.isUnlocked('Habit Builder'), isTrue);
    });
  });
}
