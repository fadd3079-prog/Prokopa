import 'package:flutter/material.dart';
import 'package:prokopa/src/wellbeing/mood_record.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class MoodCheckInSheet extends StatefulWidget {
  const MoodCheckInSheet({super.key, required this.store, this.record});

  final WellbeingStore store;
  final MoodRecord? record;

  @override
  State<MoodCheckInSheet> createState() => _MoodCheckInSheetState();
}

class _MoodCheckInSheetState extends State<MoodCheckInSheet> {
  MoodValence? _valence;
  MoodEnergy? _energy;
  MoodEmotion? _emotion;
  MoodContext? _context;
  final _note = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _valence = record?.valence;
    _energy = record?.energy;
    _emotion = record?.emotion;
    _context = record?.context;
    _note.text = record?.note ?? '';
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_valence == null) {
      setState(() => _error = 'Pilih suasana yang paling mendekati.');
      return;
    }
    try {
      await widget.store.saveMood(
        id: widget.record?.id,
        valence: _valence!,
        energy: _energy,
        emotion: _emotion,
        context: _context,
        note: _note.text,
        recordedAt: widget.record?.recordedAt,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      setState(() => _error = 'Suasana belum tersimpan. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.record == null ? 'Catat suasana' : 'Ubah suasana',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Bagaimana rasanya sekarang?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in MoodValence.values)
                  ChoiceChip(
                    label: Text(_valenceLabel(value)),
                    selected: _valence == value,
                    onSelected: (_) => setState(() => _valence = value),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Energi opsional',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final value in MoodEnergy.values)
                  ChoiceChip(
                    label: Text(_energyLabel(value)),
                    selected: _energy == value,
                    onSelected: (_) => setState(
                      () => _energy = _energy == value ? null : value,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MoodEmotion>(
              initialValue: _emotion,
              decoration: const InputDecoration(labelText: 'Emosi opsional'),
              items: MoodEmotion.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_emotionLabel(value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _emotion = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MoodContext>(
              initialValue: _context,
              decoration: const InputDecoration(labelText: 'Konteks opsional'),
              items: MoodContext.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_contextLabel(value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _context = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Catatan opsional'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Simpan suasana'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _valenceLabel(MoodValence value) => switch (value) {
    MoodValence.veryLow => 'Sangat rendah',
    MoodValence.low => 'Rendah',
    MoodValence.neutral => 'Netral',
    MoodValence.good => 'Baik',
    MoodValence.veryGood => 'Sangat baik',
  };

  String _energyLabel(MoodEnergy value) => switch (value) {
    MoodEnergy.low => 'Rendah',
    MoodEnergy.medium => 'Sedang',
    MoodEnergy.high => 'Tinggi',
  };

  String _emotionLabel(MoodEmotion value) => switch (value) {
    MoodEmotion.calm => 'Tenang',
    MoodEmotion.happy => 'Senang',
    MoodEmotion.tired => 'Lelah',
    MoodEmotion.anxious => 'Cemas',
    MoodEmotion.frustrated => 'Frustrasi',
    MoodEmotion.sad => 'Sedih',
    MoodEmotion.other => 'Lainnya',
  };

  String _contextLabel(MoodContext value) => switch (value) {
    MoodContext.work => 'Kerja',
    MoodContext.sleep => 'Tidur',
    MoodContext.family => 'Keluarga',
    MoodContext.health => 'Kesehatan',
    MoodContext.social => 'Sosial',
    MoodContext.weather => 'Cuaca',
    MoodContext.exercise => 'Olahraga',
  };
}
