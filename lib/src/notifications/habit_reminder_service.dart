import 'dart:convert';

import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:sqflite/sqflite.dart';

enum HabitReminderResult { scheduled, disabled, permissionUnavailable, failed }

class HabitReminderService {
  HabitReminderService(this._database, this._notifications);

  final Database _database;
  final LocalNotificationService _notifications;

  Future<HabitReminderResult> synchronize(Habit habit) async {
    return _synchronize(habit, requestPermission: true);
  }

  Future<void> rescheduleEnabled() async {
    if (!await _notifications.areNotificationsEnabled()) {
      return;
    }
    final preferences = await _database.query(
      'notification_preferences',
      columns: ['habit_id'],
      where: 'kind = ? AND enabled = 1 AND habit_id IS NOT NULL',
      whereArgs: ['habit'],
    );
    final ids = preferences.map((row) => row['habit_id']! as String).toSet();
    if (ids.isEmpty) {
      return;
    }
    final habits = await HabitStore(_database).list(includeArchived: true);
    for (final habit in habits.where((habit) => ids.contains(habit.id))) {
      await _synchronize(habit, requestPermission: false);
    }
  }

  Future<HabitReminderResult> _synchronize(
    Habit habit, {
    required bool requestPermission,
  }) async {
    if (!await cancel(habit)) {
      return HabitReminderResult.failed;
    }
    final time = habit.draft.reminderTime;
    if (time == null || habit.state != HabitState.active) {
      return HabitReminderResult.disabled;
    }
    if (requestPermission
        ? !await _notifications.requestPermission()
        : !await _notifications.areNotificationsEnabled()) {
      await _savePreference(habit, enabled: false);
      return HabitReminderResult.permissionUnavailable;
    }
    final delivery = await _deliveryTime(time);
    final values = delivery.split(':');
    final hour = int.parse(values[0]);
    final minute = int.parse(values[1]);
    try {
      final id = _notificationId(habit.id);
      switch (habit.draft.frequency) {
        case HabitFrequency.daily:
          await _notifications.scheduleDaily(
            id: id,
            hour: hour,
            minute: minute,
            title: 'Pengingat Prokopa',
            body: 'Waktunya kebiasaan yang kamu rencanakan.',
          );
        case HabitFrequency.specificDays:
          for (final weekday in habit.draft.specificDays) {
            await _notifications.scheduleWeekly(
              id: id + weekday,
              weekday: weekday,
              hour: hour,
              minute: minute,
              title: 'Pengingat Prokopa',
              body: 'Waktunya kebiasaan yang kamu rencanakan.',
            );
          }
        case HabitFrequency.weeklyTarget:
          for (final weekday in habit.draft.reminderDays) {
            await _notifications.scheduleWeekly(
              id: id + weekday,
              weekday: weekday,
              hour: hour,
              minute: minute,
              title: 'Pengingat Prokopa',
              body: 'Waktunya kebiasaan yang kamu rencanakan.',
            );
          }
      }
      await _savePreference(habit, enabled: true);
      return HabitReminderResult.scheduled;
    } catch (_) {
      await _savePreference(habit, enabled: false);
      return HabitReminderResult.failed;
    }
  }

  Future<bool> cancel(Habit habit) async {
    var cancelled = true;
    try {
      final id = _notificationId(habit.id);
      for (
        var weekday = DateTime.monday;
        weekday <= DateTime.sunday;
        weekday++
      ) {
        await _notifications.cancel(id + weekday);
      }
      await _notifications.cancel(id);
    } catch (_) {
      cancelled = false;
    }
    await _database.delete(
      'notification_preferences',
      where: 'id = ?',
      whereArgs: [_preferenceId(habit.id)],
    );
    return cancelled;
  }

  Future<void> _savePreference(Habit habit, {required bool enabled}) {
    return _database.insert('notification_preferences', {
      'id': _preferenceId(habit.id),
      'kind': 'habit',
      'habit_id': habit.id,
      'enabled': enabled ? 1 : 0,
      'time_of_day': habit.draft.reminderTime,
      'weekdays': habit.draft.reminderDays.isEmpty
          ? null
          : jsonEncode(habit.draft.reminderDays.toList()..sort()),
      'privacy_mode': 'generic',
      'updated_at': utcTimestamp(DateTime.now()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> _deliveryTime(String requestedTime) async {
    final rows = await _database.query(
      'application_settings',
      where: 'key IN (?, ?)',
      whereArgs: ['quiet_period_start', 'quiet_period_end'],
    );
    String? start;
    String? end;
    for (final row in rows) {
      if (row['key'] == 'quiet_period_start') {
        start = row['value'] as String;
      } else {
        end = row['value'] as String;
      }
    }
    if (start == null ||
        end == null ||
        !_inQuietPeriod(requestedTime, start, end)) {
      return requestedTime;
    }
    return end;
  }

  bool _inQuietPeriod(String value, String start, String end) {
    final minute = _minutes(value);
    final startMinute = _minutes(start);
    final endMinute = _minutes(end);
    if (startMinute == endMinute) {
      return false;
    }
    return startMinute < endMinute
        ? minute >= startMinute && minute < endMinute
        : minute >= startMinute || minute < endMinute;
  }

  int _minutes(String value) {
    final parts = value.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _preferenceId(String habitId) => 'habit:$habitId';

  int _notificationId(String habitId) {
    var value = 17;
    for (final codeUnit in habitId.codeUnits) {
      value = (value * 31 + codeUnit) & 0x3fffffff;
    }
    return value + 1000;
  }
}
