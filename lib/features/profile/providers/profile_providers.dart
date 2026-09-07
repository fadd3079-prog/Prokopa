import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/providers/core_providers.dart';

class UserStats {
  final int habitsCreated;
  final int journalEntries;
  final int sleepLogs;
  final int daysActive;
  final int totalXp;
  final int level;

  UserStats({
    required this.habitsCreated,
    required this.journalEntries,
    required this.sleepLogs,
    required this.daysActive,
    required this.totalXp,
    required this.level,
  });
}

final userProfileProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.userDao.watchUser();
});

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final db = ref.watch(databaseProvider);

  final habitsCreated = (await db.habitDao.getActiveHabits()).length;
  final journalEntries = await db.journalDao.getJournalCount();
  final sleepLogs = (await db.sleepDao.getAllRecords()).length;

  final user = await db.userDao.getUser();
  final daysActive = (DateTime.now().difference(user.createdAt).inDays + 1)
      .clamp(1, 99999);

  final totalXp = await db.achievementDao.getTotalXp();
  final level = await db.achievementDao.getLevel();

  return UserStats(
    habitsCreated: habitsCreated,
    journalEntries: journalEntries,
    sleepLogs: sleepLogs,
    daysActive: daysActive,
    totalXp: totalXp,
    level: level,
  );
});
