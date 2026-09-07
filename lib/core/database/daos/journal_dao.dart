import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/journals_table.dart';

part 'journal_dao.g.dart';

/// Data access object for journal entry operations.
@DriftAccessor(tables: [Journals])
class JournalDao extends DatabaseAccessor<AppDatabase> with _$JournalDaoMixin {
  JournalDao(super.db);

  /// Get all journal entries, newest first.
  Future<List<Journal>> getAllJournals() {
    return (select(journals)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  }

  /// Watch all journal entries reactively.
  Stream<List<Journal>> watchAllJournals() {
    return (select(journals)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
  }

  /// Get a single journal entry by ID.
  Future<Journal> getJournal(int id) {
    return (select(journals)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Get journal entry for a specific date and type.
  Future<Journal?> getJournalForDate(DateTime date, String type) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final results = await (select(journals)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end) &
              t.type.equals(type)))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Create a new journal entry.
  Future<int> createJournal(JournalsCompanion journal) {
    return into(journals).insert(journal);
  }

  /// Update an existing journal entry.
  Future<bool> updateJournal(int id, JournalsCompanion companion) {
    return (update(journals)..where((t) => t.id.equals(id)))
        .write(companion)
        .then((rows) => rows > 0);
  }

  /// Delete a journal entry.
  Future<void> deleteJournal(int id) {
    return (delete(journals)..where((t) => t.id.equals(id))).go();
  }

  /// Search journals by content.
  Future<List<Journal>> searchJournals(String query) {
    return (select(journals)
          ..where((t) => t.content.like('%$query%'))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Get journal entries for a specific mood score.
  Future<List<Journal>> getJournalsByMood(int mood) {
    return (select(journals)
          ..where((t) => t.mood.equals(mood))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Get total journal count.
  Future<int> getJournalCount() async {
    final count = countAll();
    final query = selectOnly(journals)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get journal entries from last N days.
  Future<List<Journal>> getRecentJournals(int days) {
    final start = DateTime.now().subtract(Duration(days: days));
    return (select(journals)
          ..where((t) => t.date.isBiggerOrEqualValue(start))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Get average mood score over last N days.
  Future<double> getAverageMood(int days) async {
    final entries = await getRecentJournals(days);
    if (entries.isEmpty) return 3.0;
    final total = entries.fold<int>(0, (sum, e) => sum + e.mood);
    return total / entries.length;
  }
}

