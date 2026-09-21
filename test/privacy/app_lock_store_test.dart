import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<({Database database, AppLockStore store})> openStore() async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return (
      database: database,
      store: AppLockStore(
        database,
        secureStorage: const FlutterSecureStorage(),
      ),
    );
  }

  test('local PIN enables, verifies, and disables app lock', () async {
    final result = await openStore();

    await result.store.enablePin('1234', timeout: 5);

    expect(await result.store.isEnabled(), isTrue);
    expect(await result.store.timeoutMinutes(), 5);
    expect(await result.store.verifyPin('1234'), isTrue);
    expect(await result.store.verifyPin('4321'), isFalse);

    await result.store.disable();

    expect(await result.store.isEnabled(), isFalse);
    expect(await result.store.verifyPin('1234'), isFalse);
  });

  test('invalid local PIN is rejected before persistence', () async {
    final result = await openStore();

    await expectLater(
      result.store.enablePin('abc'),
      throwsA(isA<ArgumentError>()),
    );

    expect(await result.store.isEnabled(), isFalse);
  });

  test('delete all data clears lock state and secure PIN', () async {
    final result = await openStore();
    await result.store.enablePin('1234');

    await result.store.deleteAllData();

    expect(await result.store.isEnabled(), isFalse);
    expect(await result.store.verifyPin('1234'), isFalse);
    expect(await result.database.query('application_settings'), isEmpty);
  });
}
