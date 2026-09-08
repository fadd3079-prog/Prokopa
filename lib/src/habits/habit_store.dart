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
      final records = byHabit[habit.id] ?? const [];
      final completed = records
          .where((record) => record.state == HabitExecutionState.completed)
          .length;
      if (habit.draft.frequency == HabitFrequency.weeklyTarget) {
        if (completed < habit.draft.weeklyTarget!) {
          result.add(
            TodayHabit(
              habit: habit,
              completedThisWeek: completed,
              weeklyTarget: habit.draft.weeklyTarget,
            ),
          );
        }
        continue;
      }
      if (!isHabitScheduledOn(habit.draft, day)) {
        continue;
      }
      final execution = records
          .where((record) => localDateKey(record.plannedDate) == key)
          .firstOrNull;
      result.add(
        TodayHabit(
          habit: habit,
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
    if (!await _canRecord(habit, day)) {
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
        'habit_id': habit.id,
        'planned_date': key,
        'state': HabitExecutionState.completed.value,
        'skip_reason': null,
        'note': null,
        'configuration_snapshot': jsonEncode(_configuration(habit.draft)),
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
    if (habit.draft.frequency == HabitFrequency.weeklyTarget ||
        !await _canRecord(habit, day)) {
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
        'habit_id': habit.id,
        'planned_date': key,
        'state': HabitExecutionState.skipped.value,
        'skip_reason': reason,
        'note': null,
        'configuration_snapshot': jsonEncode(_configuration(habit.draft)),
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
    if (habit.draft.frequency == HabitFrequency.weeklyTarget) {
      return 0;
    }
    final day = now ?? DateTime.now();
    final records = await history(habit);
    final byDate = {
      for (final record in records) localDateKey(record.plannedDate): record,
    };
    final pauses = await _pausesFor([habit.id]);
    var cursor = DateTime(day.year, day.month, day.day);
    var total = 0;
    while (!cursor.isBefore(habit.draft.startDate)) {
      if (_isPausedOn(pauses[habit.id] ?? const [], cursor) ||
          !isHabitScheduledOn(habit.draft, cursor)) {
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
    await _database.transaction((transaction) async {
      for (final habit in habits) {
        if (habit.draft.frequency == HabitFrequency.weeklyTarget) {
          continue;
        }
        var cursor = DateTime(
          habit.draft.startDate.year,
          habit.draft.startDate.month,
          habit.draft.startDate.day,
        );
        final archiveDate = habit.archivedAt == null
            ? null
            : DateTime(
                habit.archivedAt!.toLocal().year,
                habit.archivedAt!.toLocal().month,
                habit.archivedAt!.toLocal().day,
              ).subtract(const Duration(days: 1));
        final end = [
          yesterday,
          ?habit.draft.endDate,
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
          if (isHabitScheduledOn(habit.draft, cursor) &&
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
              'configuration_snapshot': jsonEncode(_configuration(habit.draft)),
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
    return habit.draft.frequency == HabitFrequency.weeklyTarget ||
        isHabitScheduledOn(habit.draft, day);
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
        (draft.weeklyTarget == null || draft.weeklyTarget! < 1)) {
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
