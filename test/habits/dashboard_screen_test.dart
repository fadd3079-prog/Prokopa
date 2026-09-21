import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/habits/dashboard_screen.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  testWidgets('dashboard shows real daily completion and habit streak', (
    tester,
  ) async {
    final setup = await tester.runAsync(() async {
      final database = await openDatabaseConnection(
        factory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      final store = HabitStore(database);
      final current = DateTime.now();
      final today = DateTime(current.year, current.month, current.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final habit = await store.create(
        HabitDraft(
          title: 'Membaca',
          frequency: HabitFrequency.daily,
          startDate: yesterday,
        ),
        now: yesterday,
      );
      await store.complete(habit, date: yesterday);
      await store.complete(habit, date: today);
      return (database: database, store: store);
    });
    if (setup == null) {
      fail('Database pengujian tidak dapat disiapkan.');
    }
    addTearDown(() => tester.runAsync(setup.database.close));
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: DashboardScreen(store: setup.store),
      ),
    );
    await _pumpUntilFound(tester, find.text('1 dari 1 selesai hari ini'));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Streak kebiasaan'), findsOneWidget);
    expect(find.text('Membaca'), findsOneWidget);
    expect(find.text('2 hari'), findsOneWidget);
  });
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
