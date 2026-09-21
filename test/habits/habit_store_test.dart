import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_schedule.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<({HabitStore store, Database database})> openStore() async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return (store: HabitStore(database), database: database);
  }

  HabitDraft draft({
    String title = 'Membaca',
    HabitFrequency frequency = HabitFrequency.daily,
    Set<int> specificDays = const {},
    int? weeklyTarget,
    DateTime? startDate,
  }) => HabitDraft(
    title: title,
    frequency: frequency,
    specificDays: specificDays,
    weeklyTarget: weeklyTarget,
    startDate: startDate ?? DateTime(2026, 9, 7),
    minimumVersion: 'Satu halaman',
  );

  test('daily and specific-day schedules distinguish no-plan', () {
    final daily = draft();
    final specific = draft(
      frequency: HabitFrequency.specificDays,
      specificDays: {DateTime.monday, DateTime.wednesday},
    );

    expect(isHabitScheduledOn(daily, DateTime(2026, 9, 8)), isTrue);
    expect(isHabitScheduledOn(specific, DateTime(2026, 9, 7)), isTrue);
    expect(isHabitScheduledOn(specific, DateTime(2026, 9, 8)), isFalse);
  });

  test(
    'weekly targets track completed repetitions without daily obligations',
    () async {
      final result = await openStore();
      final habit = await result.store.create(
        draft(frequency: HabitFrequency.weeklyTarget, weeklyTarget: 3),
        now: DateTime(2026, 9, 7),
      );

      expect(isHabitScheduledOn(habit.draft, DateTime(2026, 9, 7)), isFalse);
      await result.store.complete(habit, date: DateTime(2026, 9, 7));
      await result.store.complete(habit, date: DateTime(2026, 9, 8));
      final today = await result.store.loadToday(now: DateTime(2026, 9, 9));

      expect(today.single.completedThisWeek, 2);
      expect(today.single.weeklyTarget, 3);
    },
  );

  test('completion is idempotent and creates one logical execution', () async {
    final result = await openStore();
    final habit = await result.store.create(draft());

    await result.store.complete(habit, date: DateTime(2026, 9, 9));
    await result.store.complete(habit, date: DateTime(2026, 9, 9));

    final history = await result.store.history(habit);
    expect(history, hasLength(1));
    expect(history.single.state, HabitExecutionState.completed);
  });

  test('skip remains distinct from completion', () async {
    final result = await openStore();
    final habit = await result.store.create(draft());

    await result.store.skip(habit, reason: 'rest', date: DateTime(2026, 9, 9));

    final history = await result.store.history(habit);
    expect(history.single.state, HabitExecutionState.skipped);
    expect(history.single.skipReason, 'rest');
  });

  test(
    'a completed or skipped current instance can be returned to due',
    () async {
      final result = await openStore();
      final today = DateTime.now();
      final habit = await result.store.create(
        draft(startDate: today),
        now: today,
      );

      await result.store.complete(habit, date: today);
      await result.store.undo(habit, date: today);
      expect(await result.store.history(habit), isEmpty);

      await result.store.skip(habit, date: today);
      await result.store.undo(habit, date: today);
      expect(await result.store.history(habit), isEmpty);
    },
  );

  test(
    'expired planned daily work becomes missed while no-plan stays absent',
    () async {
      final result = await openStore();
      final daily = await result.store.create(
        draft(startDate: DateTime(2026, 9, 7)),
      );
      final specific = await result.store.create(
        draft(
          title: 'Rabu',
          frequency: HabitFrequency.specificDays,
          specificDays: {DateTime.wednesday},
          startDate: DateTime(2026, 9, 7),
        ),
      );

      await result.store.reconcileMissed(before: DateTime(2026, 9, 9));

      expect(await result.store.history(daily), hasLength(2));
      expect((await result.store.history(specific)), isEmpty);
    },
  );

  test(
    'pause prevents missed records and resume restores future eligibility',
    () async {
      final result = await openStore();
      final habit = await result.store.create(
        draft(startDate: DateTime(2026, 9, 7)),
      );

      await result.store.pause(habit, now: DateTime(2026, 9, 7));
      await result.store.reconcileMissed(before: DateTime(2026, 9, 9));
      expect(await result.store.history(habit), isEmpty);

      final paused = (await result.store.list()).single;
      await result.store.resume(paused, now: DateTime(2026, 9, 9));
      expect(
        (await result.store.loadToday(now: DateTime(2026, 9, 9)))
            .single
            .habit
            .id,
        habit.id,
      );
    },
  );

  test('archive preserves history and removes a habit from Today', () async {
    final result = await openStore();
    final habit = await result.store.create(draft());
    await result.store.complete(habit, date: DateTime(2026, 9, 9));

    await result.store.archive(habit, now: DateTime(2026, 9, 9));

    expect(await result.store.loadToday(now: DateTime(2026, 9, 9)), isEmpty);
    expect(
      (await result.store.history(habit))
          .any((record) => record.state == HabitExecutionState.completed),
      isTrue,
    );
  });

  test('archived habit can be restored without losing execution history', () async {
    final result = await openStore();
    final habit = await result.store.create(draft());
    await result.store.complete(habit, date: DateTime(2026, 9, 9));
    await result.store.archive(habit, now: DateTime(2026, 9, 9));

    final archived = (await result.store.list(includeArchived: true)).single;
    await result.store.restore(archived);

    final restored = (await result.store.list()).single;
    expect(restored.state, HabitState.active);
    expect(await result.store.history(restored), hasLength(1));
  });

  test(
    'future configuration updates retain historical execution snapshots',
    () async {
      final result = await openStore();
      final habit = await result.store.create(draft(title: 'Membaca'));
      await result.store.complete(habit, date: DateTime(2026, 9, 9));

      await result.store.update(
        habit,
        draft(title: 'Membaca santai', startDate: DateTime(2026, 9, 7)),
        now: DateTime(2026, 9, 9),
      );

      final record = (await result.database.query('habit_executions')).single;
      final snapshot =
          jsonDecode(record['configuration_snapshot']! as String) as Map;
      expect(snapshot['title'], 'Membaca');
      expect(
        await result.database.query(
          'habit_configuration_history',
          where: 'habit_id = ?',
          whereArgs: [habit.id],
        ),
        hasLength(2),
      );
    },
  );

  test(
    'same-day schedule edits apply tomorrow without rewriting today',
    () async {
      final result = await openStore();
      final habit = await result.store.create(
        draft(startDate: DateTime(2026, 9, 7)),
      );

      final changed = draft(
        frequency: HabitFrequency.specificDays,
        specificDays: {DateTime.wednesday},
        startDate: DateTime(2026, 9, 7),
      );
      await result.store.update(habit, changed, now: DateTime(2026, 9, 9));
      await result.store.update(habit, changed, now: DateTime(2026, 9, 9));

      expect(
        (await result.store.loadToday(now: DateTime(2026, 9, 9)))
            .single
            .habit
            .id,
        habit.id,
      );
      expect(await result.store.loadToday(now: DateTime(2026, 9, 10)), isEmpty);
      await result.store.reconcileMissed(before: DateTime(2026, 9, 11));
      expect(
        (await result.store.history(habit))
            .where((record) => record.plannedDate == DateTime(2026, 9, 10)),
        isEmpty,
      );
    },
  );

  test('weekly target is reduced only for an eligible partial week', () async {
    final result = await openStore();
    final habit = await result.store.create(
      draft(
        frequency: HabitFrequency.weeklyTarget,
        weeklyTarget: 7,
        startDate: DateTime(2026, 9, 9),
      ),
      now: DateTime(2026, 9, 9),
    );

    final today = await result.store.loadToday(now: DateTime(2026, 9, 9));

    expect(today.single.habit.id, habit.id);
    expect(today.single.weeklyTarget, 5);
  });

  test('future executions are rejected before they are persisted', () async {
    final result = await openStore();
    final today = DateTime.now();
    final habit = await result.store.create(
      draft(startDate: today),
      now: today,
    );

    await expectLater(
      result.store.complete(habit, date: today.add(const Duration(days: 1))),
      throwsStateError,
    );
    expect(await result.store.history(habit), isEmpty);
  });

  test('returning after a missed occurrence records one recovery', () async {
    final result = await openStore();
    final today = DateTime.now();
    final habit = await result.store.create(
      draft(startDate: today.subtract(const Duration(days: 2))),
    );
    await result.store.reconcileMissed(before: today);
    final history = await result.store.history(habit);

    await result.store.complete(habit, date: today);
    await result.store.complete(habit, date: today);

    expect((await result.store.history(habit)).length, history.length + 1);
    expect(await result.store.recoveryCount(habit), 1);
    expect(
      (await result.store.recoveryHistory(habit)).single.action,
      HabitRecoveryAction.continueHabit,
    );
  });

  test('separate interruptions produce separate recovery records', () async {
    final result = await openStore();
    final today = DateTime.now();
    final habit = await result.store.create(
      draft(startDate: today.subtract(const Duration(days: 5))),
    );

    await result.store.reconcileMissed(
      before: today.subtract(const Duration(days: 3)),
    );
    await result.store.complete(
      habit,
      date: today.subtract(const Duration(days: 3)),
    );
    await result.store.reconcileMissed(before: today);
    await result.store.complete(habit, date: today);

    expect(await result.store.recoveryCount(habit), 2);
  });

  test(
    'habit progress keeps streak, repetition, and recovery metrics distinct',
    () async {
      final result = await openStore();
      final today = DateTime.now();
      final habit = await result.store.create(
        draft(startDate: today.subtract(const Duration(days: 4))),
      );
      await result.store.complete(
        habit,
        date: today.subtract(const Duration(days: 4)),
      );
      await result.store.complete(
        habit,
        date: today.subtract(const Duration(days: 3)),
      );
      await result.store.reconcileMissed(before: today);
      await result.store.complete(habit, date: today);

      final progress = (await result.store.progress(now: today)).single;

      expect(progress.repetitions, 3);
      expect(progress.currentStreak, 1);
      expect(progress.longestStreak, 2);
      expect(progress.recoveryCount, 1);
    },
  );

  test('weekly habits use successful weeks for streaks', () async {
    final result = await openStore();
    final today = DateTime.now();
    final currentWeek = startOfWeek(today);
    final habit = await result.store.create(
      draft(
        frequency: HabitFrequency.weeklyTarget,
        weeklyTarget: 1,
        startDate: currentWeek.subtract(const Duration(days: 14)),
      ),
    );
    for (final day in [
      currentWeek.subtract(const Duration(days: 14)),
      currentWeek.subtract(const Duration(days: 7)),
      today,
    ]) {
      await result.store.complete(habit, date: day);
    }

    final progress = (await result.store.progress(now: today)).single;

    expect(progress.weekCompleted, 1);
    expect(progress.weekTarget, 1);
    expect(progress.currentStreak, 3);
    expect(progress.longestStreak, 3);
  });

  test(
    'habit deletion removes the habit and its executions transactionally',
    () async {
      final result = await openStore();
      final habit = await result.store.create(draft());
      await result.store.complete(habit, date: DateTime(2026, 9, 9));

      await result.store.delete(habit);

      expect(await result.store.list(includeArchived: true), isEmpty);
      expect(await result.database.query('habit_executions'), isEmpty);
    },
  );
}
