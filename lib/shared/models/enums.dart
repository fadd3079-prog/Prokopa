import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/app_colors.dart';

/// Habit category enum with display properties.
enum HabitCategory {
  general('General', Icons.check_circle_outline, AppColors.categoryGeneral),
  health('Health', Icons.favorite_outline, AppColors.categoryHealth),
  fitness('Fitness', Icons.fitness_center, AppColors.categoryFitness),
  mindfulness('Mindfulness', Icons.self_improvement, AppColors.categoryMindfulness),
  learning('Learning', Icons.school_outlined, AppColors.categoryLearning),
  productivity('Productivity', Icons.trending_up, AppColors.categoryProductivity),
  creativity('Creativity', Icons.palette_outlined, AppColors.categoryCreativity),
  social('Social', Icons.people_outline, AppColors.categorySocial);

  const HabitCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static HabitCategory fromString(String value) {
    return HabitCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitCategory.general,
    );
  }
}

/// Habit frequency enum.
enum HabitFrequency {
  daily('Daily'),
  weekly('Weekly');

  const HabitFrequency(this.label);

  final String label;

  static HabitFrequency fromString(String value) {
    return HabitFrequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitFrequency.daily,
    );
  }
}

/// Mood type with emoji and color mapping (1-5 scale).
enum MoodType {
  veryBad(1, '😢', 'Very Bad', AppColors.moodVeryBad),
  bad(2, '😔', 'Bad', AppColors.moodBad),
  normal(3, '😐', 'Normal', AppColors.moodNormal),
  good(4, '😊', 'Good', AppColors.moodGood),
  excellent(5, '😄', 'Excellent', AppColors.moodExcellent);

  const MoodType(this.score, this.emoji, this.label, this.color);

  final int score;
  final String emoji;
  final String label;
  final Color color;

  static MoodType fromScore(int score) {
    return MoodType.values.firstWhere(
      (e) => e.score == score,
      orElse: () => MoodType.normal,
    );
  }
}

/// Sleep quality rating.
enum SleepQuality {
  veryPoor(1, 'Very Poor', '😫'),
  poor(2, 'Poor', '😴'),
  fair(3, 'Fair', '😐'),
  good(4, 'Good', '😊'),
  excellent(5, 'Excellent', '🌟');

  const SleepQuality(this.score, this.label, this.emoji);

  final int score;
  final String label;
  final String emoji;

  static SleepQuality fromScore(int score) {
    return SleepQuality.values.firstWhere(
      (e) => e.score == score,
      orElse: () => SleepQuality.fair,
    );
  }
}

