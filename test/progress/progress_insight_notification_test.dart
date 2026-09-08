import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/notifications/notification_store.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<({Database database, HabitStore habits, ProgressStore progress})>
  openStores() async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return (
      database: database,
      habits: HabitStore(database),
      progress: ProgressStore(database),
    );
  }

  Future<Habit> completedHabit(HabitStore store, {int repetitions = 1}) async {
    final habit = await store.create(
      HabitDraft(
        title: 'Membaca',
        frequency: HabitFrequency.daily,
        startDate: DateTime(2026, 8, 1),
      ),
    );
    for (var index = 0; index < repetitions; index++) {
      await store.complete(habit, date: DateTime(2026, 8, 1 + index));
    }
    return habit;
  }

  test(
    'progress excludes no-plan and exposes completed skipped missed states',
    () async {
      final stores = await openStores();
      final habit = await completedHabit(stores.habits);
      await stores.habits.skip(
        habit,
        date: DateTime(2026, 8, 2),
        reason: 'rest',
      );
      await stores.habits.reconcileMissed(before: DateTime(2026, 8, 4));

      final snapshot = await stores.progress.snapshot(
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 3),
      );
      expect(snapshot.completed, 1);
      expect(snapshot.skipped, 1);
      expect(snapshot.missed, 1);
      expect(snapshot.planned, 3);
      expect(snapshot.completionRate, closeTo(1 / 3, 0.0001));
    },
  );

  test('weekly review persists rebuildable local summary', () async {
    final stores = await openStores();
    await completedHabit(stores.habits);

    final review = await stores.progress.saveReview(
      type: 'weekly',
      start: DateTime(2026, 8, 1),
      end: DateTime(2026, 8, 7),
      reflection: 'Cue pagi membantu.',
    );

    expect(review.data['completed'], 1);
    expect(
      (await stores.progress.loadReview(
        type: 'weekly',
        start: DateTime(2026, 8, 1),
      ))?.reflection,
      'Cue pagi membantu.',
    );
  });

  test('explainable insights require a local observation threshold', () async {
    final stores = await openStores();
    await completedHabit(stores.habits, repetitions: 5);
    final insights = await InsightStore(stores.database)
        .refresh(now: DateTime(2026, 8, 5));

    expect(insights, hasLength(1));
    expect(insights.single.evidence, contains('5 catatan pelaksanaan lokal'));
  });

  test('notification preferences and quiet period persist locally', () async {
    final stores = await openStores();
    final notifications = NotificationStore(stores.database);
    await notifications.save(
      const NotificationPreference(
        id: 'journal',
        kind: 'journal',
        enabled: true,
        timeOfDay: '20:00',
      ),
    );
    await notifications.saveQuietPeriod(start: '22:00', end: '07:00');

    expect((await notifications.load('journal')).enabled, isTrue);
    expect(await notifications.quietPeriod(), ('22:00', '07:00'));
  });
}
