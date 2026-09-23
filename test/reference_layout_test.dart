import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/habits/today_screen.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/journal/journal_screen.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_screen.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:prokopa/src/progress/progress_screen.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  testWidgets('Habits fits a compact viewport with large text', (tester) async {
    final database = await _openDatabase(tester);
    _configureCompactLargeText(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: TodayScreen(store: HabitStore(database)),
      ),
    );
    await _pumpUntilFound(tester, find.text('Habits'));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Tambah kebiasaan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Buat kebiasaan'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
    final manageHabits = find.text('Kelola semua kebiasaan');
    await tester.scrollUntilVisible(
      manageHabits,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(manageHabits);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Kelola kebiasaan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Journal fits a compact viewport with large text', (
    tester,
  ) async {
    final database = await _openDatabase(tester);
    _configureCompactLargeText(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: JournalScreen(
          store: JournalStore(database),
          wellbeingStore: WellbeingStore(database),
          insightStore: InsightStore(database),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('Bagaimana perasaan Anda?'));
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Catatan Hari Ini'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Catatan Hari Ini'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Statistics fits a compact viewport with large text', (
    tester,
  ) async {
    final database = await _openDatabase(tester);
    _configureCompactLargeText(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ProgressScreen(
          store: ProgressStore(database),
          wellbeingStore: WellbeingStore(database),
          habitStore: HabitStore(database),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('Stats'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile fits a compact viewport with large text', (
    tester,
  ) async {
    final database = await _openDatabase(tester);
    _configureCompactLargeText(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: SettingsScreen(
          profile: LocalProfile(
            id: 'local-profile',
            name: 'Rani',
            avatar: 'primary',
            appearance: AppAppearance.dark,
            createdAt: DateTime(2026),
          ),
          store: ProfileStore(database),
          onChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<Database> _openDatabase(WidgetTester tester) async {
  final database = await tester.runAsync(
    () => openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    ),
  );
  if (database == null) {
    fail('Database pengujian tidak dapat disiapkan.');
  }
  addTearDown(() => tester.runAsync(database.close));
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
  return database;
}

void _configureCompactLargeText(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(320, 700);
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Widget tidak selesai dimuat.');
}
