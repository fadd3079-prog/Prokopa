import 'package:flutter/material.dart';
import 'package:prokopa/src/wellbeing/mood_check_in_sheet.dart';
import 'package:prokopa/src/wellbeing/mood_record.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key, required this.store});

  final WellbeingStore store;

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  List<MoodRecord>? _records;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final records = await widget.store.listMood();
      if (mounted) {
        setState(() {
          _records = records;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Riwayat suasana belum dapat dimuat. Coba lagi.',
        );
      }
    }
  }

  Future<void> _edit(MoodRecord record) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MoodCheckInSheet(store: widget.store, record: record),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _delete(MoodRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus catatan suasana?'),
        content: const Text('Catatan ini akan dihapus dari perangkat ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.store.deleteMood(record.id);
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat suasana')),
      body: SafeArea(
        child: records == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: FilledButton(
                  onPressed: _reload,
                  child: const Text('Coba lagi'),
                ),
              )
            : records.isEmpty
            ? const Center(child: Text('Belum ada catatan suasana.'))
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: records.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = records[index];
                  return ListTile(
                    title: Text(_valence(record.valence)),
                    subtitle: Text(
                      [
                        _formatDate(record.recordedAt),
                        if (record.emotion != null) _emotion(record.emotion!),
                        if (record.context != null) _context(record.context!),
                      ].join(' · '),
                    ),
                    onTap: () => _edit(record),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _edit(record);
                        } else {
                          _delete(record);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Ubah')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _valence(MoodValence value) => switch (value) {
    MoodValence.veryLow => 'Sangat rendah',
    MoodValence.low => 'Rendah',
    MoodValence.neutral => 'Netral',
    MoodValence.good => 'Baik',
    MoodValence.veryGood => 'Sangat baik',
  };

  String _emotion(MoodEmotion value) => switch (value) {
    MoodEmotion.calm => 'Tenang',
    MoodEmotion.happy => 'Senang',
    MoodEmotion.tired => 'Lelah',
    MoodEmotion.anxious => 'Cemas',
    MoodEmotion.frustrated => 'Frustrasi',
    MoodEmotion.sad => 'Sedih',
    MoodEmotion.other => 'Lainnya',
  };

  String _context(MoodContext value) => switch (value) {
    MoodContext.work => 'Kerja',
    MoodContext.sleep => 'Tidur',
    MoodContext.family => 'Keluarga',
    MoodContext.health => 'Kesehatan',
    MoodContext.social => 'Sosial',
    MoodContext.weather => 'Cuaca',
    MoodContext.exercise => 'Olahraga',
  };
}
