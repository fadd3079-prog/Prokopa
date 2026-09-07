import 'package:intl/intl.dart';

/// Date formatting and calculation utilities.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dayFormat = DateFormat('EEEE');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');

  /// Format a date as "Sep 7, 2026".
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Format a time as "14:30".
  static String formatTime(DateTime time) => _timeFormat.format(time);

  /// Format a date as "Monday".
  static String formatDay(DateTime date) => _dayFormat.format(date);

  /// Format as "Sep 7".
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  /// Format as "September 2026".
  static String formatMonth(DateTime date) => _monthFormat.format(date);

  /// Get a greeting based on time of day.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Normalize a date to midnight (strips time).
  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Check if two dates are the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Get the start of the current week (Monday).
  static DateTime startOfWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return normalize(monday);
  }

  /// Get a list of dates for the last N days.
  static List<DateTime> lastNDays(int n) {
    final today = normalize(DateTime.now());
    return List.generate(n, (i) => today.subtract(Duration(days: n - 1 - i)));
  }

  /// Format duration in hours as "7h 30m".
  static String formatDuration(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Calculate duration between two DateTimes in hours.
  static double calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inMinutes / 60.0;
  }
}

