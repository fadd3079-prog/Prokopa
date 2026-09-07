import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/features/dashboard/providers/dashboard_providers.dart';
import 'package:habitflow/core/utils/date_utils.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/theme/app_colors.dart';
import 'package:habitflow/features/profile/providers/profile_providers.dart';
import 'package:habitflow/core/services/gamification_service.dart';

IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'book':
      return Icons.book;
    case 'water_drop':
      return Icons.water_drop;
    case 'directions_run':
      return Icons.directions_run;
    case 'self_improvement':
      return Icons.self_improvement;
    case 'monitor_heart':
      return Icons.monitor_heart;
    case 'fitness_center':
    default:
      return Icons.fitness_center;
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    final sleepAsync = ref.watch(dashboardSleepProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppDateUtils.getGreeting(),
              style: const TextStyle(fontSize: 16),
            ),
            ref.watch(userProfileProvider).when(
              data: (user) => Text(
                user.name.isNotEmpty ? user.name : 'User',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              loading: () => const Text('User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              error: (err, stack) => const Text('User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressRing(statsAsync),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildSleepSummary(sleepAsync),
              const SizedBox(height: 24),
              const Text(
                "Today's Habits",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildHabitsList(todayHabitsAsync, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing(AsyncValue statsAsync) {
    return statsAsync.when(
      data: (stats) {
        double progress = stats.totalHabits > 0
            ? stats.completedToday / stats.totalHabits
            : 0;
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${stats.completedToday}/${stats.totalHabits}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Completed'),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('Error: $e'),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionCard(context, 'New Habit', Icons.add, '/habits/new'),
        _buildActionCard(
          context,
          'Write Journal',
          Icons.edit_note,
          '/journal/new',
        ),
        _buildActionCard(context, 'Log Sleep', Icons.bedtime, '/sleep/log'),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Column(
              children: [
                Icon(icon, size: 32, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepSummary(AsyncValue<SleepRecord?> sleepAsync) {
    return sleepAsync.when(
      data: (sleep) {
        if (sleep == null) return const SizedBox.shrink();
        final hours = sleep.duration.floor();
        final minutes = ((sleep.duration - hours) * 60).round();
        final durationStr = minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.nightlight_round,
              color: AppColors.primary,
            ),
            title: const Text('Last Night'),
            subtitle: Text('Slept: $durationStr (Quality: ${sleep.quality}/5)'),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildHabitsList(AsyncValue<List<Habit>> habitsAsync, WidgetRef ref) {
    final completionsAsync = ref.watch(todayCompletionsProvider);
    final completedHabitIds = completionsAsync.when(
      data: (logs) => logs.where((l) => l.completed).map((l) => l.habitId).toSet(),
      loading: () => <int>{},
      error: (err, stack) => <int>{},
    );

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return const Center(child: Text('No habits today!'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            final isCompleted = completedHabitIds.contains(habit.id);
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(habit.color),
                  child: Icon(_getIconData(habit.icon), color: Colors.white),
                ),
                title: Text(
                  habit.title,
                  style: TextStyle(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(habit.category),
                trailing: Checkbox(
                  value: isCompleted,
                  onChanged: (val) async {
                    final db = ref.read(databaseProvider);
                    await db.habitDao.toggleCompletion(habit.id, DateTime.now());
                    await ref.read(gamificationServiceProvider).evaluateHabitAchievements();
                    ref.invalidate(dashboardStatsProvider);
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('Error loading habits: $e'),
    );
  }
}
