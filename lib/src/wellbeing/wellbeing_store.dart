import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/core/identifiers/local_id.dart';
import 'package:prokopa/src/wellbeing/mood_record.dart';
import 'package:sqflite/sqflite.dart';

enum SleepQuality { poor, fair, good, excellent }

extension SleepQualityValue on SleepQuality {
  String get value => switch (this) {
    SleepQuality.poor => 'poor',
    SleepQuality.fair => 'fair',
    SleepQuality.good => 'good',
    SleepQuality.excellent => 'excellent',
  };

  static SleepQuality fromValue(String value) => switch (value) {
    'poor' => SleepQuality.poor,
    'fair' => SleepQuality.fair,
    'excellent' => SleepQuality.excellent,
    _ => SleepQuality.good,
  };
}

class SleepRecord {
  const SleepRecord({
    required this.id,
    required this.start,
    required this.end,
    required this.quality,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final SleepQuality quality;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get durationMinutes => end.difference(start).inMinutes;
}

class WellbeingStore {
  WellbeingStore(this._database);

  final Database _database;

  Future<MoodRecord> saveMood({
    required MoodValence valence,
    MoodEnergy? energy,
    MoodEmotion? emotion,
    MoodContext? context,
    String? note,
    DateTime? recordedAt,
  }) async {
    final time = recordedAt ?? DateTime.now();
    final record = MoodRecord(
      id: newLocalId(),
      recordedAt: time,
      valence: valence,
      energy: energy,
      emotion: emotion,
      context: context,
      note: _blank(note),
    );
    await _database.insert('mood_records', {
      'id': record.id,
      'recorded_at': utcTimestamp(record.recordedAt),
      'record_date': localDateKey(record.recordedAt),
      'valence': record.valence.value,
      'energy': record.energy?.name,
      'emotion': record.emotion?.name,
      'context': record.context?.name,
      'note': record.note,
    });
    return record;
  }

  Future<List<MoodRecord>> listMood({DateTime? from, DateTime? to}) async {
    final predicates = <String>[];
    final arguments = <Object?>[];
    if (from != null) {
      predicates.add('record_date >= ?');
      arguments.add(localDateKey(from));
    }
    if (to != null) {
      predicates.add('record_date <= ?');
      arguments.add(localDateKey(to));
    }
    final rows = await _database.query(
      'mood_records',
      where: predicates.isEmpty ? null : predicates.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'recorded_at DESC',
    );
    return rows.map(_moodFromRow).toList();
  }

  Future<SleepRecord> saveSleep({
    String? id,
    required DateTime start,
    required DateTime end,
    required SleepQuality quality,
    String? note,
  }) async {
    final duration = end.difference(start).inMinutes;
    if (duration <= 0 || duration > 1440) {
      throw ArgumentError.value(
        end,
        'end',
        'Masukkan durasi tidur yang valid.',
      );
    }
    final now = DateTime.now();
    final record = SleepRecord(
      id: id ?? newLocalId(),
      start: start,
      end: end,
      quality: quality,
      note: _blank(note),
      createdAt: now,
      updatedAt: now,
    );
    await _database.insert('sleep_records', {
      'id': record.id,
      'sleep_start': utcTimestamp(record.start),
      'sleep_end': utcTimestamp(record.end),
      'wake_date': localDateKey(record.end),
      'duration_minutes': duration,
      'quality': record.quality.value,
      'note': record.note,
      'created_at': utcTimestamp(record.createdAt),
      'updated_at': utcTimestamp(record.updatedAt),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return record;
  }

  Future<List<SleepRecord>> listSleep({DateTime? from, DateTime? to}) async {
    final predicates = <String>[];
    final arguments = <Object?>[];
    if (from != null) {
      predicates.add('wake_date >= ?');
      arguments.add(localDateKey(from));
    }
    if (to != null) {
      predicates.add('wake_date <= ?');
      arguments.add(localDateKey(to));
    }
    final rows = await _database.query(
      'sleep_records',
      where: predicates.isEmpty ? null : predicates.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'sleep_end DESC',
    );
    return rows.map(_sleepFromRow).toList();
  }

  Future<void> deleteSleep(String id) {
    return _database.delete('sleep_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<double?> averageSleepDuration({DateTime? from, DateTime? to}) async {
    final records = await listSleep(from: from, to: to);
    if (records.isEmpty) {
      return null;
    }
    return records
            .map((record) => record.durationMinutes)
            .reduce((a, b) => a + b) /
        records.length;
  }

  MoodRecord _moodFromRow(Map<String, Object?> row) => MoodRecord(
    id: row['id']! as String,
    recordedAt: DateTime.parse(row['recorded_at']! as String),
    valence: MoodValue.fromValue(row['valence']! as String),
    energy: row['energy'] == null
        ? null
        : MoodEnergy.values.byName(row['energy']! as String),
    emotion: row['emotion'] == null
        ? null
        : MoodEmotion.values.byName(row['emotion']! as String),
    context: row['context'] == null
        ? null
        : MoodContext.values.byName(row['context']! as String),
    note: row['note'] as String?,
  );

  SleepRecord _sleepFromRow(Map<String, Object?> row) => SleepRecord(
    id: row['id']! as String,
    start: DateTime.parse(row['sleep_start']! as String).toLocal(),
    end: DateTime.parse(row['sleep_end']! as String).toLocal(),
    quality: SleepQualityValue.fromValue(row['quality']! as String),
    note: row['note'] as String?,
    createdAt: DateTime.parse(row['created_at']! as String),
    updatedAt: DateTime.parse(row['updated_at']! as String),
  );

  String? _blank(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
