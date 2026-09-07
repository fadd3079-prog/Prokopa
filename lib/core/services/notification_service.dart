import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service responsible for managing local reminders and notifications.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification settings for supported platforms.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(settings: initSettings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Request permissions on platforms that require runtime permission (e.g. Android 13+).
  Future<bool?> requestPermissions() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        return await androidPlatform.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return null;
  }

  /// Show an instant notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'habitflow_reminders',
        'HabitFlow Reminders',
        channelDescription: 'General reminders for habits, journals, and sleep',
        importance: Importance.high,
        priority: Priority.high,
      );

      const darwinDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Cancel all scheduled and displayed notifications.
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Schedule daily habit reminder.
  Future<void> scheduleHabitReminder() async {
    await showNotification(
      id: 101,
      title: 'HabitFlow Reminder',
      body: 'Time to complete your habit.',
    );
  }

  /// Schedule daily reflection / journal reminder.
  Future<void> scheduleJournalReminder() async {
    await showNotification(
      id: 102,
      title: 'Daily Reflection',
      body: 'Reflect your day.',
    );
  }

  /// Schedule daily sleep reminder.
  Future<void> scheduleSleepReminder() async {
    await showNotification(
      id: 103,
      title: 'Bedtime Preparation',
      body: 'Prepare for better sleep.',
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
