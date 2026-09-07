import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/features/habit/providers/habit_providers.dart';
import 'package:habitflow/features/habit/widgets/streak_display.dart';

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

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(habitStreakProvider(habit.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/habits/detail/${habit.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(habit.color),
                radius: 24,
                child: Icon(_getIconData(habit.icon), color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        habit.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              streakAsync.when(
                data: (streak) => StreakDisplay(
                  currentStreak: streak.current,
                  longestStreak: streak.longest,
                ),
                loading: () => const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: false, // In a real app, this would check todayCompletionsProvider
                onChanged: (val) {
                  final db = ref.read(databaseProvider);
                  db.habitDao.toggleCompletion(habit.id, DateTime.now());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
