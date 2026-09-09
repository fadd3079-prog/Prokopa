import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/core/database/database_migrations.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<({Database database, BackupService backup})> openBackup() async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return (database: database, backup: BackupService(database));
  }

  Future<void> addData(Database database) async {
    final profile = ProfileStore(database);
    await profile.completeOnboarding(
      LocalProfile(
        id: 'local',
        name: 'Rani',
        avatar: 'primary',
        appearance: AppAppearance.system,
        createdAt: DateTime(2026, 9, 9),
      ),
    );
    final habits = HabitStore(database);
    final habit = await habits.create(
      HabitDraft(
        title: 'Membaca',
        frequency: HabitFrequency.daily,
        startDate: DateTime(2026, 9, 9),
      ),
    );
    await habits.complete(habit, date: DateTime(2026, 9, 9));
  }

  test('local backup round-trips canonical records', () async {
    final result = await openBackup();
    await addData(result.database);
    final source = await result.backup.export();
    final preview = result.backup.preview(source);

    expect(preview.counts['local_profiles'], 1);
    expect(preview.counts['habits'], 1);
    expect(preview.counts['habit_executions'], 1);
    expect(preview.appVersion, BackupService.appVersion);
    expect(preview.schemaVersion, databaseSchemaVersion);

    await result.database.delete('habits');
    await result.database.delete('local_profiles');
    await result.backup.replace(source);

    expect(await result.database.query('local_profiles'), hasLength(1));
    expect(await result.database.query('habits'), hasLength(1));
    expect(await result.database.query('habit_executions'), hasLength(1));
  });

  test(
    'corrupted and unsupported backups are rejected before replacement',
    () async {
      final result = await openBackup();
      await addData(result.database);
      final source = await result.backup.export();
      final corrupt = jsonDecode(source) as Map<String, dynamic>;
      corrupt['checksum'] = 'invalid';

      expect(
        () => result.backup.preview(jsonEncode(corrupt)),
        throwsA(isA<BackupFormatException>()),
      );
      corrupt['formatVersion'] = 99;
      expect(
        () => result.backup.preview(jsonEncode(corrupt)),
        throwsA(isA<BackupFormatException>()),
      );
      expect(await result.database.query('habits'), hasLength(1));
    },
  );

  test('backup excludes app lock state and preserves unrelated settings', () async {
    final result = await openBackup();
    await result.database.insert('application_settings', {
      'key': 'app_lock_enabled',
      'value': 'true',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    await result.database.insert('application_settings', {
      'key': 'quiet_hours_start',
      'value': '22:00',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    final exported = jsonDecode(await result.backup.export()) as Map;
    final tables =
        ((exported['payload'] as Map)['tables'] as Map<String, dynamic>);
    final settings = tables['application_settings'] as List<dynamic>;

    expect(
      settings.map((row) => (row as Map)['key']),
      ['quiet_hours_start'],
    );

    final source = await result.backup.export();
    await result.database.delete('application_settings');
    await result.backup.replace(source);
    final restored = await result.database.query('application_settings');
    expect(restored.single['key'], 'quiet_hours_start');
  });

  test('supported older backup schema is normalized before replacement', () async {
    final result = await openBackup();
    await addData(result.database);
    final envelope =
        jsonDecode(await result.backup.export()) as Map<String, dynamic>;
    final payload = envelope['payload'] as Map<String, dynamic>;
    final tables = payload['tables'] as Map<String, dynamic>;
    envelope['schemaVersion'] = 2;
    tables.remove('habit_recoveries');
    envelope['checksum'] = sha256
        .convert(utf8.encode(jsonEncode(payload)))
        .toString();

    final preview = result.backup.preview(jsonEncode(envelope));
    await result.database.delete('habits');
    await result.backup.replace(jsonEncode(envelope));

    expect(preview.schemaVersion, 2);
    expect(await result.database.query('habits'), hasLength(1));
    expect(await result.database.query('habit_recoveries'), isEmpty);
  });

  test(
    'duplicate records fail transactionally without replacing local data',
    () async {
      final result = await openBackup();
      await addData(result.database);
      final source = await result.backup.export();
      final envelope = jsonDecode(source) as Map<String, dynamic>;
      final payload = envelope['payload'] as Map<String, dynamic>;
      final tables = payload['tables'] as Map<String, dynamic>;
      final profiles = tables['local_profiles'] as List<dynamic>;
      profiles.add(Map<String, dynamic>.from(profiles.single as Map));
      envelope['checksum'] = sha256
          .convert(utf8.encode(jsonEncode(payload)))
          .toString();

      await expectLater(
        result.backup.replace(jsonEncode(envelope)),
        throwsA(isA<DatabaseException>()),
      );
      expect(await result.database.query('local_profiles'), hasLength(1));
      expect(await result.database.query('habits'), hasLength(1));
    },
  );
}
