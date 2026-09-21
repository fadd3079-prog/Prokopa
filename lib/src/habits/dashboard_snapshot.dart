import 'package:flutter/foundation.dart';
import 'package:prokopa/src/habits/habit.dart';

@immutable
final class DashboardSnapshot {
  const DashboardSnapshot({
    required this.completedToday,
    required this.scheduledToday,
    required this.habitProgress,
  });

  final int completedToday;
  final int scheduledToday;
  final List<HabitProgress> habitProgress;
}
