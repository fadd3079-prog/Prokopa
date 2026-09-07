import 'package:drift/drift.dart' hide isNotNull, isNull;
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

  group('JournalDao Tests', () {
    test('create, read, search, and delete journal', () async {
      final now = DateTime.now();
      final id = await db.journalDao.createJournal(
        JournalsCompanion.insert(
          content: 'Today was productive and energizing!',
          mood: const Value(5),
          energyLevel: const Value(4),
          type: const Value('morning'),
          date: now,
        ),
      );
      expect(id, isPositive);

      final entry = await db.journalDao.getJournal(id);
      expect(entry.content, contains('productive'));
      expect(entry.mood, 5);

      final searchResults = await db.journalDao.searchJournals('productive');
      expect(searchResults.length, 1);

      final count = await db.journalDao.getJournalCount();
      expect(count, 1);

      final avgMood = await db.journalDao.getAverageMood(7);
      expect(avgMood, 5.0);

      await db.journalDao.deleteJournal(id);
      final countAfterDelete = await db.journalDao.getJournalCount();
      expect(countAfterDelete, 0);
    });
  });

  group('SleepDao Tests', () {
    test('create, get latest, average duration, and consistency', () async {
      final now = DateTime.now();

      await db.sleepDao.createRecord(
        SleepRecordsCompanion.insert(
          sleepStart: now.subtract(const Duration(hours: 8)),
          sleepEnd: now,
          duration: 8.0,
          quality: const Value(4),
          date: DateTime(now.year, now.month, now.day),
        ),
      );

      final latest = await db.sleepDao.getLatestRecord();
      expect(latest, isNotNull);
      expect(latest!.duration, 8.0);
      expect(latest.quality, 4);

      final avgDuration = await db.sleepDao.getAverageDuration(7);
      expect(avgDuration, 8.0);

      final avgQuality = await db.sleepDao.getAverageQuality(7);
      expect(avgQuality, 4.0);

      final consistency = await db.sleepDao.getSleepConsistency(7);
      expect(consistency, closeTo(1 / 7, 0.01));
    });
  });
}
