enum HabitFrequency { daily, specificDays, weeklyTarget }

enum HabitState { created, active, paused, archived }

enum HabitExecutionState { completed, skipped, missed }

enum HabitRecoveryAction { continueHabit, reduceTarget, changeCue, pause }

extension HabitRecoveryActionValue on HabitRecoveryAction {
  String get value => switch (this) {
    HabitRecoveryAction.continueHabit => 'continue',
    HabitRecoveryAction.reduceTarget => 'reduce_target',
    HabitRecoveryAction.changeCue => 'change_cue',
    HabitRecoveryAction.pause => 'pause',
  };
}

extension HabitFrequencyValue on HabitFrequency {
  String get value => switch (this) {
    HabitFrequency.daily => 'daily',
    HabitFrequency.specificDays => 'specific_days',
    HabitFrequency.weeklyTarget => 'weekly_target',
  };

  static HabitFrequency fromValue(String value) => switch (value) {
    'specific_days' => HabitFrequency.specificDays,
    'weekly_target' => HabitFrequency.weeklyTarget,
    _ => HabitFrequency.daily,
  };
}

extension HabitStateValue on HabitState {
  String get value => switch (this) {
    HabitState.created => 'created',
    HabitState.active => 'active',
    HabitState.paused => 'paused',
    HabitState.archived => 'archived',
  };

  static HabitState fromValue(String value) => switch (value) {
    'created' => HabitState.created,
    'paused' => HabitState.paused,
    'archived' => HabitState.archived,
    _ => HabitState.active,
  };
}

extension HabitExecutionStateValue on HabitExecutionState {
  String get value => switch (this) {
    HabitExecutionState.completed => 'completed',
    HabitExecutionState.skipped => 'skipped',
    HabitExecutionState.missed => 'missed',
  };

  static HabitExecutionState fromValue(String value) => switch (value) {
    'skipped' => HabitExecutionState.skipped,
    'missed' => HabitExecutionState.missed,
    _ => HabitExecutionState.completed,
  };
}

class HabitDraft {
  const HabitDraft({
    required this.title,
    required this.frequency,
    required this.startDate,
    this.purpose,
    this.category,
    this.icon,
    this.color,
    this.specificDays = const {},
    this.weeklyTarget,
    this.cueWhen,
    this.cueWhere,
    this.cueAction,
    this.minimumVersion,
    this.reminderTime,
    this.reminderDays = const {},
    this.endDate,
  });

  final String title;
  final String? purpose;
  final String? category;
  final String? icon;
  final String? color;
  final HabitFrequency frequency;
  final Set<int> specificDays;
  final int? weeklyTarget;
  final String? cueWhen;
  final String? cueWhere;
  final String? cueAction;
  final String? minimumVersion;
  final String? reminderTime;
  final Set<int> reminderDays;
  final DateTime startDate;
  final DateTime? endDate;
}

class Habit {
  const Habit({
    required this.id,
    required this.draft,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    this.pausedAt,
    this.archivedAt,
  });

  final String id;
  final HabitDraft draft;
  final HabitState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pausedAt;
  final DateTime? archivedAt;

  Habit withDraft(HabitDraft value) => Habit(
    id: id,
    draft: value,
    state: state,
    createdAt: createdAt,
    updatedAt: updatedAt,
    pausedAt: pausedAt,
    archivedAt: archivedAt,
  );
}

class HabitExecution {
  const HabitExecution({
    required this.id,
    required this.habitId,
    required this.plannedDate,
    required this.state,
    required this.recordedAt,
    this.skipReason,
    this.note,
  });

  final String id;
  final String habitId;
  final DateTime plannedDate;
  final HabitExecutionState state;
  final String? skipReason;
  final String? note;
  final DateTime recordedAt;
}

class HabitRecovery {
  const HabitRecovery({
    required this.id,
    required this.habitId,
    required this.action,
    required this.recordedAt,
  });

  final String id;
  final String habitId;
  final HabitRecoveryAction action;
  final DateTime recordedAt;
}

class HabitProgress {
  const HabitProgress({
    required this.habit,
    required this.repetitions,
    required this.currentStreak,
    required this.longestStreak,
    required this.recoveryCount,
    this.weekCompleted,
    this.weekTarget,
  });

  final Habit habit;
  final int repetitions;
  final int currentStreak;
  final int longestStreak;
  final int recoveryCount;
  final int? weekCompleted;
  final int? weekTarget;

  bool get isWeeklyTarget => weekTarget != null;
}

class TodayHabit {
  const TodayHabit({
    required this.habit,
    required this.completedThisWeek,
    required this.weeklyTarget,
    this.execution,
  });

  final Habit habit;
  final HabitExecution? execution;
  final int completedThisWeek;
  final int? weeklyTarget;

  bool get isComplete => execution?.state == HabitExecutionState.completed;

  bool get isWeeklyTarget =>
      habit.draft.frequency == HabitFrequency.weeklyTarget;
}
