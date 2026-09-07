import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sleep_records_table.dart';

part 'sleep_dao.g.dart';

/// Data access object for sleep record operations.
@DriftAccessor(tables: [SleepRecords])
class SleepDao extends DatabaseAccessor<AppDatabase> with _$SleepDaoMixin {
  SleepDao(super.db);

  /// Get all sleep records, newest first.
  Future<List<SleepRecord>> getAllRecords() {
    return (select(sleepRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Watch all sleep records reactively.
  Stream<List<SleepRecord>> watchAllRecords() {
    return (select(sleepRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Get the most recent sleep record.
  Future<SleepRecord?> getLatestRecord() async {
    final results = await (select(sleepRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Get sleep record for a specific date.
  Future<SleepRecord?> getRecordForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final results = await (select(sleepRecords)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Create a new sleep record.
  Future<int> createRecord(SleepRecordsCompanion record) {
    return into(sleepRecords).insert(record);
  }

  /// Update an existing sleep record.
  Future<bool> updateRecord(int id, SleepRecordsCompanion companion) {
    return (update(sleepRecords)..where((t) => t.id.equals(id)))
        .write(companion)
        .then((rows) => rows > 0);
  }

  /// Delete a sleep record.
  Future<void> deleteRecord(int id) {
    return (delete(sleepRecords)..where((t) => t.id.equals(id))).go();
  }

  /// Get records for last N days.
  Future<List<SleepRecord>> getRecentRecords(int days) {
    final start = DateTime.now().subtract(Duration(days: days));
    return (select(sleepRecords)
          ..where((t) => t.date.isBiggerOrEqualValue(start))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Calculate average sleep duration over last N days.
  Future<double> getAverageDuration(int days) async {
    final records = await getRecentRecords(days);
    if (records.isEmpty) return 0.0;
    final total = records.fold<double>(0, (sum, r) => sum + r.duration);
    return total / records.length;
  }

  /// Calculate average sleep quality over last N days.
  Future<double> getAverageQuality(int days) async {
    final records = await getRecentRecords(days);
    if (records.isEmpty) return 0.0;
    final total = records.fold<int>(0, (sum, r) => sum + r.quality);
    return total / records.length;
  }

  /// Get sleep consistency score (percentage of days with sleep logged).
  Future<double> getSleepConsistency(int days) async {
    final records = await getRecentRecords(days);
    return records.isEmpty ? 0.0 : records.length / days;
  }
}

