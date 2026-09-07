import 'package:flutter/material.dart';

/// Centralized color definitions for HabitFlow.
///
/// Calm indigo/teal palette inspired by Apple Health, Headspace, and Linear.
class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // ── Secondary ──
  static const Color secondary = Color(0xFF14B8A6); // Teal
  static const Color secondaryLight = Color(0xFF2DD4BF);
  static const Color secondaryDark = Color(0xFF0D9488);

  // ── Accent ──
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color accentLight = Color(0xFFFBBF24);

  // ── Mood Colors ──
  static const Color moodExcellent = Color(0xFF22C55E);
  static const Color moodGood = Color(0xFF84CC16);
  static const Color moodNormal = Color(0xFFFBBF24);
  static const Color moodBad = Color(0xFFF97316);
  static const Color moodVeryBad = Color(0xFFEF4444);

  // ── Habit Category Colors ──
  static const Color categoryHealth = Color(0xFF22C55E);
  static const Color categoryFitness = Color(0xFFF97316);
  static const Color categoryMindfulness = Color(0xFF8B5CF6);
  static const Color categoryLearning = Color(0xFF3B82F6);
  static const Color categoryProductivity = Color(0xFF14B8A6);
  static const Color categoryCreativity = Color(0xFFEC4899);
  static const Color categorySocial = Color(0xFFF59E0B);
  static const Color categoryGeneral = Color(0xFF6B7280);

  // ── Light Theme ──
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightOnBackground = Color(0xFF0F172A);
  static const Color lightOnSurface = Color(0xFF1E293B);
  static const Color lightOnSurfaceVariant = Color(0xFF64748B);
  static const Color lightOutline = Color(0xFFE2E8F0);

  // ── Dark Theme ──
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkOnBackground = Color(0xFFF1F5F9);
  static const Color darkOnSurface = Color(0xFFE2E8F0);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF475569);

  // ── Semantic ──
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  /// Get the color for a mood score (1-5).
  static Color moodColor(int score) {
    return switch (score) {
      5 => moodExcellent,
      4 => moodGood,
      3 => moodNormal,
      2 => moodBad,
      1 => moodVeryBad,
      _ => moodNormal,
    };
  }

  /// Get the color for a habit category.
  static Color categoryColor(String category) {
    return switch (category) {
      'health' => categoryHealth,
      'fitness' => categoryFitness,
      'mindfulness' => categoryMindfulness,
      'learning' => categoryLearning,
      'productivity' => categoryProductivity,
      'creativity' => categoryCreativity,
      'social' => categorySocial,
      _ => categoryGeneral,
    };
  }
}

