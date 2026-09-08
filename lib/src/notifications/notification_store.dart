import 'package:prokopa/src/core/date/local_date.dart';
import 'package:sqflite/sqflite.dart';

class NotificationPreference {
  const NotificationPreference({
    required this.id,
    required this.kind,
    required this.enabled,
    this.timeOfDay,
    this.privacyMode = 'generic',
  });

  final String id;
  final String kind;
  final bool enabled;
  final String? timeOfDay;
  final String privacyMode;
}

class NotificationStore {
  NotificationStore(this._database);

  final Database _database;

  Future<NotificationPreference> load(String id) async {
    final rows = await _database.query(
      'notification_preferences',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return NotificationPreference(id: id, kind: id, enabled: false);
    }
    final row = rows.single;
    return NotificationPreference(
      id: row['id']! as String,
      kind: row['kind']! as String,
      enabled: row['enabled'] == 1,
      timeOfDay: row['time_of_day'] as String?,
      privacyMode: row['privacy_mode']! as String,
    );
  }

  Future<void> save(NotificationPreference preference) {
    return _database.insert('notification_preferences', {
      'id': preference.id,
      'kind': preference.kind,
      'habit_id': null,
      'enabled': preference.enabled ? 1 : 0,
      'time_of_day': preference.timeOfDay,
      'weekdays': null,
      'privacy_mode': preference.privacyMode,
      'updated_at': utcTimestamp(DateTime.now()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<(String?, String?)> quietPeriod() async {
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
    return (start, end);
  }

  Future<void> saveQuietPeriod({String? start, String? end}) async {
    final now = utcTimestamp(DateTime.now());
    await _database.transaction((transaction) async {
      for (final setting in [
        ('quiet_period_start', start),
        ('quiet_period_end', end),
      ]) {
        if (setting.$2 == null) {
          await transaction.delete(
            'application_settings',
            where: 'key = ?',
            whereArgs: [setting.$1],
          );
        } else {
          await transaction.insert('application_settings', {
            'key': setting.$1,
            'value': setting.$2,
            'updated_at': now,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }
}
