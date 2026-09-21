import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_screen.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  testWidgets('insight summary appears before journal entries', (tester) async {
    final setup = await tester.runAsync(() async {
      final database = await openDatabaseConnection(
        factory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      final habitStore = HabitStore(database);
      final journalStore = JournalStore(database);
      final current = DateTime.now();
      final today = DateTime(current.year, current.month, current.day);
      final firstDay = today.subtract(const Duration(days: 4));
      final habit = await habitStore.create(
        HabitDraft(
          title: 'Membaca',
          frequency: HabitFrequency.daily,
          startDate: firstDay,
        ),
        now: firstDay,
      );
      for (var offset = 0; offset < 5; offset++) {
        await habitStore.complete(
          habit,
          date: firstDay.add(Duration(days: offset)),
        );
      }
      final entry = await journalStore.createDraft(
        type: JournalEntryType.free,
        now: today,
      );
      await journalStore.finish(
        entry.copyWith(title: 'Catatan uji', body: 'Isi'),
      );
      return (database: database, journalStore: journalStore);
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
        home: JournalScreen(
          store: setup.journalStore,
          wellbeingStore: WellbeingStore(setup.database),
          insightStore: InsightStore(setup.database),
        ),
      ),
    );
    final observation = find.textContaining('Membaca diselesaikan');
    await _pumpUntilFound(tester, observation);

    expect(find.text('Insight'), findsOneWidget);
    expect(find.text('Catatan uji'), findsOneWidget);
    final dismissButton = find.byTooltip('Sembunyikan insight');
    expect(dismissButton, findsOneWidget);
    final dismissSize = tester.getSize(dismissButton);
    expect(dismissSize.width, greaterThanOrEqualTo(44));
    expect(dismissSize.height, greaterThanOrEqualTo(44));
    expect(
      tester.getTopLeft(find.text('Insight')).dy,
      lessThan(tester.getTopLeft(find.text('Catatan uji')).dy),
    );

    await tester.tap(dismissButton);
    await _pumpUntilFound(tester, find.textContaining('Belum ada pola'));
    expect(observation, findsNothing);
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
