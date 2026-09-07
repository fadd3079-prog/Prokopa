/// App-wide constants for HabitFlow.
class AppConstants {
  AppConstants._();

  // ── XP System ──
  static const int xpPerHabitCompletion = 10;
  static const int xpPerJournalEntry = 15;
  static const int xpPerSleepLog = 5;
  static const int xpPerLevel = 500;

  // ── Achievement Thresholds ──
  static const int streakMasterDays = 30;
  static const int centurionDays = 100;
  static const int journalKeeperCount = 10;
  static const int prolificWriterCount = 50;
  static const int sleepTrackerDays = 7;
  static const int sleepMasterDays = 30;
  static const double sleepMasterMinHours = 7.0;
  static const int habitBuilderCount = 5;
  static const int weekWarriorDays = 7;

  // ── Sleep ──
  static const double idealSleepHoursMin = 7.0;
  static const double idealSleepHoursMax = 9.0;

  // ── Analytics ──
  static const int defaultAnalyticsDays = 30;
  static const int weeklyChartDays = 7;
  static const int monthlyChartDays = 30;

  // ── UI ──
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double defaultPadding = 16.0;

  // ── Habit Icons ──
  static const List<String> habitIcons = [
    'check_circle',
    'fitness_center',
    'book',
    'self_improvement',
    'water_drop',
    'directions_run',
    'restaurant',
    'code',
    'music_note',
    'brush',
    'school',
    'work',
    'favorite',
    'star',
    'local_cafe',
    'bedtime',
  ];
}

