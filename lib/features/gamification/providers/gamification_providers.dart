import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/database/app_database.dart';

final achievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.achievementDao.watchAllAchievements();
});

final totalXpProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.achievementDao.getTotalXp();
});

final userLevelProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.achievementDao.getLevel();
});
