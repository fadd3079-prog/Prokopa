import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class SleepInputSheet extends StatefulWidget {
  const SleepInputSheet({
    super.key,
    required this.store,
    required this.date,
    this.record,
  });

  final WellbeingStore store;
  final DateTime date;
  final SleepRecord? record;

  @override
  State<SleepInputSheet> createState() => _SleepInputSheetState();
}

class _SleepInputSheetState extends State<SleepInputSheet> {
  late TimeOfDay _bedtime;
  late TimeOfDay _wakeTime;
  late SleepQuality _quality;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _bedtime = record == null
        ? const TimeOfDay(hour: 22, minute: 30)
        : TimeOfDay.fromDateTime(record.start);
    _wakeTime = record == null
        ? const TimeOfDay(hour: 6, minute: 30)
        : TimeOfDay.fromDateTime(record.end);
    _quality = record?.quality ?? SleepQuality.good;
  }

  (DateTime, DateTime) get _range {
    final wake = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    var start = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _bedtime.hour,
      _bedtime.minute,
    );
    if (!start.isBefore(wake)) {
      start = start.subtract(const Duration(days: 1));
    }
    return (start, wake);
  }

  Future<void> _pickBedtime() async {
    final value = await showTimePicker(context: context, initialTime: _bedtime);
    if (value != null) {
      setState(() => _bedtime = value);
    }
  }

  Future<void> _pickWakeTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
    );
    if (value != null) {
      setState(() => _wakeTime = value);
    }
  }

  Future<void> _save() async {
    final (start, end) = _range;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.store.saveSleep(
        id: widget.record?.id,
        start: start,
        end: end,
        quality: _quality,
        note: widget.record?.note,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Catatan tidur belum tersimpan. Periksa waktunya.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final (start, end) = _range;
    final minutes = end.difference(start).inMinutes;
    final duration = '${minutes ~/ 60}j ${minutes % 60}m';
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Catat Tidur',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _TimeButton(
                    label: 'Waktu tidur',
                    value: _bedtime.format(context),
                    onTap: _pickBedtime,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TimeButton(
                    label: 'Waktu bangun',
                    value: _wakeTime.format(context),
                    onTap: _pickWakeTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: AppRadius.mdBorder,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const ExcludeSemantics(
                      child: Icon(Icons.bedtime_outlined, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Durasi tidur',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Kualitas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final quality in SleepQuality.values)
                  ChoiceChip(
                    label: Text(_qualityLabel(quality)),
                    selected: _quality == quality,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _quality = quality),
                  ),
              ],
            ),
            if (_error case final error?) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: AppSpacing.xs),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Menyimpan' : 'Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _qualityLabel(SleepQuality quality) => switch (quality) {
    SleepQuality.poor => 'Buruk',
    SleepQuality.fair => 'Cukup',
    SleepQuality.good => 'Baik',
    SleepQuality.excellent => 'Sangat baik',
  };
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
