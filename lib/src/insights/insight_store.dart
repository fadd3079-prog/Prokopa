import 'package:prokopa/src/core/date/local_date.dart';
import 'package:sqflite/sqflite.dart';

class LocalInsight {
  const LocalInsight({
    required this.id,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.observation,
    required this.evidence,
    required this.createdAt,
    this.action,
    this.dismissedAt,
  });

  final String id;
  final String type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String observation;
  final String evidence;
  final String? action;
  final DateTime createdAt;
  final DateTime? dismissedAt;
}

class InsightStore {
  InsightStore(this._database);

  final Database _database;

  Future<List<LocalInsight>> refresh({DateTime? now}) async {
    final end = now ?? DateTime.now();
    final start = end.subtract(const Duration(days: 27));
    final startKey = localDateKey(start);
    final endKey = localDateKey(end);
    await _database.delete(
      'insights',
      where: 'period_start = ? AND period_end = ? AND dismissed_at IS NULL',
      whereArgs: [startKey, endKey],
    );
    final rows = await _database.rawQuery(
      '''
      SELECT habits.id, habits.title,
        SUM(CASE WHEN habit_executions.state = 'completed' THEN 1 ELSE 0 END) AS completed,
        COUNT(*) AS total
      FROM habit_executions
      INNER JOIN habits ON habits.id = habit_executions.habit_id
      WHERE habit_executions.planned_date BETWEEN ? AND ?
      GROUP BY habits.id, habits.title
      HAVING COUNT(*) >= 5
      ''',
      [startKey, endKey],
    );
    for (final row in rows) {
      final completed = row['completed']! as int;
      final total = row['total']! as int;
      final title = row['title']! as String;
      final observation =
          '$title diselesaikan $completed dari $total catatan pelaksanaan dalam 4 minggu terakhir.';
      await _upsert(
        id: 'habit_consistency:${row['id']}:$startKey:$endKey',
        type: 'habit_consistency',
        start: start,
        end: end,
        observation: observation,
        evidence: '$total catatan pelaksanaan lokal.',
        action: 'Pertimbangkan apakah cue saat ini masih membantu.',
      );
    }
    await _refreshMoodSummary(start, end);
    await _refreshSleepSummary(start, end);
    await _refreshRecoverySummary(start, end);
    await _refreshJournalSummary(start, end);
    await _refreshSleepHabitObservation(start, end);
    return list();
  }

  Future<void> _refreshMoodSummary(DateTime start, DateTime end) async {
    final rows = await _database.query(
      'mood_records',
      columns: ['valence'],
      where: 'record_date BETWEEN ? AND ?',
      whereArgs: [localDateKey(start), localDateKey(end)],
    );
    if (rows.length < 7) {
      return;
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
    final average = total / rows.length;
    await _upsert(
      id: 'mood_summary:${localDateKey(start)}:${localDateKey(end)}',
      type: 'mood_summary',
      start: start,
      end: end,
      observation:
          'Dalam 4 minggu terakhir, rata-rata suasana yang kamu catat adalah ${average.toStringAsFixed(1)} dari 5.',
      evidence: '${rows.length} catatan suasana lokal.',
      action: 'Pertimbangkan konteks yang ingin kamu catat lebih lanjut.',
    );
  }

  Future<void> _refreshSleepSummary(DateTime start, DateTime end) async {
    final rows = await _database.query(
      'sleep_records',
      columns: ['duration_minutes', 'quality'],
      where: 'wake_date BETWEEN ? AND ?',
      whereArgs: [localDateKey(start), localDateKey(end)],
    );
    if (rows.length < 7) {
      return;
    }
    final duration = rows.fold<int>(
      0,
      (sum, row) => sum + (row['duration_minutes']! as int),
    );
    final quality = rows.fold<int>(0, (sum, row) {
      return sum +
          switch (row['quality']! as String) {
            'poor' => 1,
            'fair' => 2,
            'good' => 3,
            'excellent' => 4,
            _ => 3,
          };
    });
    final averageDuration = duration ~/ rows.length;
    final averageQuality = quality / rows.length;
    await _upsert(
      id: 'sleep_summary:${localDateKey(start)}:${localDateKey(end)}',
      type: 'sleep_summary',
      start: start,
      end: end,
      observation:
          'Dalam 4 minggu terakhir, rata-rata tidur yang dicatat adalah ${averageDuration ~/ 60}j ${averageDuration % 60}m dengan kualitas ${averageQuality.toStringAsFixed(1)} dari 4.',
      evidence: '${rows.length} catatan tidur lokal.',
      action: 'Pertimbangkan waktu istirahat yang terasa realistis bagimu.',
    );
  }

  Future<void> _refreshRecoverySummary(DateTime start, DateTime end) async {
    final count = Sqflite.firstIntValue(
      await _database.rawQuery(
        '''
        SELECT COUNT(*) FROM habit_recoveries
        WHERE action = 'continue' AND recorded_at >= ? AND recorded_at < ?
        ''',
        [utcTimestamp(start), utcTimestamp(end.add(const Duration(days: 1)))],
      ),
    ) ??
        0;
    if (count < 2) {
      return;
    }
    await _upsert(
      id: 'recovery_summary:${localDateKey(start)}:${localDateKey(end)}',
      type: 'recovery_summary',
      start: start,
      end: end,
      observation:
          'Dalam 4 minggu terakhir, kamu kembali ke kebiasaan setelah jeda sebanyak $count kali.',
      evidence: '$count catatan pemulihan lokal.',
      action: 'Pertimbangkan langkah kecil yang membantumu kembali.',
    );
  }

  Future<void> _refreshJournalSummary(DateTime start, DateTime end) async {
    final count = Sqflite.firstIntValue(
      await _database.rawQuery(
        '''
        SELECT COUNT(*) FROM journal_entries
        WHERE status = 'saved' AND entry_date BETWEEN ? AND ?
        ''',
        [localDateKey(start), localDateKey(end)],
      ),
    ) ??
        0;
    if (count < 3) {
      return;
    }
    await _upsert(
      id: 'journal_summary:${localDateKey(start)}:${localDateKey(end)}',
      type: 'journal_summary',
      start: start,
      end: end,
      observation:
          'Dalam 4 minggu terakhir, kamu menyimpan $count catatan refleksi.',
      evidence: '$count jurnal tersimpan secara lokal.',
      action: 'Buka jurnal jika ada hal yang ingin kamu tinjau kembali.',
    );
  }

  Future<void> _refreshSleepHabitObservation(
    DateTime start,
    DateTime end,
  ) async {
    final sleep = await _database.query(
      'sleep_records',
      columns: ['wake_date', 'duration_minutes'],
      where: 'wake_date BETWEEN ? AND ?',
      whereArgs: [localDateKey(start), localDateKey(end)],
    );
    final executions = await _database.rawQuery(
      '''
      SELECT planned_date,
        SUM(CASE WHEN state = 'completed' THEN 1 ELSE 0 END) AS completed,
        COUNT(*) AS planned
      FROM habit_executions
      WHERE planned_date BETWEEN ? AND ?
      GROUP BY planned_date
      ''',
      [localDateKey(start), localDateKey(end)],
    );
    final executionByDay = {
      for (final row in executions)
        row['planned_date']! as String: (
          completed: row['completed']! as int,
          planned: row['planned']! as int,
        ),
    };
    var restedCompleted = 0;
    var restedPlanned = 0;
    var otherCompleted = 0;
    var otherPlanned = 0;
    for (final row in sleep) {
      final execution = executionByDay[row['wake_date']! as String];
      if (execution == null) {
        continue;
      }
      if ((row['duration_minutes']! as int) >= 420) {
        restedCompleted += execution.completed;
        restedPlanned += execution.planned;
      } else {
        otherCompleted += execution.completed;
        otherPlanned += execution.planned;
      }
    }
    if (restedPlanned < 3 || otherPlanned < 3) {
      return;
    }
    final restedRate = restedCompleted / restedPlanned;
    final otherRate = otherCompleted / otherPlanned;
    if ((restedRate - otherRate).abs() < 0.1) {
      return;
    }
    await _upsert(
      id: 'sleep_habit_observation:${localDateKey(start)}:${localDateKey(end)}',
      type: 'sleep_habit_observation',
      start: start,
      end: end,
      observation:
          'Dalam 4 minggu terakhir, kebiasaan terjadwal selesai ${(restedRate * 100).round()}% pada hari dengan tidur tercatat setidaknya 7 jam, dibanding ${(otherRate * 100).round()}% pada hari lain yang tercatat.',
      evidence:
          '$restedPlanned pelaksanaan pada hari dengan tidur setidaknya 7 jam dan $otherPlanned pelaksanaan pada hari lain.',
      action: 'Ini adalah pengamatan, bukan sebab-akibat. Pertimbangkan apakah pola ini berguna untukmu.',
    );
  }

  Future<void> _upsert({
    required String id,
    required String type,
    required DateTime start,
    required DateTime end,
    required String observation,
    required String evidence,
    required String action,
  }) async {
    final existing = await _database.query(
      'insights',
      columns: ['dismissed_at'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (existing.singleOrNull?['dismissed_at'] != null) {
      return;
    }
    await _database.insert('insights', {
      'id': id,
      'type': type,
      'period_start': localDateKey(start),
      'period_end': localDateKey(end),
      'observation': observation,
      'evidence': evidence,
      'action': action,
      'dismissed_at': null,
      'created_at': utcTimestamp(DateTime.now()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LocalInsight>> list({bool includeDismissed = false}) async {
    final rows = await _database.query(
      'insights',
      where: includeDismissed ? null : 'dismissed_at IS NULL',
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<void> dismiss(LocalInsight insight) {
    return _database.update(
      'insights',
      {'dismissed_at': utcTimestamp(DateTime.now())},
      where: 'id = ?',
      whereArgs: [insight.id],
    );
  }

  LocalInsight _fromRow(Map<String, Object?> row) => LocalInsight(
    id: row['id']! as String,
    type: row['type']! as String,
    periodStart: localDateFromKey(row['period_start']! as String),
    periodEnd: localDateFromKey(row['period_end']! as String),
    observation: row['observation']! as String,
    evidence: row['evidence']! as String,
    action: row['action'] as String?,
    dismissedAt: row['dismissed_at'] == null
        ? null
        : DateTime.parse(row['dismissed_at']! as String),
    createdAt: DateTime.parse(row['created_at']! as String),
  );
}
