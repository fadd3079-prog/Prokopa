import 'dart:convert';

import 'package:prokopa/src/core/date/local_date.dart';
import 'package:sqflite/sqflite.dart';

class AchievementState {
  const AchievementState({
    required this.key,
    required this.title,
    required this.description,
    required this.category,
    required this.requirement,
    required this.reward,
    required this.iconName,
    required this.progress,
    required this.target,
    this.earnedAt,
  });

  final String key;
  final String title;
  final String description;
  final String category;
  final String requirement;
  final String reward;
  final String iconName;
  final int progress;
  final int target;
  final DateTime? earnedAt;

  bool get isUnlocked => earnedAt != null;
}

class AchievementStore {
  AchievementStore(this._database);

  final Database _database;

  Future<List<AchievementState>> evaluate() async {
    final metrics = await _metrics();
    final existing = await _database.query('achievements');
    final unlocked = {
      for (final row in existing)
        row['key']! as String: DateTime.parse(row['earned_at']! as String),
    };
    final definitions = [
      (
        'first_habit',
        'Kebiasaan pertama',
        'Satu kebiasaan baru sudah tersimpan secara lokal.',
        'Habit',
        'Buat satu kebiasaan.',
        'Pengakuan',
        'habit',
        metrics.habits,
        1,
      ),
      (
        'habit_builder',
        'Pembangun kebiasaan',
        'Lima kebiasaan berbeda sudah pernah dibuat.',
        'Habit',
        'Buat lima kebiasaan berbeda.',
        'Pengakuan',
        'habit',
        metrics.habits,
        5,
      ),
      (
        'journal_days',
        'Hari menulis',
        'Catatan tersimpan pada hari-hari yang berbeda.',
        'Journal',
        'Tulis jurnal pada 14 hari berbeda.',
        'Pengakuan',
        'journal',
        metrics.journalDays,
        14,
      ),
      (
        'mood_days',
        'Penjelajah suasana',
        'Suasana dicatat pada hari-hari yang berbeda.',
        'Reflection',
        'Catat suasana pada 14 hari berbeda.',
        'Pengakuan',
        'mood',
        metrics.moodDays,
        14,
      ),
      (
        'sleep_week',
        'Catatan tidur',
        'Tidur dicatat pada tujuh hari berturut-turut.',
        'Sleep',
        'Catat tidur selama 7 hari berturut-turut.',
        'Pengakuan',
        'sleep',
        metrics.sleepStreak,
        7,
      ),
      (
        'return_after_pause',
        'Kembali',
        'Satu penyelesaian terjadi setelah jeda yang tercatat.',
        'Recovery',
        'Selesaikan satu kebiasaan setelah jeda.',
        'Pengakuan',
        'recovery',
        metrics.recoveries,
        1,
      ),
    ];
    final now = utcTimestamp(DateTime.now());
    for (final definition in definitions) {
      if (definition.$8 >= definition.$9 &&
          !unlocked.containsKey(definition.$1)) {
        await _database.insert('achievements', {
          'key': definition.$1,
          'earned_at': now,
          'metadata': jsonEncode({
            'progress': definition.$8,
            'target': definition.$9,
          }),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    final after = await _database.query('achievements');
    final earned = {
      for (final row in after)
        row['key']! as String: DateTime.parse(row['earned_at']! as String),
    };
    return definitions
        .map(
          (definition) => AchievementState(
            key: definition.$1,
            title: definition.$2,
            description: definition.$3,
            category: definition.$4,
            requirement: definition.$5,
            reward: definition.$6,
            iconName: definition.$7,
            progress: definition.$8,
            target: definition.$9,
            earnedAt: earned[definition.$1],
          ),
        )
        .toList();
  }

  Future<
    ({
      int habits,
      int journalDays,
      int moodDays,
      int sleepStreak,
      int recoveries,
    })
  >
  _metrics() async {
    final habits =
        Sqflite.firstIntValue(
          await _database.rawQuery('SELECT COUNT(*) FROM habits'),
        ) ??
        0;
    final journalDays =
        Sqflite.firstIntValue(
          await _database.rawQuery(
            "SELECT COUNT(DISTINCT entry_date) FROM journal_entries WHERE status = 'saved'",
          ),
        ) ??
        0;
    final moodDays =
        Sqflite.firstIntValue(
          await _database.rawQuery(
            'SELECT COUNT(DISTINCT record_date) FROM mood_records',
          ),
        ) ??
        0;
    final recovery =
        Sqflite.firstIntValue(
          await _database.rawQuery(
            "SELECT COUNT(*) FROM habit_recoveries WHERE action = 'continue'",
          ),
        ) ??
        0;
    final sleepRows = await _database.query(
      'sleep_records',
      columns: ['wake_date'],
      groupBy: 'wake_date',
      orderBy: 'wake_date DESC',
    );
    var streak = 0;
    var longestStreak = 0;
    DateTime? expected;
    for (final row in sleepRows) {
      final day = localDateFromKey(row['wake_date']! as String);
      if (expected == null || day == expected) {
        streak++;
        if (streak > longestStreak) {
          longestStreak = streak;
        }
        expected = day.subtract(const Duration(days: 1));
      } else {
        streak = 1;
        expected = day.subtract(const Duration(days: 1));
      }
    }
    return (
      habits: habits,
      journalDays: journalDays,
      moodDays: moodDays,
      sleepStreak: longestStreak,
      recoveries: recovery,
    );
  }
}
