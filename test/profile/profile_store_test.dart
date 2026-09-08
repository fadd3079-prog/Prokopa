import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<ProfileStore> openStore() async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return ProfileStore(database);
  }

  LocalProfile profile({
    String name = 'Rani',
    String avatar = 'primary',
    AppAppearance appearance = AppAppearance.system,
  }) {
    return LocalProfile(
      id: 'local',
      name: name,
      avatar: avatar,
      appearance: appearance,
      createdAt: DateTime(2026, 9, 9),
      focus: 'Kesehatan',
    );
  }

  test('first-run state remains incomplete without a local profile', () async {
    final store = await openStore();

    expect(await store.load(), isNull);
    expect(await store.isOnboardingComplete(), isFalse);
  });

  test('onboarding persists a local profile and completion together', () async {
    final store = await openStore();

    await store.completeOnboarding(profile());

    expect(await store.isOnboardingComplete(), isTrue);
    final loaded = await store.load();
    expect(loaded?.name, 'Rani');
    expect(loaded?.focus, 'Kesehatan');
    expect(loaded?.appearance, AppAppearance.system);
  });

  test('local profile updates persist name avatar and appearance', () async {
    final store = await openStore();
    await store.completeOnboarding(profile());

    await store.save(
      profile(name: 'Dita', avatar: 'tertiary', appearance: AppAppearance.dark),
    );

    final loaded = await store.load();
    expect(loaded?.name, 'Dita');
    expect(loaded?.avatar, 'tertiary');
    expect(loaded?.appearance, AppAppearance.dark);
    expect(await store.isOnboardingComplete(), isTrue);
  });

  test('invalid profile persistence never completes onboarding', () async {
    final store = await openStore();

    await expectLater(
      store.completeOnboarding(profile(name: '  ')),
      throwsArgumentError,
    );

    expect(await store.load(), isNull);
    expect(await store.isOnboardingComplete(), isFalse);
  });
}
