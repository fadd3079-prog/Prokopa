import 'dart:convert';

import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/core/identifiers/local_id.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_schedule.dart';
import 'package:sqflite/sqflite.dart';

class HabitStore {
  HabitStore(this._database);

  final Database _database;

  Future<Habit> create(HabitDraft draft, {DateTime? now}) async {
    _validate(draft);
    final createdAt = now ?? DateTime.now();
    final habit = Habit(
      id: newLocalId(),
      draft: _normalizedDraft(draft),
      state: HabitState.active,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    await _database.transaction((transaction) async {
      await transaction.insert('habits', _habitValues(habit));
      await transaction.insert('habit_configuration_history', {
        'id': newLocalId(),
        'habit_id': habit.id,
        'effective_from': localDateKey(habit.draft.startDate),
        'effective_until': null,
        'configuration': jsonEncode(_configuration(habit.draft)),
        'created_at': utcTimestamp(createdAt),
      });
    });
    return habit;
  }

  Future<List<Habit>> list({bool includeArchived = false}) async {
    final rows = await _database.query(
      'habits',
      where: includeArchived ? null : 'state != ?',
      whereArgs: includeArchived ? null : [HabitState.archived.value],
      orderBy: 'created_at ASC',
    );
    return rows.map(_habitFromRow).toList();
  }

  Future<List<TodayHabit>> loadToday({DateTime? now}) async {
    final day = now ?? DateTime.now();
    await reconcileMissed(before: day);
    final habits = await list();
    final key = localDateKey(day);
    final weekStart = localDateKey(startOfWeek(day));
    final weekEnd = localDateKey(endOfWeek(day));
    final executions = await _database.query(
      'habit_executions',
      where: 'planned_date BETWEEN ? AND ?',
      whereArgs: [weekStart, weekEnd],
    );
    final byHabit = <String, List<HabitExecution>>{};
    for (final row in executions) {
      final execution = _executionFromRow(row);
      byHabit.putIfAbsent(execution.habitId, () => []).add(execution);
    }
    final pauses = await _pausesFor(habits.map((habit) => habit.id));
    final result = <TodayHabit>[];
    for (final habit in habits) {
      if (habit.state != HabitState.active ||
          _isPausedOn(pauses[habit.id] ?? const [], day)) {
        continue;
      }
      final effectiveHabit = habit.withDraft(await _draftForDate(habit, day));
      final records = byHabit[habit.id] ?? const [];
      final completed = records
          .where((record) => record.state == HabitExecutionState.completed)
          .length;
      if (effectiveHabit.draft.frequency == HabitFrequency.weeklyTarget) {
        final target = await _weeklyTargetForPeriod(effectiveHabit, day);
        if (target > 0 && completed < target) {
          result.add(
            TodayHabit(
              habit: effectiveHabit,
              completedThisWeek: completed,
              weeklyTarget: target,
            ),
          );
        }
        continue;
      }
      if (!isHabitScheduledOn(effectiveHabit.draft, day)) {
        continue;
      }
      final execution = records
          .where((record) => localDateKey(record.plannedDate) == key)
          .firstOrNull;
      result.add(
        TodayHabit(
          habit: effectiveHabit,
          execution: execution,
          completedThisWeek: completed,
          weeklyTarget: null,
        ),
      );
    }
    result.sort((left, right) {
      if (left.isComplete != right.isComplete) {
        return left.isComplete ? 1 : -1;
      }
      return left.habit.createdAt.compareTo(right.habit.createdAt);
    });
    return result;
  }

  Future<void> complete(Habit habit, {DateTime? date}) async {
    final day = date ?? DateTime.now();
    _ensureNotFuture(day);
    final effectiveHabit = habit.withDraft(await _draftForDate(habit, day));
    if (!await _canRecord(effectiveHabit, day)) {
      throw StateError('Habit is not scheduled for this date.');
    }
    final key = localDateKey(day);
    await _database.transaction((transaction) async {
      final rows = await transaction.query(
        'habit_executions',
        where: 'habit_id = ? AND planned_date = ?',
        whereArgs: [habit.id, key],
        limit: 1,
      );
      if (rows.singleOrNull?['state'] == HabitExecutionState.completed.value) {
        return;
      }
      if (rows.singleOrNull?['state'] == HabitExecutionState.missed.value) {
        throw StateError('A missed execution cannot be completed implicitly.');
      }
      final now = utcTimestamp(DateTime.now());
      final values = {
        'habit_id': effectiveHabit.id,
        'planned_date': key,
        'state': HabitExecutionState.completed.value,
        'skip_reason': null,
        'note': null,
        'configuration_snapshot': jsonEncode(
          _configuration(effectiveHabit.draft),
        ),
        'recorded_at': now,
        'updated_at': now,
      };
      if (rows.isEmpty) {
        await transaction.insert('habit_executions', {
          'id': newLocalId(),
          ...values,
        });
      } else {
        await transaction.update(
          'habit_executions',
          values,
          where: 'id = ?',
          whereArgs: [rows.single['id']],
        );
      }
    });
  }

  Future<void> skip(
    Habit habit, {
    String reason = 'other',
    DateTime? date,
  }) async {
    final day = date ?? DateTime.now();
    _ensureNotFuture(day);
    final effectiveHabit = habit.withDraft(await _draftForDate(habit, day));
    if (effectiveHabit.draft.frequency == HabitFrequency.weeklyTarget ||
        !await _canRecord(effectiveHabit, day)) {
      throw StateError('Habit is not scheduled for this date.');
    }
    final key = localDateKey(day);
    final now = utcTimestamp(DateTime.now());
    await _database.transaction((transaction) async {
      final rows = await transaction.query(
        'habit_executions',
        where: 'habit_id = ? AND planned_date = ?',
        whereArgs: [habit.id, key],
        limit: 1,
      );
      if (rows.singleOrNull?['state'] == HabitExecutionState.completed.value) {
        throw StateError('A completed execution cannot be skipped.');
      }
      final values = {
        'habit_id': effectiveHabit.id,
        'planned_date': key,
        'state': HabitExecutionState.skipped.value,
        'skip_reason': reason,
        'note': null,
        'configuration_snapshot': jsonEncode(
          _configuration(effectiveHabit.draft),
        ),
        'recorded_at': now,
        'updated_at': now,
      };
      if (rows.isEmpty) {
        await transaction.insert('habit_executions', {
          'id': newLocalId(),
          ...values,
        });
      } else {
        await transaction.update(
          'habit_executions',
          values,
          where: 'id = ?',
          whereArgs: [rows.single['id']],
        );
      }
    });
  }

  Future<void> pause(Habit habit, {DateTime? now}) async {
    final day = now ?? DateTime.now();
    if (habit.state != HabitState.active) {
      return;
    }
    final timestamp = utcTimestamp(day);
    await _database.transaction((transaction) async {
      await transaction.update(
        'habits',
        {
          'state': HabitState.paused.value,
          'paused_at': timestamp,
          'updated_at': timestamp,
        },
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      await transaction.insert('habit_pauses', {
        'id': newLocalId(),
        'habit_id': habit.id,
        'start_date': localDateKey(day),
        'end_date': null,
        'created_at': timestamp,
      });
    });
  }

  Future<void> pauseWithRecovery(Habit habit, {DateTime? now}) async {
    final day = now ?? DateTime.now();
    if (habit.state != HabitState.active) {
      return;
    }
    final timestamp = utcTimestamp(day);
    await _database.transaction((transaction) async {
      await transaction.update(
        'habits',
        {
          'state': HabitState.paused.value,
          'paused_at': timestamp,
          'updated_at': timestamp,
        },
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      await transaction.insert('habit_pauses', {
        'id': newLocalId(),
        'habit_id': habit.id,
        'start_date': localDateKey(day),
        'end_date': null,
        'created_at': timestamp,
      });
      await transaction.insert('habit_recoveries', {
        'id': newLocalId(),
        'habit_id': habit.id,
        'action': HabitRecoveryAction.pause.value,
        'recorded_at': timestamp,
      });
    });
  }

  Future<void> resume(Habit habit, {DateTime? now}) async {
    final day = now ?? DateTime.now();
    if (habit.state != HabitState.paused) {
      return;
    }
    final key = localDateKey(day);
    final timestamp = utcTimestamp(day);
    await _database.transaction((transaction) async {
      final pauses = await transaction.query(
        'habit_pauses',
        where: 'habit_id = ? AND end_date IS NULL',
        whereArgs: [habit.id],
        orderBy: 'start_date DESC',
        limit: 1,
      );
      if (pauses.isNotEmpty) {
        if (pauses.single['start_date'] == key) {
          await transaction.delete(
            'habit_pauses',
            where: 'id = ?',
            whereArgs: [pauses.single['id']],
          );
        } else {
          final yesterday = localDateKey(day.subtract(const Duration(days: 1)));
          await transaction.update(
            'habit_pauses',
            {'end_date': yesterday},
            where: 'id = ?',
            whereArgs: [pauses.single['id']],
          );
        }
      }
      await transaction.update(
        'habits',
        {
          'state': HabitState.active.value,
          'paused_at': null,
          'updated_at': timestamp,
        },
        where: 'id = ?',
        whereArgs: [habit.id],
      );
    });
  }

  Future<void> archive(Habit habit, {DateTime? now}) async {
    if (habit.state == HabitState.archived) {
      return;
    }
    final timestamp = utcTimestamp(now ?? DateTime.now());
    await _database.update(
      'habits',
      {
        'state': HabitState.archived.value,
        'archived_at': timestamp,
        'updated_at': timestamp,
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> restore(Habit habit) async {
    if (habit.state != HabitState.archived) {
      return;
    }
    await _database.update(
      'habits',
      {
        'state': HabitState.active.value,
        'archived_at': null,
        'updated_at': utcTimestamp(DateTime.now()),
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> recordRecovery(
    Habit habit,
    HabitRecoveryAction action, {
    DateTime? now,
  }) {
    return _database.insert('habit_recoveries', {
      'id': newLocalId(),
      'habit_id': habit.id,
      'action': action.value,
      'recorded_at': utcTimestamp(now ?? DateTime.now()),
    });
  }

  Future<List<HabitRecovery>> recoveryHistory(Habit habit) async {
    final rows = await _database.query(
      'habit_recoveries',
      where: 'habit_id = ?',
      whereArgs: [habit.id],
      orderBy: 'recorded_at DESC',
    );
    return rows
        .map(
          (row) => HabitRecovery(
            id: row['id']! as String,
            habitId: row['habit_id']! as String,
            action: switch (row['action']! as String) {
              'reduce_target' => HabitRecoveryAction.reduceTarget,
              'change_cue' => HabitRecoveryAction.changeCue,
              'pause' => HabitRecoveryAction.pause,
              _ => HabitRecoveryAction.continueHabit,
            },
            recordedAt: DateTime.parse(row['recorded_at']! as String),
          ),
        )
        .toList();
  }

  Future<int> recoveryCount(Habit habit) {
    return _database
        .rawQuery('SELECT COUNT(*) FROM habit_recoveries WHERE habit_id = ?', [
          habit.id,
        ])
        .then((rows) => Sqflite.firstIntValue(rows) ?? 0);
  }

  Future<void> delete(Habit habit) {
    return _database.transaction(
      (transaction) =>
          transaction.delete('habits', where: 'id = ?', whereArgs: [habit.id]),
    );
  }

  Future<Habit> update(Habit habit, HabitDraft draft, {DateTime? now}) async {
    _validate(draft);
    final updatedAt = now ?? DateTime.now();
    final effectiveFrom = localDateKey(updatedAt.add(const Duration(days: 1)));
    final effectiveUntil = localDateKey(updatedAt);
    final updated = Habit(
      id: habit.id,
      draft: _normalizedDraft(draft),
      state: habit.state,
      createdAt: habit.createdAt,
      updatedAt: updatedAt,
      pausedAt: habit.pausedAt,
      archivedAt: habit.archivedAt,
    );
    await _database.transaction((transaction) async {
      final futureRows = await transaction.query(
        'habit_configuration_history',
        where: 'habit_id = ? AND effective_from = ?',
        whereArgs: [habit.id, effectiveFrom],
        limit: 1,
      );
      if (futureRows.isEmpty) {
        await transaction.update(
          'habit_configuration_history',
          {'effective_until': effectiveUntil},
          where: 'habit_id = ? AND effective_until IS NULL',
          whereArgs: [habit.id],
        );
        await transaction.insert('habit_configuration_history', {
          'id': newLocalId(),
          'habit_id': habit.id,
          'effective_from': effectiveFrom,
          'effective_until': null,
          'configuration': jsonEncode(_configuration(updated.draft)),
          'created_at': utcTimestamp(updatedAt),
        });
      } else {
        await transaction.update(
          'habit_configuration_history',
          {
            'configuration': jsonEncode(_configuration(updated.draft)),
            'created_at': utcTimestamp(updatedAt),
          },
          where: 'id = ?',
          whereArgs: [futureRows.single['id']],
        );
      }
      await transaction.update(
        'habits',
        _habitValues(updated)
          ..removeWhere((key, _) => key == 'id' || key == 'created_at'),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
    });
    return updated;
  }

  Future<List<HabitExecution>> history(Habit habit) async {
    final rows = await _database.query(
      'habit_executions',
      where: 'habit_id = ?',
      whereArgs: [habit.id],
      orderBy: 'planned_date DESC',
    );
    return rows.map(_executionFromRow).toList();
  }

  Future<int> dailyStreak(Habit habit, {DateTime? now}) async {
    final day = now ?? DateTime.now();
    final records = await history(habit);
    final byDate = {
      for (final record in records) localDateKey(record.plannedDate): record,
    };
    final pauses = await _pausesFor([habit.id]);
    var cursor = DateTime(day.year, day.month, day.day);
    var total = 0;
    while (!cursor.isBefore(_localDay(habit.createdAt))) {
      final draft = await _draftForDate(habit, cursor);
      if (draft.frequency == HabitFrequency.weeklyTarget) {
        return 0;
      }
      if (_isPausedOn(pauses[habit.id] ?? const [], cursor) ||
          !isHabitScheduledOn(draft, cursor)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      final state = byDate[localDateKey(cursor)]?.state;
      if (state == HabitExecutionState.completed) {
        total++;
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      if (cursor.year == day.year &&
          cursor.month == day.month &&
          cursor.day == day.day) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      return total;
    }
    return total;
  }

  Future<void> reconcileMissed({required DateTime before}) async {
    final yesterday = DateTime(
      before.year,
      before.month,
      before.day,
    ).subtract(const Duration(days: 1));
    final habits = await list(includeArchived: true);
    final pauses = await _pausesFor(habits.map((habit) => habit.id));
    final configurations = <String, List<_ConfigurationRange>>{};
    for (final habit in habits) {
      configurations[habit.id] = await _configurationRanges(habit.id);
    }
    await _database.transaction((transaction) async {
      for (final habit in habits) {
        final ranges = configurations[habit.id] ?? const [];
        if (ranges.isEmpty) {
          continue;
        }
        var cursor = ranges.first.effectiveFrom;
        final archiveDate = habit.archivedAt == null
            ? null
            : DateTime(
                habit.archivedAt!.toLocal().year,
                habit.archivedAt!.toLocal().month,
                habit.archivedAt!.toLocal().day,
              ).subtract(const Duration(days: 1));
        final end = [
          yesterday,
          ?archiveDate,
        ].reduce((left, right) => left.isBefore(right) ? left : right);
        if (cursor.isAfter(end)) {
          continue;
        }
        final existing = await transaction.query(
          'habit_executions',
          columns: ['planned_date'],
          where: 'habit_id = ? AND planned_date BETWEEN ? AND ?',
          whereArgs: [habit.id, localDateKey(cursor), localDateKey(end)],
        );
        final known = existing
            .map((row) => row['planned_date']! as String)
            .toSet();
        while (!cursor.isAfter(end)) {
          final key = localDateKey(cursor);
          final draft = _draftFromRanges(ranges, cursor);
          if (draft != null &&
              draft.frequency != HabitFrequency.weeklyTarget &&
              isHabitScheduledOn(draft, cursor) &&
              !_isPausedOn(pauses[habit.id] ?? const [], cursor) &&
              !known.contains(key)) {
            final timestamp = utcTimestamp(DateTime.now());
            await transaction.insert('habit_executions', {
              'id': newLocalId(),
              'habit_id': habit.id,
              'planned_date': key,
              'state': HabitExecutionState.missed.value,
              'skip_reason': null,
              'note': null,
              'configuration_snapshot': jsonEncode(_configuration(draft)),
              'recorded_at': timestamp,
              'updated_at': timestamp,
            });
          }
          cursor = cursor.add(const Duration(days: 1));
        }
      }
    });
  }

  Future<bool> _canRecord(Habit habit, DateTime day) async {
    if (habit.state != HabitState.active) {
      return false;
    }
    final pauses = await _pausesFor([habit.id]);
    if (_isPausedOn(pauses[habit.id] ?? const [], day)) {
      return false;
    }
    return habit.draft.frequency == HabitFrequency.weeklyTarget
        ? _isWithinActiveRange(habit.draft, day)
        : isHabitScheduledOn(habit.draft, day);
  }

  Future<HabitDraft> _draftForDate(Habit habit, DateTime day) async {
    final ranges = await _configurationRanges(habit.id);
    return _draftFromRanges(ranges, day) ?? habit.draft;
  }

  Future<List<_ConfigurationRange>> _configurationRanges(String habitId) async {
    final rows = await _database.query(
      'habit_configuration_history',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'effective_from ASC',
    );
    return rows
        .map(
          (row) => _ConfigurationRange(
            effectiveFrom: localDateFromKey(row['effective_from']! as String),
            effectiveUntil: row['effective_until'] == null
                ? null
                : localDateFromKey(row['effective_until']! as String),
            draft: _draftFromConfiguration(
              jsonDecode(row['configuration']! as String)
                  as Map<String, Object?>,
            ),
          ),
        )
        .toList();
  }

  HabitDraft? _draftFromRanges(List<_ConfigurationRange> ranges, DateTime day) {
    final local = _localDay(day);
    for (final range in ranges.reversed) {
      if (!local.isBefore(range.effectiveFrom) &&
          (range.effectiveUntil == null ||
              !local.isAfter(range.effectiveUntil!))) {
        return range.draft;
      }
    }
    return null;
  }

  HabitDraft _draftFromConfiguration(Map<String, Object?> values) => HabitDraft(
    title: values['title']! as String,
    purpose: values['purpose'] as String?,
    category: values['category'] as String?,
    icon: values['icon'] as String?,
    color: values['color'] as String?,
    frequency: HabitFrequencyValue.fromValue(values['frequency']! as String),
    specificDays: (values['specificDays'] as List? ?? const [])
        .cast<int>()
        .toSet(),
    weeklyTarget: values['weeklyTarget'] as int?,
    cueWhen: values['cueWhen'] as String?,
    cueWhere: values['cueWhere'] as String?,
    cueAction: values['cueAction'] as String?,
    minimumVersion: values['minimumVersion'] as String?,
    reminderTime: values['reminderTime'] as String?,
    startDate: localDateFromKey(values['startDate']! as String),
    endDate: values['endDate'] == null
        ? null
        : localDateFromKey(values['endDate']! as String),
  );

  Future<int> _weeklyTargetForPeriod(Habit habit, DateTime day) async {
    final target = habit.draft.weeklyTarget!;
    final start = startOfWeek(day);
    final end = endOfWeek(day);
    final pauses = await _pausesFor([habit.id]);
    var eligibleDays = 0;
    for (
      var cursor = start;
      !cursor.isAfter(end);
      cursor = cursor.add(const Duration(days: 1))
    ) {
      if (_isWithinActiveRange(habit.draft, cursor) &&
          !_isPausedOn(pauses[habit.id] ?? const [], cursor)) {
        eligibleDays++;
      }
    }
    return target < eligibleDays ? target : eligibleDays;
  }

  void _ensureNotFuture(DateTime day) {
    if (_localDay(day).isAfter(_localDay(DateTime.now()))) {
      throw StateError('A future habit execution cannot be recorded.');
    }
  }

  DateTime _localDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _isWithinActiveRange(HabitDraft draft, DateTime day) {
    final local = _localDay(day);
    return !local.isBefore(_localDay(draft.startDate)) &&
        (draft.endDate == null || !local.isAfter(_localDay(draft.endDate!)));
  }

  Future<Map<String, List<_Pause>>> _pausesFor(
    Iterable<String> habitIds,
  ) async {
    final ids = habitIds.toList();
    if (ids.isEmpty) {
      return const {};
    }
    final rows = await _database.query(
      'habit_pauses',
      where: 'habit_id IN (${List.filled(ids.length, '?').join(', ')})',
      whereArgs: ids,
    );
    final result = <String, List<_Pause>>{};
    for (final row in rows) {
      final pause = _Pause(
        localDateFromKey(row['start_date']! as String),
        row['end_date'] == null
            ? null
            : localDateFromKey(row['end_date']! as String),
      );
      result.putIfAbsent(row['habit_id']! as String, () => []).add(pause);
    }
    return result;
  }

  bool _isPausedOn(List<_Pause> pauses, DateTime day) {
    final local = DateTime(day.year, day.month, day.day);
    return pauses.any(
      (pause) =>
          !local.isBefore(pause.start) &&
          (pause.end == null || !local.isAfter(pause.end!)),
    );
  }

  HabitDraft _normalizedDraft(HabitDraft draft) => HabitDraft(
    title: draft.title.trim(),
    purpose: _blankToNull(draft.purpose),
    category: _blankToNull(draft.category),
    icon: _blankToNull(draft.icon),
    color: _blankToNull(draft.color),
    frequency: draft.frequency,
    specificDays: draft.specificDays,
    weeklyTarget: draft.weeklyTarget,
    cueWhen: _blankToNull(draft.cueWhen),
    cueWhere: _blankToNull(draft.cueWhere),
    cueAction: _blankToNull(draft.cueAction),
    minimumVersion: _blankToNull(draft.minimumVersion),
    reminderTime: _blankToNull(draft.reminderTime),
    startDate: DateTime(
      draft.startDate.year,
      draft.startDate.month,
      draft.startDate.day,
    ),
    endDate: draft.endDate == null
        ? null
        : DateTime(
            draft.endDate!.year,
            draft.endDate!.month,
            draft.endDate!.day,
          ),
  );

  void _validate(HabitDraft draft) {
    if (draft.title.trim().isEmpty) {
      throw ArgumentError.value(
        draft.title,
        'title',
        'A habit name is required.',
      );
    }
    if (draft.frequency == HabitFrequency.specificDays &&
        draft.specificDays.isEmpty) {
      throw ArgumentError.value(
        draft.specificDays,
        'specificDays',
        'Specific-day habits need at least one day.',
      );
    }
    if (draft.frequency == HabitFrequency.specificDays &&
        draft.specificDays.any(
          (day) => day < DateTime.monday || day > DateTime.sunday,
        )) {
      throw ArgumentError.value(
        draft.specificDays,
        'specificDays',
        'Invalid weekday.',
      );
    }
    if (draft.frequency == HabitFrequency.weeklyTarget &&
        (draft.weeklyTarget == null ||
            draft.weeklyTarget! < 1 ||
            draft.weeklyTarget! > 7)) {
      throw ArgumentError.value(
        draft.weeklyTarget,
        'weeklyTarget',
        'Weekly target must be positive.',
      );
    }
    if (draft.endDate != null && draft.endDate!.isBefore(draft.startDate)) {
      throw ArgumentError.value(
        draft.endDate,
        'endDate',
        'End date precedes start date.',
      );
    }
  }

  Map<String, Object?> _habitValues(Habit habit) {
    final draft = habit.draft;
    return {
      'id': habit.id,
      'title': draft.title,
      'purpose': draft.purpose,
      'category': draft.category,
      'icon': draft.icon,
      'color': draft.color,
      'frequency': draft.frequency.value,
      'specific_days': draft.frequency == HabitFrequency.specificDays
          ? jsonEncode(draft.specificDays.toList()..sort())
          : null,
      'weekly_target': draft.frequency == HabitFrequency.weeklyTarget
          ? draft.weeklyTarget
          : null,
      'cue_when': draft.cueWhen,
      'cue_where': draft.cueWhere,
      'cue_action': draft.cueAction,
      'minimum_version': draft.minimumVersion,
      'reminder_time': draft.reminderTime,
      'start_date': localDateKey(draft.startDate),
      'end_date': draft.endDate == null ? null : localDateKey(draft.endDate!),
      'state': habit.state.value,
      'paused_at': habit.pausedAt == null
          ? null
          : utcTimestamp(habit.pausedAt!),
      'archived_at': habit.archivedAt == null
          ? null
          : utcTimestamp(habit.archivedAt!),
      'created_at': utcTimestamp(habit.createdAt),
      'updated_at': utcTimestamp(habit.updatedAt),
    };
  }

  Map<String, Object?> _configuration(HabitDraft draft) => {
    'title': draft.title,
    'purpose': draft.purpose,
    'category': draft.category,
    'icon': draft.icon,
    'color': draft.color,
    'frequency': draft.frequency.value,
    'specificDays': draft.specificDays.toList()..sort(),
    'weeklyTarget': draft.weeklyTarget,
    'cueWhen': draft.cueWhen,
    'cueWhere': draft.cueWhere,
    'cueAction': draft.cueAction,
    'minimumVersion': draft.minimumVersion,
    'reminderTime': draft.reminderTime,
    'startDate': localDateKey(draft.startDate),
    'endDate': draft.endDate == null ? null : localDateKey(draft.endDate!),
  };

  Habit _habitFromRow(Map<String, Object?> row) {
    final frequency = HabitFrequencyValue.fromValue(
      row['frequency']! as String,
    );
    final specificDays = row['specific_days'] == null
        ? <int>{}
        : (jsonDecode(row['specific_days']! as String) as List)
              .map((value) => value as int)
              .toSet();
    return Habit(
      id: row['id']! as String,
      draft: HabitDraft(
        title: row['title']! as String,
        purpose: row['purpose'] as String?,
        category: row['category'] as String?,
        icon: row['icon'] as String?,
        color: row['color'] as String?,
        frequency: frequency,
        specificDays: specificDays,
        weeklyTarget: row['weekly_target'] as int?,
        cueWhen: row['cue_when'] as String?,
        cueWhere: row['cue_where'] as String?,
        cueAction: row['cue_action'] as String?,
        minimumVersion: row['minimum_version'] as String?,
        reminderTime: row['reminder_time'] as String?,
        startDate: localDateFromKey(row['start_date']! as String),
        endDate: row['end_date'] == null
            ? null
            : localDateFromKey(row['end_date']! as String),
      ),
      state: HabitStateValue.fromValue(row['state']! as String),
      pausedAt: row['paused_at'] == null
          ? null
          : DateTime.parse(row['paused_at']! as String),
      archivedAt: row['archived_at'] == null
          ? null
          : DateTime.parse(row['archived_at']! as String),
      createdAt: DateTime.parse(row['created_at']! as String),
      updatedAt: DateTime.parse(row['updated_at']! as String),
    );
  }

  HabitExecution _executionFromRow(Map<String, Object?> row) => HabitExecution(
    id: row['id']! as String,
    habitId: row['habit_id']! as String,
    plannedDate: localDateFromKey(row['planned_date']! as String),
    state: HabitExecutionStateValue.fromValue(row['state']! as String),
    skipReason: row['skip_reason'] as String?,
    note: row['note'] as String?,
    recordedAt: DateTime.parse(row['recorded_at']! as String),
  );

  String? _blankToNull(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

class _Pause {
  const _Pause(this.start, this.end);

  final DateTime start;
  final DateTime? end;
}

class _ConfigurationRange {
  const _ConfigurationRange({
    required this.effectiveFrom,
    required this.effectiveUntil,
    required this.draft,
  });

  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final HabitDraft draft;
}
