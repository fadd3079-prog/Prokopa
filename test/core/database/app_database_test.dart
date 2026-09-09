import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/core/database/database_migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const testMigrations = <DatabaseMigration>[
  ...databaseMigrations,
  (
    version: 5,
    name: 'create_migration_probe',
    statements: ['CREATE TABLE migration_probe (id INTEGER PRIMARY KEY)'],
  ),
  (
    version: 6,
    name: 'extend_migration_probe',
    statements: ['ALTER TABLE migration_probe ADD COLUMN value TEXT'],
  ),
];

void main() {
  sqfliteFfiInit();

  Future<Database> openTestDatabase({
    String databasePath = inMemoryDatabasePath,
  }) async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    addTearDown(database.close);
    return database;
  }

  Future<String> temporaryDatabasePath() async {
    final directory = await Directory.systemTemp.createTemp(
      'prokopa_database_',
    );
    addTearDown(() => directory.delete(recursive: true));
    return path.join(directory.path, 'test.db');
  }

  Future<Database> openMigrationFixture(
    String databasePath,
    List<DatabaseMigration> migrations,
  ) async {
    final database = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: migrations.last.version,
        singleInstance: false,
        onCreate: (database, version) =>
            runDatabaseMigrations(database, 0, version, migrations),
        onUpgrade: (database, oldVersion, newVersion) =>
            runDatabaseMigrations(database, oldVersion, newVersion, migrations),
      ),
    );
    addTearDown(database.close);
    return database;
  }

  test('fresh database creates the current local schema', () async {
    final database = await openTestDatabase();

    expect(database.isOpen, isTrue);
    expect(
      await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      ),
      containsAll([
        {'name': 'application_settings'},
        {'name': 'habit_executions'},
        {'name': 'habit_recoveries'},
        {'name': 'habits'},
        {'name': 'journal_entries'},
        {'name': 'local_profiles'},
        {'name': 'schema_migrations'},
        {'name': 'sleep_records'},
      ]),
    );
    expect(
      await database.query('schema_migrations', columns: ['version', 'name']),
      [
        {'version': 1, 'name': 'create_schema_migrations'},
        {'version': 2, 'name': 'create_local_product_data'},
        {'version': 3, 'name': 'create_habit_recoveries'},
        {'version': 4, 'name': 'add_habit_reminder_days'},
      ],
    );
  });

  test('initial schema version is explicit and stored in SQLite', () async {
    final database = await openTestDatabase();

    expect(databaseSchemaVersion, 4);
    expect(databaseMigrations.last.version, databaseSchemaVersion);
    expect(await database.getVersion(), databaseSchemaVersion);
    expect(await database.rawQuery('PRAGMA user_version'), [
      {'user_version': databaseSchemaVersion},
    ]);
  });

  test('foreign key enforcement is enabled on each connection', () async {
    final database = await openTestDatabase();

    expect(await database.rawQuery('PRAGMA foreign_keys'), [
      {'foreign_keys': 1},
    ]);
  });

  test(
    'an existing version-zero database upgrades to the current schema',
    () async {
      final databasePath = await temporaryDatabasePath();
      final previous = await databaseFactoryFfi.openDatabase(databasePath);
      addTearDown(previous.close);
      await previous.execute(
        'CREATE TABLE preservation_probe (id INTEGER PRIMARY KEY)',
      );
      await previous.insert('preservation_probe', {'id': 7});
      expect(await previous.getVersion(), 0);
      await previous.close();

      final upgraded = await openTestDatabase(databasePath: databasePath);

      expect(await upgraded.getVersion(), databaseSchemaVersion);
      expect(await upgraded.query('preservation_probe'), [
        {'id': 7},
      ]);
      expect(await upgraded.query('schema_migrations'), hasLength(4));
    },
  );

  test('fresh migration sequence runs in ascending dependency order', () async {
    final database = await openMigrationFixture(
      inMemoryDatabasePath,
      testMigrations,
    );

    expect(await database.getVersion(), 6);
    await database.insert('migration_probe', {'id': 1, 'value': 'probe'});
    expect(await database.query('migration_probe'), [
      {'id': 1, 'value': 'probe'},
    ]);
    expect(
      await database.query(
        'schema_migrations',
        columns: ['version'],
        orderBy: 'version',
      ),
      [
        {'version': 1},
        {'version': 2},
        {'version': 3},
        {'version': 4},
        {'version': 5},
        {'version': 6},
      ],
    );
  });

  test(
    'older version upgrades only pending migrations and preserves rows',
    () async {
      final databasePath = await temporaryDatabasePath();
      final previous = await openMigrationFixture(
        databasePath,
        testMigrations.take(5).toList(),
      );
      await previous.insert('migration_probe', {'id': 7});
      final priorLedger = await previous.query(
        'schema_migrations',
        orderBy: 'version',
      );
      await previous.close();

      final upgraded = await openMigrationFixture(databasePath, testMigrations);

      expect(await upgraded.getVersion(), 6);
      expect(await upgraded.query('migration_probe'), [
        {'id': 7, 'value': null},
      ]);
      expect(
        await upgraded.query(
          'schema_migrations',
          where: 'version <= 5',
          orderBy: 'version',
        ),
        priorLedger,
      );
      expect(await upgraded.query('schema_migrations'), hasLength(6));
    },
  );

  test('out-of-order migrations are rejected before changing schema', () async {
    final database = await openTestDatabase();

    await expectLater(
      database.transaction(
        (transaction) => runDatabaseMigrations(transaction, 4, 6, [
          testMigrations[5],
          testMigrations[4],
        ]),
      ),
      throwsStateError,
    );
    expect(await database.query('schema_migrations'), hasLength(4));
    expect(await database.getVersion(), 4);
  });

  test('a missing migration is rejected before changing schema', () async {
    final database = await openTestDatabase();

    await expectLater(
      database.transaction(
        (transaction) =>
            runDatabaseMigrations(transaction, 4, 6, [testMigrations[4]]),
      ),
      throwsStateError,
    );
    expect(await database.query('schema_migrations'), hasLength(4));
    expect(
      await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE name = 'migration_probe'",
      ),
      isEmpty,
    );
  });

  test(
    'failed upgrade rolls back every pending migration and the version',
    () async {
      final databasePath = await temporaryDatabasePath();
      final previous = await openTestDatabase(databasePath: databasePath);
      final priorLedger = await previous.query('schema_migrations');
      await previous.close();

      await expectLater(
        openMigrationFixture(databasePath, [
          ...testMigrations.take(5),
          (
            version: 6,
            name: 'failing_migration',
            statements: [
              'INSERT INTO migration_probe (id) VALUES (1)',
              'INSERT INTO missing_table (id) VALUES (1)',
            ],
          ),
        ]),
        throwsA(
          isA<DatabaseMigrationException>()
              .having((error) => error.version, 'version', 6)
              .having((error) => error.name, 'name', 'failing_migration')
              .having(
                (error) => error.cause,
                'cause',
                isA<DatabaseException>(),
              ),
        ),
      );

      final reopened = await openTestDatabase(databasePath: databasePath);
      expect(await reopened.getVersion(), 4);
      expect(await reopened.query('schema_migrations'), priorLedger);
      expect(
        await reopened.rawQuery(
          "SELECT name FROM sqlite_master WHERE name = 'migration_probe'",
        ),
        isEmpty,
      );
    },
  );

  test(
    'failed initial migration leaves version zero and no partial schema',
    () async {
      final databasePath = await temporaryDatabasePath();

      await expectLater(
        openMigrationFixture(databasePath, [
          ...databaseMigrations,
          (
            version: 5,
            name: 'failing_initialization',
            statements: ['INSERT INTO missing_table (id) VALUES (1)'],
          ),
        ]),
        throwsA(isA<DatabaseMigrationException>()),
      );

      final raw = await databaseFactoryFfi.openDatabase(databasePath);
      addTearDown(raw.close);
      expect(await raw.getVersion(), 0);
      expect(
        await raw.rawQuery(
          "SELECT name FROM sqlite_master WHERE name = 'schema_migrations'",
        ),
        isEmpty,
      );
      await raw.close();
      final recovered = await openTestDatabase(databasePath: databasePath);
      expect(await recovered.getVersion(), databaseSchemaVersion);
    },
  );

  test('opening a newer schema refuses downgrade and preserves its data', () async {
    final databasePath = await temporaryDatabasePath();
    final newer = await openMigrationFixture(databasePath, testMigrations);
    await newer.insert('migration_probe', {'id': 7, 'value': 'preserved'});
    expect(await newer.getVersion(), 6);
    final originalSchema = await newer.rawQuery(
      'SELECT type, name, tbl_name, sql FROM sqlite_master ORDER BY type, name',
    );
    final originalLedger = await newer.query(
      'schema_migrations',
      orderBy: 'version',
    );
    await newer.close();

    await expectLater(
      openTestDatabase(databasePath: databasePath),
      throwsA(
        isA<UnsupportedDatabaseVersionException>()
            .having((error) => error.storedVersion, 'storedVersion', 6)
            .having(
              (error) => error.supportedVersion,
              'supportedVersion',
              databaseSchemaVersion,
            ),
      ),
    );

    expect(await File(databasePath).exists(), isTrue);
    final reopened = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    addTearDown(reopened.close);
    expect(await reopened.getVersion(), 6);
    expect(await reopened.query('migration_probe'), [
      {'id': 7, 'value': 'preserved'},
    ]);
    expect(
      await reopened.query('schema_migrations', orderBy: 'version'),
      originalLedger,
    );
    expect(
      await reopened.rawQuery(
        'SELECT type, name, tbl_name, sql FROM sqlite_master ORDER BY type, name',
      ),
      originalSchema,
    );
  });

  test('transaction commit persists both writes after reopening', () async {
    final databasePath = await temporaryDatabasePath();
    final database = await openTestDatabase(databasePath: databasePath);
    await database.execute(
      'CREATE TABLE transaction_probe (id INTEGER PRIMARY KEY)',
    );

    final result = await database.transaction((transaction) async {
      await transaction.insert('transaction_probe', {'id': 1});
      await transaction.insert('transaction_probe', {'id': 2});
      return 'committed';
    });
    expect(result, 'committed');
    await database.close();

    final reopened = await openTestDatabase(databasePath: databasePath);
    expect(await reopened.query('transaction_probe', orderBy: 'id'), [
      {'id': 1},
      {'id': 2},
    ]);
  });

  test('SQL failure rolls back earlier transaction writes', () async {
    final database = await openTestDatabase();
    await database.execute(
      'CREATE TABLE transaction_probe (id INTEGER PRIMARY KEY)',
    );

    await expectLater(
      database.transaction((transaction) async {
        await transaction.insert('transaction_probe', {'id': 1});
        await transaction.insert('transaction_probe', {'id': 1});
      }),
      throwsA(isA<DatabaseException>()),
    );

    expect(await database.query('transaction_probe'), isEmpty);
    await database.insert('transaction_probe', {'id': 2});
    expect(await database.query('transaction_probe'), [
      {'id': 2},
    ]);
  });

  test(
    'callback exception rolls back and propagates the original error',
    () async {
      final database = await openTestDatabase();
      await database.execute(
        'CREATE TABLE transaction_probe (id INTEGER PRIMARY KEY)',
      );
      final failure = StateError('Abort transaction');

      await expectLater(
        database.transaction((transaction) async {
          await transaction.insert('transaction_probe', {'id': 1});
          throw failure;
        }),
        throwsA(same(failure)),
      );
      expect(await database.query('transaction_probe'), isEmpty);
    },
  );

  test(
    'database closes cleanly and reopening does not rerun migrations',
    () async {
      final databasePath = await temporaryDatabasePath();
      final database = await openTestDatabase(databasePath: databasePath);
      final ledger = await database.query('schema_migrations');

      await database.close();
      expect(database.isOpen, isFalse);

      final reopened = await openTestDatabase(databasePath: databasePath);
      expect(reopened.isOpen, isTrue);
      expect(await reopened.getVersion(), databaseSchemaVersion);
      expect(await reopened.query('schema_migrations'), ledger);
    },
  );

  test('in-memory databases do not share schema or records', () async {
    final first = await openTestDatabase();
    final second = await openTestDatabase();
    await first.execute(
      'CREATE TABLE isolation_probe (id INTEGER PRIMARY KEY)',
    );
    await first.insert('isolation_probe', {'id': 1});

    expect(first.path, inMemoryDatabasePath);
    expect(second.path, inMemoryDatabasePath);
    expect(
      await second.rawQuery(
        "SELECT name FROM sqlite_master WHERE name = 'isolation_probe'",
      ),
      isEmpty,
    );
    expect(await second.query('schema_migrations'), hasLength(4));
  });

  test('database open failure propagates to the caller', () async {
    final databasePath = await temporaryDatabasePath();
    final blockingFile = File(databasePath);
    await blockingFile.writeAsString('not a directory');

    await expectLater(
      openTestDatabase(
        databasePath: path.join(blockingFile.path, 'blocked.db'),
      ),
      throwsA(anything),
    );
    expect(await blockingFile.readAsString(), 'not a directory');
  });
}
