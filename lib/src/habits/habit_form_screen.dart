import 'package:flutter/material.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key, required this.store, this.habit});

  final HabitStore store;
  final Habit? habit;

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
    frequency: _frequency,
    specificDays: _days,
    weeklyTarget: _frequency == HabitFrequency.weeklyTarget
        ? _weeklyTarget
        : null,
    cueWhen: _cueWhen.text,
    cueWhere: _cueWhere.text,
    cueAction: _cueAction.text,
    minimumVersion: _minimum.text,
    startDate: _startDate,
  );

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.habit == null) {
        await widget.store.create(_draft());
      } else {
        await widget.store.update(widget.habit!, _draft());
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
              maxLength: 80,
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

const _weekdays = [
  (day: DateTime.monday, label: 'Sen'),
  (day: DateTime.tuesday, label: 'Sel'),
  (day: DateTime.wednesday, label: 'Rab'),
  (day: DateTime.thursday, label: 'Kam'),
  (day: DateTime.friday, label: 'Jum'),
  (day: DateTime.saturday, label: 'Sab'),
  (day: DateTime.sunday, label: 'Min'),
];
