import 'dart:convert';

import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/core/identifiers/local_id.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:sqflite/sqflite.dart';

class JournalStore {
  JournalStore(this._database);

  final Database _database;

  Future<JournalEntry> createDraft({
    required JournalEntryType type,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    final entry = JournalEntry(
      id: newLocalId(),
      date: timestamp,
      type: type,
      body: '',
      tags: const [],
      status: JournalEntryStatus.draft,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    await save(entry);
    return entry;
  }

  Future<void> save(JournalEntry entry) {
    return _database.insert(
      'journal_entries',
      _values(entry.copyWith(updatedAt: DateTime.now())),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> finish(JournalEntry entry) {
    return save(entry.copyWith(status: JournalEntryStatus.saved));
  }

  Future<JournalEntry?> load(String id) async {
    final rows = await _database.query(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.single);
  }

  Future<List<JournalEntryPreview>> list({
    String query = '',
    JournalEntryType? type,
    String? mood,
    String? tag,
    int limit = 40,
    int offset = 0,
  }) async {
    final predicates = <String>[];
    final arguments = <Object?>[];
    if (query.trim().isNotEmpty) {
      predicates.add('(title LIKE ? OR body LIKE ? OR tags LIKE ?)');
      final value = '%${query.trim()}%';
      arguments.addAll([value, value, value]);
    }
    if (type != null) {
      predicates.add('type = ?');
      arguments.add(type.value);
    }
    if (mood != null) {
      predicates.add('mood = ?');
      arguments.add(mood);
    }
    if (tag != null) {
      predicates.add('tags LIKE ?');
      arguments.add('%${jsonEncode(tag)}%');
    }
    final rows = await _database.query(
      'journal_entries',
      columns: const [
        'id',
        'entry_date',
        'type',
        'title',
        'substr(body, 1, 240) AS body_preview',
        'mood',
        'status',
        'updated_at',
      ],
      where: predicates.isEmpty ? null : predicates.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'updated_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_previewFromRow).toList();
  }

  Future<void> delete(String id) {
    return _database.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, Object?> _values(JournalEntry entry) => {
    'id': entry.id,
    'entry_date': localDateKey(entry.date),
    'type': entry.type.value,
    'title': _blank(entry.title),
    'body': entry.body,
    'mood': _blank(entry.mood),
    'energy': _blank(entry.energy),
    'tags': jsonEncode(entry.tags),
    'guided_responses': entry.guidedResponses.isEmpty
        ? null
        : jsonEncode(entry.guidedResponses),
    'prompt_index': entry.promptIndex,
    'status': entry.status.value,
    'created_at': utcTimestamp(entry.createdAt),
    'updated_at': utcTimestamp(entry.updatedAt),
  };

  JournalEntry _fromRow(Map<String, Object?> row) => JournalEntry(
    id: row['id']! as String,
    date: localDateFromKey(row['entry_date']! as String),
    type: JournalEntryTypeValue.fromValue(row['type']! as String),
    title: row['title'] as String?,
    body: row['body']! as String,
    mood: row['mood'] as String?,
    energy: row['energy'] as String?,
    tags: (jsonDecode(row['tags']! as String) as List).cast<String>(),
    guidedResponses: row['guided_responses'] == null
        ? const {}
        : (jsonDecode(row['guided_responses']! as String) as Map)
              .cast<String, String>(),
    promptIndex: row['prompt_index']! as int,
    status: JournalEntryStatusValue.fromValue(row['status']! as String),
    createdAt: DateTime.parse(row['created_at']! as String),
    updatedAt: DateTime.parse(row['updated_at']! as String),
  );

  JournalEntryPreview _previewFromRow(Map<String, Object?> row) =>
      JournalEntryPreview(
        id: row['id']! as String,
        date: localDateFromKey(row['entry_date']! as String),
        type: JournalEntryTypeValue.fromValue(row['type']! as String),
        title: row['title'] as String?,
        bodyPreview: row['body_preview']! as String,
        mood: row['mood'] as String?,
        status: JournalEntryStatusValue.fromValue(row['status']! as String),
        updatedAt: DateTime.parse(row['updated_at']! as String),
      );

  String? _blank(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
