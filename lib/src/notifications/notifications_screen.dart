import 'package:flutter/material.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/notifications/notification_store.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.store,
    required this.service,
    this.habitReminders,
  });

  final NotificationStore store;
  final LocalNotificationService service;
  final HabitReminderService? habitReminders;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _reminders = [
    (
      id: 'journal',
      label: 'Pengingat jurnal',
      notificationId: 101,
      defaultTime: '20:00',
    ),
    (
      id: 'sleep',
      label: 'Pengingat tidur',
      notificationId: 102,
      defaultTime: '22:00',
    ),
    (
      id: 'weekly_review',
      label: 'Tinjauan mingguan',
      notificationId: 103,
      defaultTime: '18:00',
    ),
  ];

  final _preferences = <String, NotificationPreference>{};
  (String?, String?) _quiet = (null, null);
  String? _message;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final preferences = await Future.wait(
      _reminders.map((reminder) => widget.store.load(reminder.id)),
    );
    final quiet = await widget.store.quietPeriod();
    if (mounted) {
      setState(() {
        _preferences
          ..clear()
          ..addEntries(
            preferences.map(
              (preference) => MapEntry(preference.id, preference),
            ),
          );
        _quiet = quiet;
      });
    }
  }

  Future<void> _toggle(
    ({String id, String label, int notificationId, String defaultTime})
    reminder,
    bool enabled,
  ) async {
    final current = _preferences[reminder.id]!;
    final time = current.timeOfDay ?? reminder.defaultTime;
    if (enabled) {
      final granted = await widget.service.requestPermission();
      if (!granted) {
        if (mounted) {
          setState(() => _message = 'Izin notifikasi belum diberikan.');
        }
        return;
      }
      await _schedule(reminder, time);
    } else {
      await widget.service.cancel(reminder.notificationId);
    }
    await widget.store.save(
      NotificationPreference(
        id: reminder.id,
        kind: reminder.id,
        enabled: enabled,
        timeOfDay: time,
      ),
    );
    await _reload();
  }

  Future<void> _pickTime(
    ({String id, String label, int notificationId, String defaultTime})
    reminder,
  ) async {
    final current = _preferences[reminder.id]!;
    final time = _timeOfDay(current.timeOfDay ?? reminder.defaultTime);
    final selected = await showTimePicker(context: context, initialTime: time);
    if (selected == null) {
      return;
    }
    final value =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    if (current.enabled) {
      await _schedule(reminder, value);
    }
    await widget.store.save(
      NotificationPreference(
        id: reminder.id,
        kind: reminder.id,
        enabled: current.enabled,
        timeOfDay: value,
      ),
    );
    await _reload();
  }

  Future<void> _schedule(
    ({String id, String label, int notificationId, String defaultTime})
    reminder,
    String time,
  ) async {
    await widget.store.schedule(
      NotificationPreference(
        id: reminder.id,
        kind: reminder.id,
        enabled: true,
        timeOfDay: time,
      ),
      widget.service,
    );
  }

  Future<void> _setQuietPeriod() async {
    final start = await showTimePicker(
      context: context,
      initialTime: _timeOfDay(_quiet.$1 ?? '22:00'),
    );
    if (start == null || !mounted) {
      return;
    }
    final end = await showTimePicker(
      context: context,
      initialTime: _timeOfDay(_quiet.$2 ?? '07:00'),
    );
    if (end == null) {
      return;
    }
    await widget.store.saveQuietPeriod(
      start: _format(start),
      end: _format(end),
    );
    await _reload();
    await _rescheduleEnabled();
  }

  Future<void> _clearQuietPeriod() async {
    await widget.store.saveQuietPeriod();
    await _reload();
    await _rescheduleEnabled();
  }

  Future<void> _rescheduleEnabled() async {
    for (final reminder in _reminders) {
      final preference = _preferences[reminder.id];
      if (preference?.enabled == true) {
        await _schedule(
          reminder,
          preference!.timeOfDay ?? reminder.defaultTime,
        );
      }
    }
    await widget.habitReminders?.rescheduleEnabled();
  }

  TimeOfDay _timeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _format(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pengingat bersifat lokal dan opsional. Isi jurnal tidak ditampilkan pada layar kunci.',
            ),
            const SizedBox(height: 12),
            for (final reminder in _reminders)
              if (_preferences.containsKey(reminder.id))
                SwitchListTile(
                  title: Text(reminder.label),
                  subtitle: Text(
                    _preferences[reminder.id]!.timeOfDay ??
                        reminder.defaultTime,
                  ),
                  value: _preferences[reminder.id]!.enabled,
                  onChanged: (enabled) => _toggle(reminder, enabled),
                  secondary: IconButton(
                    onPressed: () => _pickTime(reminder),
                    icon: const Icon(Icons.schedule),
                    tooltip: 'Ubah waktu ${reminder.label}',
                  ),
                ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Periode hening'),
              subtitle: Text(
                _quiet.$1 == null
                    ? 'Tidak diatur'
                    : '${_quiet.$1} sampai ${_quiet.$2}',
              ),
              onTap: _setQuietPeriod,
              trailing: _quiet.$1 == null
                  ? const Icon(Icons.nights_stay_outlined)
                  : IconButton(
                      onPressed: _clearQuietPeriod,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Hapus periode hening',
                    ),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_message!),
              ),
          ],
        ),
      ),
    );
  }
}
