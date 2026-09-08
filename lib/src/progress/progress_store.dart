import 'dart:convert';

import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/core/identifiers/local_id.dart';
import 'package:sqflite/sqflite.dart';

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.start,
    required this.end,
    required this.completed,
    required this.skipped,
    required this.missed,
    required this.repetitions,
    required this.calendar,
  });

  final DateTime start;
  final DateTime end;
  final int completed;
  final int skipped;
  final int missed;
  final int repetitions;
  final Map<String, String> calendar;

  int get planned => completed + skipped + missed;

  double? get completionRate => planned == 0 ? null : completed / planned;
}

class ReviewRecord {
  const ReviewRecord({
    required this.id,
    required this.type,
    required this.start,
    required this.end,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    this.reflection,
  });

  final String id;
  final String type;
  final DateTime start;
  final DateTime end;
  final String? reflection;
  final Map<String, Object?> data;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ProgressStore {
  ProgressStore(this._database);

  final Database _database;

  Future<ProgressSnapshot> snapshot(DateTime start, DateTime end) async {
    final rows = await _database.query(
      'habit_executions',
      where: 'planned_date BETWEEN ? AND ?',
      whereArgs: [localDateKey(start), localDateKey(end)],
    );
    var completed = 0;
    var skipped = 0;
    var missed = 0;
    final calendar = <String, String>{};
    for (final row in rows) {
      final state = row['state']! as String;
      switch (state) {
        case 'completed':
          completed++;
        case 'skipped':
          skipped++;
        case 'missed':
          missed++;
      }
      final key = row['planned_date']! as String;
      final existing = calendar[key];
      calendar[key] = _combinedCalendarState(existing, state);
    }
    return ProgressSnapshot(
      start: start,
      end: end,
      completed: completed,
      skipped: skipped,
      missed: missed,
      repetitions: completed,
      calendar: calendar,
    );
  }

  Future<ReviewRecord> saveReview({
    required String type,
    required DateTime start,
    required DateTime end,
    String? reflection,
  }) async {
    final snapshot = await this.snapshot(start, end);
    final mood = await _moodSummary(start, end);
    final sleep = await _sleepSummary(start, end);
    final now = DateTime.now();
    final prior = await loadReview(type: type, start: start);
    final record = ReviewRecord(
      id: prior?.id ?? newLocalId(),
      type: type,
      start: start,
      end: end,
      reflection: _blank(reflection),
      data: {
        'completed': snapshot.completed,
        'planned': snapshot.planned,
        'skipped': snapshot.skipped,
        'missed': snapshot.missed,
        'moodCount': mood,
        'sleepCount': sleep.$1,
        'averageSleepMinutes': sleep.$2,
      },
      createdAt: prior?.createdAt ?? now,
      updatedAt: now,
    );
    await _database.insert('reviews', {
      'id': record.id,
      'type': type,
      'period_start': localDateKey(start),
      'period_end': localDateKey(end),
      'reflection': record.reflection,
      'data': jsonEncode(record.data),
      'created_at': utcTimestamp(record.createdAt),
      'updated_at': utcTimestamp(record.updatedAt),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return record;
  }

  Future<ReviewRecord?> loadReview({
    required String type,
    required DateTime start,
  }) async {
    final rows = await _database.query(
      'reviews',
      where: 'type = ? AND period_start = ?',
      whereArgs: [type, localDateKey(start)],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.single;
    return ReviewRecord(
      id: row['id']! as String,
      type: row['type']! as String,
      start: localDateFromKey(row['period_start']! as String),
      end: localDateFromKey(row['period_end']! as String),
      reflection: row['reflection'] as String?,
      data: (jsonDecode(row['data']! as String) as Map).cast<String, Object?>(),
      createdAt: DateTime.parse(row['created_at']! as String),
      updatedAt: DateTime.parse(row['updated_at']! as String),
    );
  }

  Future<(int, double?)> _sleepSummary(DateTime start, DateTime end) async {
    final rows = await _database.query(
      'sleep_records',
      columns: ['duration_minutes'],
      where: 'wake_date BETWEEN ? AND ?',
      whereArgs: [localDateKey(start), localDateKey(end)],
    );
    if (rows.isEmpty) {
      return (0, null);
    }
    final total = rows.fold<int>(
      0,
      (sum, row) => sum + (row['duration_minutes']! as int),
    );
    return (rows.length, total / rows.length);
  }

  Future<int> _moodSummary(DateTime start, DateTime end) async {
    final value = Sqflite.firstIntValue(
      await _database.rawQuery(
        'SELECT COUNT(*) FROM mood_records WHERE record_date BETWEEN ? AND ?',
        [localDateKey(start), localDateKey(end)],
      ),
    );
    return value ?? 0;
  }

  String _combinedCalendarState(String? current, String next) {
    if (current == null || current == next) {
      return next;
    }
    if (current == 'completed' || next == 'completed') {
      return 'partial';
    }
    if (current == 'missed' || next == 'missed') {
      return 'missed';
    }
    return 'skipped';
  }

  String? _blank(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
