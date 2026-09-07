import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/features/habit/providers/habit_providers.dart';
import 'package:habitflow/core/providers/core_providers.dart';

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

class HabitDetailScreen extends ConsumerWidget {
  final int habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitDetailProvider(habitId));
    final streakAsync = ref.watch(habitStreakProvider(habitId));
    final completionRateAsync = ref.watch(habitCompletionRateProvider(habitId));
    final logsAsync = ref.watch(habitLogsProvider(habitId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/habits/$habitId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: habitAsync.when(
        data: (habit) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(habit.color),
                      child: Icon(
                        _getIconData(habit.icon),
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            habit.category,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (habit.description.isNotEmpty)
                  Text(habit.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  'Frequency: ${habit.frequency}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),

                streakAsync.when(
                  data: (streak) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Current Streak', '${streak.current} 🔥'),
                      _buildStatCard('Longest Streak', '${streak.longest} 🏆'),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => const Text('Error loading stats'),
                ),

                const SizedBox(height: 24),
                completionRateAsync.when(
                  data: (rate) => Text(
                    '30-Day Completion Rate: ${(rate * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) =>
                      const Text('Error loading completion rate'),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Last 30 Days History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                logsAsync.when(
                  data: (logs) => _buildHistoryGrid(logs, habit.color),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const Text('Error loading history'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryGrid(List<dynamic> logs, int habitColor) {
    final now = DateTime.now();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final targetDate = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 29 - index));
        final completed = logs.any((log) =>
            log.date.year == targetDate.year &&
            log.date.month == targetDate.month &&
            log.date.day == targetDate.day &&
            log.completed == true);
        return Container(
          decoration: BoxDecoration(
            color: completed ? Color(habitColor) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final db = ref.read(databaseProvider);
              db.habitDao.deleteHabit(habitId);
              Navigator.of(ctx).pop();
              context.go('/habits');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
