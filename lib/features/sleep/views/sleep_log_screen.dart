import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/shared/models/enums.dart';
import 'package:habitflow/core/services/gamification_service.dart';

class SleepLogScreen extends ConsumerStatefulWidget {
  const SleepLogScreen({super.key});

  @override
  ConsumerState<SleepLogScreen> createState() => _SleepLogScreenState();
}

class _SleepLogScreenState extends ConsumerState<SleepLogScreen> {
  DateTime _date = DateTime.now();
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0);
  SleepQuality _quality = SleepQuality.good;

  String _getEmojiForQuality(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return '😩';
      case SleepQuality.fair:
        return '🥱';
      case SleepQuality.good:
        return '😌';
      case SleepQuality.excellent:
        return '🤩';
      default:
        return '😴';
    }
  }

  Duration _calculateDuration() {
    DateTime bed = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _bedTime.hour,
      _bedTime.minute,
    );
    DateTime wake = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    if (wake.isBefore(bed)) {
      wake = wake.add(const Duration(days: 1));
    }

    return wake.difference(bed);
  }

  Future<void> _selectBedTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedTime,
    );
    if (picked != null && picked != _bedTime) {
      setState(() {
        _bedTime = picked;
      });
    }
  }

  Future<void> _selectWakeTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
    );
    if (picked != null && picked != _wakeTime) {
      setState(() {
        _wakeTime = picked;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    final duration = _calculateDuration();
    if (duration.isNegative || duration.inMinutes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wake time must be after bed time.')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    DateTime bed = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _bedTime.hour,
      _bedTime.minute,
    );
    DateTime wake = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    if (wake.isBefore(bed)) {
      wake = wake.add(const Duration(days: 1));
    }

    await db.sleepDao.createRecord(
      SleepRecordsCompanion.insert(
        sleepStart: bed,
        sleepEnd: wake,
        duration: duration.inMinutes / 60.0,
        quality: Value(_quality.score),
        date: DateTime(_date.year, _date.month, _date.day),
      ),
    );
    await ref.read(gamificationServiceProvider).evaluateSleepAchievements();

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration();
    final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';

    return Scaffold(
      appBar: AppBar(title: const Text('Log Sleep')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const Divider(),
            ListTile(
              title: const Text('Bedtime'),
              subtitle: Text(_bedTime.format(context)),
              trailing: const Icon(Icons.nights_stay),
              onTap: _selectBedTime,
            ),
            ListTile(
              title: const Text('Wake Time'),
              subtitle: Text(_wakeTime.format(context)),
              trailing: const Icon(Icons.wb_sunny),
              onTap: _selectWakeTime,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'Duration: $durationStr',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Sleep Quality',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: SleepQuality.values.map((q) {
                final isSelected = _quality == q;
                return GestureDetector(
                  onTap: () => setState(() => _quality = q),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getEmojiForQuality(q),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saveRecord,
              child: const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }
}
