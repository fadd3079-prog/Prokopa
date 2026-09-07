import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';

/// Service responsible for evaluating and awarding gamification achievements.
class GamificationService {
  final AppDatabase db;

  GamificationService(this.db);

  /// Evaluate habit-related achievements.
  Future<List<String>> evaluateHabitAchievements() async {
    final unlocked = <String>[];
    final activeHabits = await db.habitDao.getActiveHabits();

    // "Habit Builder": Create 5 different habits
    if (activeHabits.length >= 5) {
      if (await db.achievementDao.unlockByName('Habit Builder')) {
        unlocked.add('Habit Builder');
      }
    }

    // Check completion-based achievements
    int maxStreak = 0;
    bool hasAnyCompletion = false;

    for (final habit in activeHabits) {
      final currentStreak = await db.habitDao.getCurrentStreak(habit.id);
      final longestStreak = await db.habitDao.getLongestStreak(habit.id);
      final best = currentStreak > longestStreak ? currentStreak : longestStreak;
      if (best > maxStreak) maxStreak = best;

      final logs = await db.habitDao.getLogsForHabit(habit.id);
      if (logs.any((l) => l.completed)) {
        hasAnyCompletion = true;
      }
    }

    // "First Step": Complete your first habit
    if (hasAnyCompletion) {
      if (await db.achievementDao.unlockByName('First Step')) {
        unlocked.add('First Step');
      }
    }

    // "Week Warrior": Reach a 7-day streak
    if (maxStreak >= 7) {
      if (await db.achievementDao.unlockByName('Week Warrior')) {
        unlocked.add('Week Warrior');
      }
    }

    // "Streak Master": Reach a 30-day streak
    if (maxStreak >= 30) {
      if (await db.achievementDao.unlockByName('Streak Master')) {
        unlocked.add('Streak Master');
      }
    }

    // "Centurion": Reach a 100-day streak
    if (maxStreak >= 100) {
      if (await db.achievementDao.unlockByName('Centurion')) {
        unlocked.add('Centurion');
      }
    }

    return unlocked;
  }

  /// Evaluate journal-related achievements.
  Future<List<String>> evaluateJournalAchievements() async {
    final unlocked = <String>[];
    final count = await db.journalDao.getJournalCount();

    // "Journal Keeper": Write 10 journal entries
    if (count >= 10) {
      if (await db.achievementDao.unlockByName('Journal Keeper')) {
        unlocked.add('Journal Keeper');
      }
    }

    // "Mood Explorer": Log your mood for 14 days (entries)
    if (count >= 14) {
      if (await db.achievementDao.unlockByName('Mood Explorer')) {
        unlocked.add('Mood Explorer');
      }
    }

    // "Prolific Writer": Write 50 journal entries
    if (count >= 50) {
      if (await db.achievementDao.unlockByName('Prolific Writer')) {
        unlocked.add('Prolific Writer');
      }
    }

    return unlocked;
  }

  /// Evaluate sleep-related achievements.
  Future<List<String>> evaluateSleepAchievements() async {
    final unlocked = <String>[];
    final records = await db.sleepDao.getAllRecords();

    // "Sleep Tracker": Log sleep for 7 days
    if (records.length >= 7) {
      if (await db.achievementDao.unlockByName('Sleep Tracker')) {
        unlocked.add('Sleep Tracker');
      }
    }

    // "Sleep Master": Maintain 7+ hours sleep for 30 logs
    final sevenHourSleeps = records.where((r) => r.duration >= 7.0).length;
    if (sevenHourSleeps >= 30) {
      if (await db.achievementDao.unlockByName('Sleep Master')) {
        unlocked.add('Sleep Master');
      }
    }

    return unlocked;
  }
}

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  final db = ref.watch(databaseProvider);
  return GamificationService(db);
});
