import 'package:flutter/material.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({
    super.key,
    required this.store,
    this.habit,
    this.reminderService,
  });

  final HabitStore store;
  final Habit? habit;
  final HabitReminderService? reminderService;

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _purpose;
  late final TextEditingController _cueWhen;
  late final TextEditingController _cueWhere;
  late final TextEditingController _cueAction;
  late final TextEditingController _minimum;
  late HabitFrequency _frequency;
  late Set<int> _days;
  late int _weeklyTarget;
  late DateTime _startDate;
  DateTime? _endDate;
  String? _category;
  String? _icon;
  String? _color;
  TimeOfDay? _reminderTime;
  Set<int> _reminderDays = {};
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final draft = widget.habit?.draft;
    _title = TextEditingController(text: draft?.title ?? '');
    _purpose = TextEditingController(text: draft?.purpose ?? '');
    _cueWhen = TextEditingController(text: draft?.cueWhen ?? '');
    _cueWhere = TextEditingController(text: draft?.cueWhere ?? '');
    _cueAction = TextEditingController(text: draft?.cueAction ?? '');
    _minimum = TextEditingController(text: draft?.minimumVersion ?? '');
    _frequency = draft?.frequency ?? HabitFrequency.daily;
    _days = {...(draft?.specificDays ?? const <int>{})};
    _weeklyTarget = draft?.weeklyTarget ?? 3;
    _startDate = draft?.startDate ?? DateTime.now();
    _endDate = draft?.endDate;
    _category = draft?.category;
    _icon = draft?.icon;
    _color = draft?.color;
    _reminderTime = _timeFromValue(draft?.reminderTime);
    _reminderDays = {...(draft?.reminderDays ?? const <int>{})};
  }

  @override
  void dispose() {
    _title.dispose();
    _purpose.dispose();
    _cueWhen.dispose();
    _cueWhere.dispose();
    _cueAction.dispose();
    _minimum.dispose();
    super.dispose();
  }

  HabitDraft _draft() => HabitDraft(
    title: _title.text,
    purpose: _purpose.text,
    category: _category,
    icon: _icon,
    color: _color,
    frequency: _frequency,
    specificDays: _days,
    weeklyTarget: _frequency == HabitFrequency.weeklyTarget
        ? _weeklyTarget
        : null,
    cueWhen: _cueWhen.text,
    cueWhere: _cueWhere.text,
    cueAction: _cueAction.text,
    minimumVersion: _minimum.text,
    reminderTime: _reminderTime == null
        ? null
        : '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}',
    reminderDays: _frequency == HabitFrequency.weeklyTarget
        ? _reminderDays
        : const {},
    startDate: _startDate,
    endDate: _endDate,
  );

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

  Future<void> _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => _startDate = selected);
    }
  }

  Future<void> _pickEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => _endDate = selected);
    }
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (selected != null) {
      setState(() => _reminderTime = selected);
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
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nama kebiasaan'),
            ),
            TextField(
              controller: _purpose,
              enabled: !_saving,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Mengapa ini penting',
              ),
            ),
            const SizedBox(height: 16),
            Text('Frekuensi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<HabitFrequency>(
              segments: const [
                ButtonSegment(
                  value: HabitFrequency.daily,
                  label: Text('Harian'),
                ),
                ButtonSegment(
                  value: HabitFrequency.specificDays,
                  label: Text('Hari tertentu'),
                ),
                ButtonSegment(
                  value: HabitFrequency.weeklyTarget,
                  label: Text('Target mingguan'),
                ),
              ],
              selected: {_frequency},
              onSelectionChanged: _saving
                  ? null
                  : (value) => setState(() => _frequency = value.single),
            ),
            if (_frequency == HabitFrequency.specificDays) ...[
              const SizedBox(height: 16),
              Text(
                'Pilih hari',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final day in _weekdays)
                    FilterChip(
                      label: Text(day.label),
                      selected: _days.contains(day.day),
                      onSelected: _saving
                          ? null
                          : (selected) => setState(() {
                              if (selected) {
                                _days.add(day.day);
                              } else {
                                _days.remove(day.day);
                              }
                            }),
                    ),
                ],
              ),
            ],
            if (_frequency == HabitFrequency.weeklyTarget) ...[
              const SizedBox(height: 16),
              Text('Target: $_weeklyTarget kali per minggu'),
              Slider(
                value: _weeklyTarget.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                label: '$_weeklyTarget',
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _weeklyTarget = value.round()),
              ),
            ],
            const SizedBox(height: 20),
            Text('Pengaturan', style: Theme.of(context).textTheme.titleMedium),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: _categories
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _category = value),
            ),
            DropdownButtonFormField<String>(
              initialValue: _icon,
              decoration: const InputDecoration(labelText: 'Ikon'),
              items: _icons
                  .map(
                    (icon) => DropdownMenuItem(
                      value: icon.$1,
                      child: Row(
                        children: [
                          Icon(icon.$2),
                          const SizedBox(width: 12),
                          Text(icon.$1),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _icon = value),
            ),
            DropdownButtonFormField<String>(
              initialValue: _color,
              decoration: const InputDecoration(labelText: 'Warna aksen'),
              items: _colors
                  .map(
                    (color) => DropdownMenuItem(
                      value: color.$1,
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: color.$2),
                          const SizedBox(width: 12),
                          Text(color.$1),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _color = value),
            ),
            const SizedBox(height: 20),
            Text('Cue', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _cueWhen,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Kapan'),
            ),
            TextField(
              controller: _cueWhere,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Di mana'),
            ),
            TextField(
              controller: _cueAction,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Tindakan'),
            ),
            TextField(
              controller: _minimum,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Versi minimum'),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mulai'),
              subtitle: Text(localDateKey(_startDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _saving ? null : _pickStartDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Berakhir'),
              subtitle: Text(
                _endDate == null
                    ? 'Tanpa tanggal akhir'
                    : localDateKey(_endDate!),
              ),
              trailing: _endDate == null
                  ? const Icon(Icons.event_available_outlined)
                  : IconButton(
                      tooltip: 'Hapus tanggal akhir',
                      onPressed: _saving
                          ? null
                          : () => setState(() => _endDate = null),
                      icon: const Icon(Icons.clear),
                    ),
              onTap: _saving ? null : _pickEndDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pengingat lokal'),
              subtitle: Text(
                _reminderTime == null
                    ? 'Tidak diaktifkan'
                    : MaterialLocalizations.of(context)
                          .formatTimeOfDay(_reminderTime!),
              ),
              trailing: _reminderTime == null
                  ? const Icon(Icons.notifications_none)
                  : IconButton(
                      tooltip: 'Matikan pengingat',
                      onPressed: _saving
                          ? null
                          : () => setState(() => _reminderTime = null),
                      icon: const Icon(Icons.notifications_off_outlined),
                    ),
              onTap: _saving ? null : _pickReminderTime,
            ),
            if (_frequency == HabitFrequency.weeklyTarget &&
                _reminderTime != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hari pengingat',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final day in _weekdays)
                    FilterChip(
                      label: Text(day.label),
                      selected: _reminderDays.contains(day.day),
                      onSelected: _saving
                          ? null
                          : (selected) => setState(() {
                              if (selected) {
                                _reminderDays.add(day.day);
                              } else {
                                _reminderDays.remove(day.day);
                              }
                            }),
                    ),
                ],
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 20),
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

TimeOfDay? _timeFromValue(String? value) {
  if (value == null) {
    return null;
  }
  final values = value.split(':');
  if (values.length != 2) {
    return null;
  }
  final hour = int.tryParse(values[0]);
  final minute = int.tryParse(values[1]);
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}

const _categories = [
  'Kesehatan',
  'Belajar',
  'Produktivitas',
  'Pikiran',
  'Gaya hidup',
  'Pribadi',
  'Tidur',
  'Lainnya',
];

const _icons = [
  ('Buku', Icons.menu_book_outlined),
  ('Bergerak', Icons.directions_walk_outlined),
  ('Fokus', Icons.center_focus_strong_outlined),
  ('Pikiran', Icons.self_improvement_outlined),
  ('Tidur', Icons.bedtime_outlined),
  ('Cek', Icons.check_circle_outline),
];

const _colors = [
  ('Indigo', Color(0xFF3949AB)),
  ('Hijau', Color(0xFF2E7D32)),
  ('Oranye', Color(0xFFEF6C00)),
  ('Merah muda', Color(0xFFC2185B)),
  ('Abu-abu', Color(0xFF546E7A)),
];

const _weekdays = [
  (day: DateTime.monday, label: 'Sen'),
  (day: DateTime.tuesday, label: 'Sel'),
  (day: DateTime.wednesday, label: 'Rab'),
  (day: DateTime.thursday, label: 'Kam'),
  (day: DateTime.friday, label: 'Jum'),
  (day: DateTime.saturday, label: 'Sab'),
  (day: DateTime.sunday, label: 'Min'),
];
