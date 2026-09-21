import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/wellbeing/mood_record.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<({JournalStore journal, WellbeingStore wellbeing})>
  openStores() async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return (
      journal: JournalStore(database),
      wellbeing: WellbeingStore(database),
    );
  }

  test('journal draft autosave data survives reload and search', () async {
    final stores = await openStores();
    final draft = await stores.journal.createDraft(
      type: JournalEntryType.free,
      now: DateTime(2026, 9, 9),
    );
    await stores.journal.save(
      draft.copyWith(
        title: 'Catatan pagi',
        body: 'Saya ingin berjalan pelan hari ini.',
        tags: const ['pagi', 'jalan'],
      ),
    );

    final loaded = await stores.journal.load(draft.id);
    expect(loaded?.status, JournalEntryStatus.draft);
    expect(loaded?.body, 'Saya ingin berjalan pelan hari ini.');
    expect((await stores.journal.list(query: 'berjalan')).single.id, draft.id);
    expect((await stores.journal.list(tag: 'jalan')).single.id, draft.id);
  });

  test('guided journal responses and finished state persist', () async {
    final stores = await openStores();
    final draft = await stores.journal.createDraft(
      type: JournalEntryType.guided,
      now: DateTime(2026, 9, 9),
    );
    await stores.journal.finish(
      draft.copyWith(
        body: 'Saya membutuhkan jeda.',
        guidedResponses: const {
          'Apa yang sedang kamu alami hari ini?': 'Saya membutuhkan jeda.',
        },
        promptIndex: 1,
      ),
    );

    final loaded = await stores.journal.load(draft.id);
    expect(loaded?.status, JournalEntryStatus.saved);
    expect(loaded?.guidedResponses.values.single, 'Saya membutuhkan jeda.');
  });

  test('mood is self-reported with optional context', () async {
    final stores = await openStores();
    await stores.wellbeing.saveMood(
      valence: MoodValence.good,
      energy: MoodEnergy.medium,
      emotion: MoodEmotion.calm,
      context: MoodContext.exercise,
      recordedAt: DateTime(2026, 9, 9, 8),
    );

    final record = (await stores.wellbeing.listMood()).single;
    expect(record.valence, MoodValence.good);
    expect(record.context, MoodContext.exercise);
  });

  test(
    'mood can be edited and deleted without touching journal data',
    () async {
      final stores = await openStores();
      final created = await stores.wellbeing.saveMood(
        valence: MoodValence.low,
        recordedAt: DateTime(2026, 9, 9, 8),
      );

      await stores.wellbeing.saveMood(
        id: created.id,
        valence: MoodValence.good,
        energy: MoodEnergy.high,
        recordedAt: created.recordedAt,
      );
      final edited = (await stores.wellbeing.listMood()).single;
      expect(edited.valence, MoodValence.good);
      expect(edited.energy, MoodEnergy.high);

      await stores.wellbeing.deleteMood(edited.id);
      expect(await stores.wellbeing.listMood(), isEmpty);
    },
  );

  test('sleep uses wake date and calculates cross-midnight duration', () async {
    final stores = await openStores();
    final record = await stores.wellbeing.saveSleep(
      start: DateTime(2026, 9, 8, 23),
      end: DateTime(2026, 9, 9, 6, 30),
      quality: SleepQuality.good,
    );

    expect(record.durationMinutes, 450);
    final loaded = (await stores.wellbeing.listSleep()).single;
    expect(loaded.durationMinutes, 450);
    expect(await stores.wellbeing.averageSleepDuration(), 450);
  });

  test('invalid sleep durations are rejected before persistence', () async {
    final stores = await openStores();

    await expectLater(
      stores.wellbeing.saveSleep(
        start: DateTime(2026, 9, 9, 8),
        end: DateTime(2026, 9, 9, 8),
        quality: SleepQuality.fair,
      ),
      throwsArgumentError,
    );
    expect(await stores.wellbeing.listSleep(), isEmpty);
  });

  test(
    'sleep updates preserve identity and expose local quality metrics',
    () async {
      final stores = await openStores();
      final record = await stores.wellbeing.saveSleep(
        start: DateTime(2026, 9, 8, 23),
        end: DateTime(2026, 9, 9, 6),
        quality: SleepQuality.fair,
      );

      final updated = await stores.wellbeing.saveSleep(
        id: record.id,
        start: DateTime(2026, 9, 8, 23),
        end: DateTime(2026, 9, 9, 7),
        quality: SleepQuality.excellent,
      );

      expect((await stores.wellbeing.listSleep()), hasLength(1));
      expect(updated.durationMinutes, 480);
      expect(await stores.wellbeing.averageSleepQuality(), 4);
      expect(await stores.wellbeing.sleepConsistency(), 1);
    },
  );
}
