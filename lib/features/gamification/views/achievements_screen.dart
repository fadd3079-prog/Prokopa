import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/gamification/providers/gamification_providers.dart';
import 'package:habitflow/features/gamification/widgets/achievement_card.dart';
import 'package:habitflow/features/gamification/widgets/xp_progress_bar.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final totalXpAsync = ref.watch(totalXpProvider);
    final levelAsync = ref.watch(userLevelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  levelAsync.when(
                    data: (level) => totalXpAsync.when(
                      data: (xp) => XpProgressBar(level: level, currentXp: xp),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => const Text('Error loading XP'),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => const Text('Error loading level'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Badges',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          achievementsAsync.when(
            data: (achievements) {
              if (achievements.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No achievements available.'),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final achievement = achievements[index];
                    // Assuming Achievement has these fields
                    return AchievementCard(
                      name: achievement.name,
                      description: achievement.description,
                      iconEmoji: achievement.icon,
                      isUnlocked: achievement.unlocked,
                      unlockedAt: achievement.unlockDate,
                    );
                  }, childCount: achievements.length),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) =>
                SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
    );
  }
}
