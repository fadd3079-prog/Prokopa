import 'package:flutter/foundation.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

@immutable
final class DashboardSnapshot {
  const DashboardSnapshot({
    required this.completedToday,
    required this.scheduledToday,
    required this.habitProgress,
    this.todayHabits = const [],
    this.month,
    this.journal,
    this.sleep,
  });

  final int completedToday;
  final int scheduledToday;
  final List<HabitProgress> habitProgress;
  final List<TodayHabit> todayHabits;
  final ProgressSnapshot? month;
  final JournalEntryPreview? journal;
  final SleepRecord? sleep;
}
