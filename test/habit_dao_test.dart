import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('HabitDao Tests', () {
    test('create, read, update, archive, and delete habit', () async {
      // Create habit
      final id = await db.habitDao.createHabit(
        HabitsCompanion.insert(
          title: 'Read Book',
          description: const Value('Read 20 pages'),
          category: const Value('learning'),
          frequency: const Value('Daily'),
          color: const Value(0xFF2196F3),
          icon: const Value('book'),
        ),
      );
      expect(id, isPositive);

      // Read habit
      final habit = await db.habitDao.getHabit(id);
      expect(habit.title, 'Read Book');
      expect(habit.status, 'active');

      // Update habit
      final updated = await db.habitDao.updateHabit(
        id,
        const HabitsCompanion(title: Value('Read 30 pages')),
      );
      expect(updated, isTrue);

      final updatedHabit = await db.habitDao.getHabit(id);
      expect(updatedHabit.title, 'Read 30 pages');

      // Archive habit
      await db.habitDao.archiveHabit(id);
      final activeAfterArchive = await db.habitDao.getActiveHabits();
      expect(activeAfterArchive.any((h) => h.id == id), isFalse);

      // Delete habit
      await db.habitDao.deleteHabit(id);
      final allHabits = await (db.select(db.habits)).get();
      expect(allHabits.any((h) => h.id == id), isFalse);
    });

    test('toggleCompletion and isCompleted', () async {
      final id = await db.habitDao.createHabit(
        HabitsCompanion.insert(
          title: 'Morning Jog',
          category: const Value('fitness'),
        ),
      );

      final today = DateTime.now();

      // Initially not completed
      expect(await db.habitDao.isCompleted(id, today), isFalse);

      // Toggle to true
      await db.habitDao.toggleCompletion(id, today);
      expect(await db.habitDao.isCompleted(id, today), isTrue);

      // Toggle back to false
      await db.habitDao.toggleCompletion(id, today);
      expect(await db.habitDao.isCompleted(id, today), isFalse);
    });

    test('streak calculations: current and longest', () async {
      final id = await db.habitDao.createHabit(
        HabitsCompanion.insert(
          title: 'Drink Water',
          category: const Value('health'),
        ),
      );

      final now = DateTime.now();

      // Log completions for today, yesterday, and 2 days ago (3-day streak)
      await db.habitDao.toggleCompletion(id, now);
      await db.habitDao.toggleCompletion(id, now.subtract(const Duration(days: 1)));
      await db.habitDao.toggleCompletion(id, now.subtract(const Duration(days: 2)));

      final currentStreak = await db.habitDao.getCurrentStreak(id);
      expect(currentStreak, 3);

      final longestStreak = await db.habitDao.getLongestStreak(id);
      expect(longestStreak, 3);
    });

    test('completion rate over N days', () async {
      final id = await db.habitDao.createHabit(
        HabitsCompanion.insert(
          title: 'Meditate',
          category: const Value('mindfulness'),
        ),
      );

      final now = DateTime.now();
      await db.habitDao.toggleCompletion(id, now);
      await db.habitDao.toggleCompletion(id, now.subtract(const Duration(days: 1)));

      final rate = await db.habitDao.getCompletionRate(id, 10);
      expect(rate, closeTo(0.2, 0.05));
    });
  });
}
