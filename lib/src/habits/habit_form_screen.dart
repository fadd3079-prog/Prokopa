import 'package:flutter/material.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({
    super.key,
    required this.store,
    this.habit,
    this.initialDate,
    this.reminderService,
  });

  final HabitStore store;
  final Habit? habit;
  final DateTime? initialDate;
  final HabitReminderService? reminderService;

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  late final TextEditingController _title;
  late String _color;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.habit?.draft.title ?? '');
    _color = _normalizedColor(widget.habit?.draft.color);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  HabitDraft _draft() {
    final existing = widget.habit?.draft;
    return HabitDraft(
      title: _title.text,
      color: _color,
      frequency: existing?.frequency ?? HabitFrequency.daily,
      startDate: existing?.startDate ?? widget.initialDate ?? DateTime.now(),
      purpose: existing?.purpose,
      category: existing?.category,
      icon: existing?.icon,
      specificDays: existing?.specificDays ?? const {},
      weeklyTarget: existing?.weeklyTarget,
      cueWhen: existing?.cueWhen,
      cueWhere: existing?.cueWhere,
      cueAction: existing?.cueAction,
      minimumVersion: existing?.minimumVersion,
      reminderTime: existing?.reminderTime,
      reminderDays: existing?.reminderDays ?? const {},
      endDate: existing?.endDate,
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final habit = widget.habit == null
          ? await widget.store.create(_draft())
          : await widget.store.update(widget.habit!, _draft());
      final reminder = widget.reminderService == null
          ? HabitReminderResult.disabled
          : await widget.reminderService!.synchronize(habit);
      if (reminder == HabitReminderResult.permissionUnavailable ||
          reminder == HabitReminderResult.failed) {
        setState(() {
          _saving = false;
          _error = reminder == HabitReminderResult.permissionUnavailable
              ? 'Kebiasaan tersimpan. Izin pengingat belum diberikan.'
              : 'Kebiasaan tersimpan. Pengingat belum dapat dijadwalkan.';
        });
        return;
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ArgumentError catch (error) {
      setState(() {
        _saving = false;
        _error = error.message?.toString() ?? 'Periksa kebiasaan ini.';
      });
    } catch (_) {
      setState(() {
        _saving = false;
        _error = 'Kebiasaan belum tersimpan. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Buat kebiasaan' : 'Ubah kebiasaan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _title,
              enabled: !_saving,
              autofocus: widget.habit == null,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: _saving ? null : (_) => _save(),
              decoration: const InputDecoration(labelText: 'Nama kebiasaan'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _color,
              decoration: const InputDecoration(labelText: 'Warna aksen'),
              items: _colors
                  .map(
                    (color) => DropdownMenuItem(
                      value: color.value,
                      child: Row(
                        children: [
                          ExcludeSemantics(
                            child: Icon(Icons.circle, color: color.color),
                          ),
                          const SizedBox(width: 12),
                          Text(color.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _color = value);
                      }
                    },
            ),
            if (_error case final error?)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Menyimpan' : 'Simpan kebiasaan'),
            ),
          ],
        ),
      ),
    );
  }
}

String _normalizedColor(String? value) {
  if (value == null) {
    return _colors.first.value;
  }
  for (final color in _colors) {
    if (value == color.value || value == color.label) {
      return color.value;
    }
  }
  return _colors.first.value;
}

const _colors = [
  (label: 'Indigo', value: '#3949AB', color: Color(0xFF3949AB)),
  (label: 'Hijau', value: '#2E7D32', color: Color(0xFF2E7D32)),
  (label: 'Oranye', value: '#EF6C00', color: Color(0xFFEF6C00)),
  (label: 'Merah muda', value: '#C2185B', color: Color(0xFFC2185B)),
  (label: 'Abu-abu', value: '#546E7A', color: Color(0xFF546E7A)),
];
