import 'package:path/path.dart' as path;
import 'package:prokopa/src/core/database/database_migrations.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openAppDatabase() async {
  final directory = await getDatabasesPath();
  return openDatabaseConnection(
    factory: databaseFactory,
    databasePath: path.join(directory, 'prokopa.db'),
  );
}

Future<Database> openDatabaseConnection({
  required DatabaseFactory factory,
  required String databasePath,
}) {
  return factory.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      version: databaseSchemaVersion,
      singleInstance: false,
      onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
      onCreate: (database, version) => runDatabaseMigrations(
        database,
        0,
        version,
        databaseMigrations,
      ),
      onUpgrade: (database, oldVersion, newVersion) => runDatabaseMigrations(
        database,
        oldVersion,
        newVersion,
        databaseMigrations,
      ),
      onDowngrade: (_, storedVersion, supportedVersion) {
        throw UnsupportedDatabaseVersionException(
          storedVersion,
          supportedVersion,
        );
      },
    ),
  );
}

class UnsupportedDatabaseVersionException implements Exception {
  const UnsupportedDatabaseVersionException(
    this.storedVersion,
    this.supportedVersion,
  );

  final int storedVersion;
  final int supportedVersion;

  @override
  String toString() =>
      'Database schema version $storedVersion is newer than the supported '
      'version $supportedVersion.';
}
