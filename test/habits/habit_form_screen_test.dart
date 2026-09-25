import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app_date_controller.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/habits/today_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<({HabitStore store, Database database})> openStore() async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return (store: HabitStore(database), database: database);
  }

  testWidgets('habit form only asks for name and accent color', (tester) async {
    final result = await openStore();

    await tester.pumpWidget(
      MaterialApp(home: TodayScreen(store: result.store)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Nama kebiasaan'), findsOneWidget);
    expect(find.text('Warna aksen'), findsOneWidget);
    expect(find.text('Frekuensi'), findsNothing);
    expect(find.text('Mulai'), findsNothing);
    expect(find.text('Pengingat lokal'), findsNothing);
  });

  testWidgets('new habit keeps selected date and chosen accent color', (
    tester,
  ) async {
    final result = await openStore();
    final selectedDate = DateTime(2026, 9, 20);

    await tester.pumpWidget(
      MaterialApp(
        home: TodayScreen(
          store: result.store,
          dateController: AppDateController(initialDate: selectedDate),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Olahraga');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hijau').last);
    await tester.tap(find.text('Simpan kebiasaan'));
    await tester.pumpAndSettle();

    final habit = (await result.store.list()).single;
    expect(habit.draft.title, 'Olahraga');
    expect(habit.draft.color, '#2E7D32');
    expect(habit.draft.frequency, HabitFrequency.daily);
    expect(habit.draft.startDate, selectedDate);
  });

  testWidgets('manage all habits action is absent', (tester) async {
    final result = await openStore();

    await tester.pumpWidget(
      MaterialApp(home: TodayScreen(store: result.store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kelola semua kebiasaan'), findsNothing);
  });
}
