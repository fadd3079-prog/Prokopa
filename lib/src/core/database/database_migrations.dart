import 'package:sqflite/sqflite.dart';

typedef DatabaseMigration = ({
  int version,
  String name,
  List<String> statements,
});

const databaseSchemaVersion = 1;

const databaseMigrations = <DatabaseMigration>[
  (
    version: 1,
    name: 'create_schema_migrations',
    statements: [
      '''
      CREATE TABLE schema_migrations (
        version INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      ''',
    ],
  ),
];

Future<void> runDatabaseMigrations(
  DatabaseExecutor database,
  int oldVersion,
  int newVersion,
  List<DatabaseMigration> migrations,
) async {
  if (newVersion < oldVersion) {
    throw StateError('Database migrations are forward-only.');
  }

  final pending = migrations
      .where((step) => step.version > oldVersion && step.version <= newVersion)
      .toList();
  var expectedVersion = oldVersion + 1;
  for (final migration in pending) {
    if (migration.version != expectedVersion) {
      throw StateError('Expected migration $expectedVersion.');
    }
    expectedVersion++;
  }
  if (expectedVersion != newVersion + 1) {
    throw StateError('Missing migration $expectedVersion.');
  }

  for (final migration in pending) {
    try {
      for (final statement in migration.statements) {
        await database.execute(statement);
      }
      await database.insert('schema_migrations', {
        'version': migration.version,
        'name': migration.name,
      });
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        DatabaseMigrationException(migration.version, migration.name, error),
        stackTrace,
      );
    }
  }
}

class DatabaseMigrationException implements Exception {
  const DatabaseMigrationException(this.version, this.name, this.cause);

  final int version;
  final String name;
  final Object cause;

  @override
  String toString() => 'Migration $version ($name) failed: $cause';
}
