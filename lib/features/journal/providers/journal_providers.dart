import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';

final allJournalsProvider = StreamProvider<List<Journal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.journalDao.watchAllJournals();
});

final journalDetailProvider = FutureProvider.family<Journal?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.journalDao.getJournal(id);
});

final journalSearchProvider = FutureProvider.family<List<Journal>, String>((
  ref,
  query,
) {
  final db = ref.watch(databaseProvider);
  return db.journalDao.searchJournals(query);
});

final averageMoodProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);
  final journals = await db.journalDao.getRecentJournals(30);
  if (journals.isEmpty) return 0.0;

  double totalMood = 0;
  for (var journal in journals) {
    totalMood += journal.mood;
  }
  return totalMood / journals.length;
});
