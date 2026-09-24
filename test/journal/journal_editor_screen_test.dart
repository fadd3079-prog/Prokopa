import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/core/database/app_database.dart';
import 'package:prokopa/src/journal/journal_editor_screen.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  testWidgets('dispose queues latest edit behind an in-flight autosave', (
    tester,
  ) async {
    final database = await openDatabaseConnection(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final firstSave = Completer<void>();
    final store = _ControlledJournalStore(database, firstSave.future);
    final timestamp = DateTime(2026, 9, 24, 10);
    final entry = JournalEntry(
      id: 'journal-1',
      date: timestamp,
      type: JournalEntryType.free,
      body: '',
      tags: const [],
      status: JournalEntryStatus.draft,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: JournalEditorScreen(store: store, entry: entry),
      ),
    );
    await tester.enterText(find.byType(TextField).at(1), 'Versi pertama');
    await tester.pump(const Duration(milliseconds: 600));
    expect(store.saved, hasLength(1));

    await tester.enterText(find.byType(TextField).at(1), 'Versi terakhir');
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    firstSave.complete();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(store.saved, hasLength(2));
    expect(store.saved.last.body, 'Versi terakhir');
  });
}

final class _ControlledJournalStore extends JournalStore {
  _ControlledJournalStore(super.database, this._firstSave);

  final Future<void> _firstSave;
  final List<JournalEntry> saved = [];

  @override
  Future<void> save(JournalEntry entry) async {
    saved.add(entry);
    if (saved.length == 1) {
      await _firstSave;
    }
  }
}
