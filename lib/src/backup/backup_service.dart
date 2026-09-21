import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:prokopa/src/core/database/database_migrations.dart';
import 'package:sqflite/sqflite.dart';

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupPreview {
  const BackupPreview({
    required this.createdAt,
    required this.appVersion,
    required this.schemaVersion,
    required this.counts,
  });

  final DateTime createdAt;
  final String appVersion;
  final int schemaVersion;
  final Map<String, int> counts;
}

class BackupService {
  BackupService(this._database);

  static const formatVersion = 1;
  static const appVersion = '0.1.0';
  static const _minimumSupportedBackupSchemaVersion = 2;

  static const _tables = [
    ('application_settings', 'key'),
    ('local_profiles', 'id'),
    ('habits', 'id'),
    ('habit_configuration_history', 'id'),
    ('habit_pauses', 'id'),
    ('habit_executions', 'id'),
    ('habit_recoveries', 'id'),
    ('journal_entries', 'id'),
    ('mood_records', 'id'),
    ('sleep_records', 'id'),
    ('reviews', 'id'),
    ('insights', 'id'),
    ('achievements', 'key'),
    ('notification_preferences', 'id'),
  ];

  final Database _database;

  Future<String> export() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in _tables) {
      final rows = await _database.query(table.$1, orderBy: table.$2);
      tables[table.$1] = table.$1 == 'application_settings'
          ? rows
                .where(
                  (row) => !(row['key']! as String).startsWith('app_lock_'),
                )
                .toList()
          : rows;
    }
    final payload = {'tables': tables};
    final encodedPayload = jsonEncode(payload);
    final envelope = {
      'formatVersion': formatVersion,
      'appVersion': appVersion,
      'schemaVersion': databaseSchemaVersion,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'deviceTimezone': DateTime.now().timeZoneName,
      'checksum': sha256.convert(utf8.encode(encodedPayload)).toString(),
      'payload': payload,
    };
    return jsonEncode(envelope);
  }

  BackupPreview preview(String source) {
    final envelope = _validatedEnvelope(source);
    final tables =
        (envelope['payload']! as Map<String, Object?>)['tables']!
            as Map<String, List<Map<String, Object?>>>;
    return BackupPreview(
      createdAt: DateTime.parse(envelope['createdAt']! as String),
      appVersion: envelope['appVersion']! as String,
      schemaVersion: envelope['schemaVersion']! as int,
      counts: {
        for (final table in _tables)
          table.$1: (tables[table.$1] ?? const []).length,
      },
    );
  }

  Future<void> replace(String source) async {
    final envelope = _validatedEnvelope(source);
    final tables =
        (envelope['payload']! as Map<String, Object?>)['tables']!
            as Map<String, List<Map<String, Object?>>>;
    await _database.transaction((transaction) async {
      for (final table in _tables.reversed) {
        await transaction.delete(table.$1);
      }
      for (final table in _tables) {
        final rows = tables[table.$1] ?? const [];
        for (final row in rows) {
          await transaction.insert(table.$1, row);
        }
      }
      final references = await transaction.rawQuery('PRAGMA foreign_key_check');
      if (references.isNotEmpty) {
        throw const BackupFormatException('Relasi data backup tidak valid.');
      }
    });
  }

  Map<String, Object?> _validatedEnvelope(String source) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } catch (_) {
      throw const BackupFormatException('File backup tidak dapat dibaca.');
    }
    if (decoded is! Map) {
      throw const BackupFormatException('Format backup tidak valid.');
    }
    final format = decoded['formatVersion'];
    final app = decoded['appVersion'];
    final schema = decoded['schemaVersion'];
    final createdAt = decoded['createdAt'];
    final checksum = decoded['checksum'];
    final payload = decoded['payload'];
    if (format != formatVersion ||
        (app != null && app is! String) ||
        schema is! int ||
        schema < _minimumSupportedBackupSchemaVersion ||
        schema > databaseSchemaVersion ||
        createdAt is! String ||
        checksum is! String ||
        payload is! Map ||
        payload['tables'] is! Map) {
      throw const BackupFormatException('Versi backup tidak didukung.');
    }
    try {
      DateTime.parse(createdAt);
    } catch (_) {
      throw const BackupFormatException('Tanggal backup tidak valid.');
    }
    final tables = <String, List<Map<String, Object?>>>{};
    final rawTables = payload['tables'] as Map;
    var missingRecoveries = false;
    for (final table in _tables) {
      final rawRows = rawTables[table.$1];
      if (rawRows == null && schema < 3 && table.$1 == 'habit_recoveries') {
        missingRecoveries = true;
        continue;
      }
      if (rawRows is! List) {
        throw BackupFormatException('Data ${table.$1} tidak valid.');
      }
      final rows = <Map<String, Object?>>[];
      for (final rawRow in rawRows) {
        if (rawRow is! Map) {
          throw BackupFormatException('Data ${table.$1} tidak valid.');
        }
        rows.add(rawRow.cast<String, Object?>());
      }
      tables[table.$1] = rows;
    }
    final canonicalPayload = {'tables': tables};
    final actual = sha256
        .convert(utf8.encode(jsonEncode(canonicalPayload)))
        .toString();
    if (actual != checksum) {
      throw const BackupFormatException('Pemeriksaan integritas backup gagal.');
    }
    if (missingRecoveries) {
      tables['habit_recoveries'] = [];
    }
    tables['application_settings']!.removeWhere(
      (row) => (row['key']! as String).startsWith('app_lock_'),
    );
    return {
      'formatVersion': format,
      'appVersion': app ?? 'Versi sebelumnya',
      'schemaVersion': schema,
      'createdAt': createdAt,
      'payload': {'tables': tables},
    };
  }
}
