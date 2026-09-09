import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/achievements/achievement_store.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/notifications/notification_store.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/mood_record.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<
    ({
      Database database,
      HabitStore habits,
      ProgressStore progress,
      WellbeingStore wellbeing,
    })
  >
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
      wellbeing: WellbeingStore(database),
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
      adjustment: 'keep',
    );

    expect(review.data['completed'], 1);
    expect(
      (await stores.progress.loadReview(
        type: 'weekly',
        start: DateTime(2026, 8, 1),
      ))?.reflection,
      'Cue pagi membantu.',
    );
    expect(review.data['adjustment'], 'keep');
    expect(review.data['journalCount'], 0);
  });

  test('explainable insights require a local observation threshold', () async {
    final stores = await openStores();
    await completedHabit(stores.habits, repetitions: 5);
    final insights = await InsightStore(stores.database)
        .refresh(now: DateTime(2026, 8, 5));

    expect(insights, hasLength(1));
    expect(insights.single.evidence, contains('5 catatan pelaksanaan lokal'));
  });

  test(
    'mood and sleep insights are local, thresholded, and idempotent',
    () async {
      final stores = await openStores();
      final now = DateTime(2026, 8, 28);
      for (var index = 0; index < 7; index++) {
        final day = now.subtract(Duration(days: index));
        await stores.wellbeing.saveMood(
          valence: MoodValence.good,
          recordedAt: day,
        );
        await stores.wellbeing.saveSleep(
          start: day.subtract(const Duration(hours: 8)),
          end: day,
          quality: SleepQuality.good,
        );
      }

      final insights = await InsightStore(stores.database).refresh(now: now);
      final refreshed = await InsightStore(stores.database).refresh(now: now);

      expect(insights, hasLength(2));
      expect(refreshed, hasLength(2));
      expect(
        insights.map((insight) => insight.type),
        containsAll(['mood_summary', 'sleep_summary']),
      );
      expect(
        insights.every(
          (insight) => !insight.observation.contains('menyebabkan'),
        ),
        isTrue,
      );
    },
  );

  test('recovery journal and cross-domain insights are thresholded locally', () async {
    final stores = await openStores();
    final habit = await stores.habits.create(
      HabitDraft(
        title: 'Membaca',
        frequency: HabitFrequency.daily,
        startDate: DateTime(2026, 8, 1),
      ),
    );
    for (var day = 1; day <= 3; day++) {
      await stores.habits.complete(habit, date: DateTime(2026, 8, day));
      final wake = DateTime(2026, 8, day, 7);
      await stores.wellbeing.saveSleep(
        start: wake.subtract(const Duration(hours: 8)),
        end: wake,
        quality: SleepQuality.good,
      );
    }
    for (var day = 4; day <= 6; day++) {
      final wake = DateTime(2026, 8, day, 7);
      await stores.wellbeing.saveSleep(
        start: wake.subtract(const Duration(hours: 5)),
        end: wake,
        quality: SleepQuality.fair,
      );
    }
    await stores.habits.reconcileMissed(before: DateTime(2026, 8, 7));
    await stores.habits.complete(habit, date: DateTime(2026, 8, 7));
    await stores.habits.reconcileMissed(before: DateTime(2026, 8, 9));
    await stores.habits.complete(habit, date: DateTime(2026, 8, 9));
    final journal = JournalStore(stores.database);
    for (var day = 1; day <= 3; day++) {
      final draft = await journal.createDraft(
        type: JournalEntryType.free,
        now: DateTime(2026, 8, day),
      );
      await journal.finish(draft.copyWith(body: 'Catatan $day'));
    }

    final insights = await InsightStore(stores.database).refresh(
      now: DateTime(2026, 8, 10),
    );

    expect(
      insights.map((insight) => insight.type),
      containsAll([
        'recovery_summary',
        'journal_summary',
        'sleep_habit_observation',
      ]),
    );
    expect(
      insights
          .singleWhere((insight) => insight.type == 'sleep_habit_observation')
          .observation,
      contains('bukan sebab-akibat'),
    );
  });

  test('achievements use local records and unlock only once', () async {
    final stores = await openStores();
    await completedHabit(stores.habits);
    final achievements = AchievementStore(stores.database);

    final first = await achievements.evaluate();
    final second = await achievements.evaluate();

    expect(
      first
          .singleWhere((achievement) => achievement.key == 'first_habit')
          .isUnlocked,
      isTrue,
    );
    expect(
      second
          .singleWhere((achievement) => achievement.key == 'first_habit')
          .isUnlocked,
      isTrue,
    );
    expect(
      await stores.database.query(
        'achievements',
        where: 'key = ?',
        whereArgs: ['first_habit'],
      ),
      hasLength(1),
    );
  });

  test('achievement streaks use historical local records and real recovery', () async {
    final stores = await openStores();
    final habit = await stores.habits.create(
      HabitDraft(
        title: 'Membaca',
        frequency: HabitFrequency.daily,
        startDate: DateTime(2026, 8, 1),
      ),
    );
    await stores.habits.reconcileMissed(before: DateTime(2026, 8, 3));
    await stores.habits.complete(habit, date: DateTime(2026, 8, 3));
    for (var day = 1; day <= 7; day++) {
      final wake = DateTime(2026, 8, day, 7);
      await stores.wellbeing.saveSleep(
        start: wake.subtract(const Duration(hours: 8)),
        end: wake,
        quality: SleepQuality.good,
      );
    }
    final laterWake = DateTime(2026, 8, 20, 7);
    await stores.wellbeing.saveSleep(
      start: laterWake.subtract(const Duration(hours: 8)),
      end: laterWake,
      quality: SleepQuality.good,
    );

    final states = await AchievementStore(stores.database).evaluate();

    expect(
      states.singleWhere((state) => state.key == 'sleep_week').isUnlocked,
      isTrue,
    );
    expect(
      states
          .singleWhere((state) => state.key == 'return_after_pause')
          .isUnlocked,
      isTrue,
    );
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

  test('enabled generic reminders rebuild with quiet-period delivery', () async {
    final stores = await openStores();
    final notifications = NotificationStore(stores.database);
    await notifications.save(
      const NotificationPreference(
        id: 'journal',
        kind: 'journal',
        enabled: true,
        timeOfDay: '23:00',
      ),
    );
    await notifications.save(
      const NotificationPreference(
        id: 'weekly_review',
        kind: 'weekly_review',
        enabled: true,
        timeOfDay: '18:00',
      ),
    );
    await notifications.saveQuietPeriod(start: '22:00', end: '07:00');
    final service = _FakeNotifications();

    await notifications.rebuildSchedules(service);

    expect(service.dailyTime, (7, 0));
    expect(service.weeklySchedules, [103]);
  });

  test(
    'habit reminders use the local schedule and persistent preference',
    () async {
      final stores = await openStores();
      final habit = await stores.habits.create(
        HabitDraft(
          title: 'Membaca',
          frequency: HabitFrequency.specificDays,
          specificDays: {DateTime.monday, DateTime.wednesday},
          reminderTime: '20:00',
          startDate: DateTime(2026, 9, 7),
        ),
      );
      final service = _FakeNotifications();
      final reminders = HabitReminderService(stores.database, service);

      expect(await reminders.synchronize(habit), HabitReminderResult.scheduled);
      expect(service.weeklySchedules, hasLength(2));
      expect(
        (await stores.database.query(
          'notification_preferences',
          where: 'habit_id = ?',
          whereArgs: [habit.id],
        )).single['enabled'],
        1,
      );
    },
  );

  test('quiet periods delay local habit reminder delivery', () async {
    final stores = await openStores();
    await NotificationStore(stores.database)
        .saveQuietPeriod(start: '22:00', end: '07:00');
    final habit = await stores.habits.create(
      HabitDraft(
        title: 'Membaca',
        frequency: HabitFrequency.daily,
        reminderTime: '23:00',
        startDate: DateTime(2026, 9, 7),
      ),
    );
    final service = _FakeNotifications();

    await HabitReminderService(stores.database, service).synchronize(habit);

    expect(service.dailyTime, (7, 0));
  });

  test('notification permission does not block a stored habit', () async {
    final stores = await openStores();
    final habit = await stores.habits.create(
      HabitDraft(
        title: 'Membaca',
        frequency: HabitFrequency.daily,
        reminderTime: '20:00',
        startDate: DateTime(2026, 9, 7),
      ),
    );
    final service = _FakeNotifications(granted: false);

    expect(
      await HabitReminderService(stores.database, service).synchronize(habit),
      HabitReminderResult.permissionUnavailable,
    );
    expect(await stores.habits.list(), hasLength(1));
  });
}

class _FakeNotifications extends LocalNotificationService {
  _FakeNotifications({this.granted = true});

  final bool granted;
  final weeklySchedules = <int>[];
  (int, int)? dailyTime;

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<bool> areNotificationsEnabled() async => granted;

  @override
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    dailyTime = (hour, minute);
  }

  @override
  Future<void> scheduleWeekly({
    required int id,
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    weeklySchedules.add(id);
  }

  @override
  Future<void> cancel(int id) async {}
}
