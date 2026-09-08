import 'package:prokopa/src/habits/habit.dart';

bool isHabitScheduledOn(HabitDraft draft, DateTime day) {
  final local = DateTime(day.year, day.month, day.day);
  final start = DateTime(
    draft.startDate.year,
    draft.startDate.month,
    draft.startDate.day,
  );
  final end = draft.endDate == null
      ? null
      : DateTime(draft.endDate!.year, draft.endDate!.month, draft.endDate!.day);
  if (local.isBefore(start) || (end != null && local.isAfter(end))) {
    return false;
  }
  return switch (draft.frequency) {
    HabitFrequency.daily => true,
    HabitFrequency.specificDays => draft.specificDays.contains(local.weekday),
    HabitFrequency.weeklyTarget => false,
  };
}

DateTime startOfWeek(DateTime day) {
  final local = DateTime(day.year, day.month, day.day);
  return local.subtract(Duration(days: local.weekday - DateTime.monday));
}

DateTime endOfWeek(DateTime day) =>
    startOfWeek(day).add(const Duration(days: 6));
