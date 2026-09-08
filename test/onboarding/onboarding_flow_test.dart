import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app.dart';
import 'package:prokopa/src/app/app_shell.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<Database> openTestDatabase(WidgetTester tester) async {
    final database = (await tester.runAsync(
      () => openDatabaseConnection(
        factory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      ),
    ))!;
    addTearDown(database.close);
    return database;
  }

  Future<void> completeOnboarding(WidgetTester tester) async {
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Rani');
    await tester.tap(find.text('Mulai'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pump();
  }

  testWidgets('fresh local database enters onboarding and reaches Today', (
    tester,
  ) async {
    final database = await openTestDatabase(tester);
    await tester.pumpWidget(
      ProkopaApp(database: database, enableFeatureScreens: false),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Ruang kecil untuk kebiasaan dan refleksi.'),
      findsOneWidget,
    );
    await completeOnboarding(tester);

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
  });

  testWidgets('completed onboarding does not reappear after an app rebuild', (
    tester,
  ) async {
    final database = await openTestDatabase(tester);
    await tester.pumpWidget(
      ProkopaApp(database: database, enableFeatureScreens: false),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();
    await completeOnboarding(tester);

    await tester.pumpWidget(
      ProkopaApp(database: database, enableFeatureScreens: false),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pump();

    expect(find.byType(AppShell), findsOneWidget);
    expect(
      find.text('Ruang kecil untuk kebiasaan dan refleksi.'),
      findsNothing,
    );
  });

  testWidgets('Profile edits local name avatar and appearance', (tester) async {
    final database = await openTestDatabase(tester);
    await tester.pumpWidget(
      ProkopaApp(database: database, enableFeatureScreens: false),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();
    await completeOnboarding(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Rani'), findsOneWidget);
    await tester.tap(find.text('Edit profil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Dita');
    await tester.tap(find.text('Aksen'));
    await tester.tap(find.text('Gelap'));
    await tester.tap(find.text('Simpan perubahan'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dita'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(AppShell))).brightness,
      Brightness.dark,
    );
  });
}
