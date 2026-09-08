import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/core/identifiers/local_id.dart';
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
      [localDateKey(start), localDateKey(end)],
    );
    for (final row in rows) {
      final completed = row['completed']! as int;
      final total = row['total']! as int;
      final title = row['title']! as String;
      final observation =
          '$title diselesaikan $completed dari $total catatan pelaksanaan dalam 4 minggu terakhir.';
      await _database.insert('insights', {
        'id': newLocalId(),
        'type': 'habit_consistency',
        'period_start': localDateKey(start),
        'period_end': localDateKey(end),
        'observation': observation,
        'evidence': '$total catatan pelaksanaan lokal.',
        'action': 'Pertimbangkan apakah cue saat ini masih membantu.',
        'dismissed_at': null,
        'created_at': utcTimestamp(DateTime.now()),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    return list();
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
