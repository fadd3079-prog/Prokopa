import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/achievements_table.dart';

part 'achievement_dao.g.dart';

/// Data access object for achievement/gamification operations.
@DriftAccessor(tables: [Achievements])
class AchievementDao extends DatabaseAccessor<AppDatabase>
    with _$AchievementDaoMixin {
  AchievementDao(super.db);

  /// Get all achievements.
  Future<List<Achievement>> getAllAchievements() {
    return select(achievements).get();
  }

  /// Watch all achievements reactively.
  Stream<List<Achievement>> watchAllAchievements() {
    return select(achievements).watch();
  }

  /// Get only unlocked achievements.
  Future<List<Achievement>> getUnlockedAchievements() {
    return (select(achievements)..where((t) => t.unlocked.equals(true))).get();
  }

  /// Unlock an achievement by ID.
  Future<void> unlockAchievement(int id) {
    return (update(achievements)..where((t) => t.id.equals(id))).write(
      AchievementsCompanion(
        unlocked: const Value(true),
        unlockDate: Value(DateTime.now()),
      ),
    );
  }

  /// Get total XP from unlocked achievements.
  Future<int> getTotalXp() async {
    final unlocked = await getUnlockedAchievements();
    return unlocked.fold<int>(0, (sum, a) => sum + a.xpReward);
  }

  /// Calculate level from XP (every 500 XP = 1 level).
  Future<int> getLevel() async {
    final xp = await getTotalXp();
    return (xp / 500).floor() + 1;
  }

  /// Check if a specific achievement is unlocked.
  Future<bool> isUnlocked(String name) async {
    final results = await (select(achievements)
          ..where((t) => t.name.equals(name) & t.unlocked.equals(true)))
        .get();
    return results.isNotEmpty;
  }
}

