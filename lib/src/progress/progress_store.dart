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
    String? adjustment,
  }) async {
    final snapshot = await this.snapshot(start, end);
    final mood = await _moodSummary(start, end);
    final sleep = await _sleepSummary(start, end);
    final journalCount = await _journalCount(start, end);
    final habitSummary = await _habitSummary(start, end);
    final recoveries = await _recoveryCount(start, end);
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
        'moodCount': mood.$1,
        'averageMood': mood.$2,
        'sleepCount': sleep.$1,
        'averageSleepMinutes': sleep.$2,
        'journalCount': journalCount,
        'mostConsistentHabit': habitSummary.$1,
        'hardestHabit': habitSummary.$2,
        'recoveryCount': recoveries,
        'adjustment': _blank(adjustment),
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

  Future<(int, double?)> _moodSummary(DateTime start, DateTime end) async {
    final rows = await _database.query(
      'mood_records',
      columns: ['valence'],
      where: 'record_date BETWEEN ? AND ?',
      whereArgs: [localDateKey(start), localDateKey(end)],
    );
    if (rows.isEmpty) {
      return (0, null);
    }
    final total = rows.fold<int>(0, (sum, row) {
      return sum +
          switch (row['valence']! as String) {
            'very_low' => 1,
            'low' => 2,
            'neutral' => 3,
            'good' => 4,
            'very_good' => 5,
            _ => 3,
          };
    });
    return (rows.length, total / rows.length);
  }

  Future<int> _journalCount(DateTime start, DateTime end) async {
    return Sqflite.firstIntValue(
          await _database.rawQuery(
            "SELECT COUNT(*) FROM journal_entries WHERE status = 'saved' AND entry_date BETWEEN ? AND ?",
            [localDateKey(start), localDateKey(end)],
          ),
        ) ??
        0;
  }

  Future<(String?, String?)> _habitSummary(DateTime start, DateTime end) async {
    final rows = await _database.rawQuery(
      '''
      SELECT habits.title,
        SUM(CASE WHEN habit_executions.state = 'completed' THEN 1 ELSE 0 END) AS completed,
        COUNT(*) AS planned
      FROM habit_executions
      INNER JOIN habits ON habits.id = habit_executions.habit_id
      WHERE habit_executions.planned_date BETWEEN ? AND ?
      GROUP BY habits.id, habits.title
      HAVING COUNT(*) > 0
      ''',
      [localDateKey(start), localDateKey(end)],
    );
    if (rows.isEmpty) {
      return (null, null);
    }
    final ordered = [...rows]
      ..sort((left, right) {
        final leftRate =
            (left['completed']! as int) / (left['planned']! as int);
        final rightRate =
            (right['completed']! as int) / (right['planned']! as int);
        return rightRate.compareTo(leftRate);
      });
    return (
      ordered.first['title']! as String,
      ordered.last['title']! as String,
    );
  }

  Future<int> _recoveryCount(DateTime start, DateTime end) async {
    return Sqflite.firstIntValue(
          await _database.rawQuery(
            '''
            SELECT COUNT(*) FROM habit_recoveries
            WHERE action = 'continue' AND recorded_at >= ? AND recorded_at < ?
            ''',
            [
              utcTimestamp(start),
              utcTimestamp(end.add(const Duration(days: 1))),
            ],
          ),
        ) ??
        0;
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
