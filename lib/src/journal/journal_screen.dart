import 'package:flutter/material.dart';
import 'package:prokopa/src/journal/journal_editor_screen.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/wellbeing/mood_check_in_sheet.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    required this.store,
    required this.wellbeingStore,
  });

  final JournalStore store;
  final WellbeingStore wellbeingStore;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _search = TextEditingController();
  List<JournalEntry>? _entries;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    try {
      final entries = await widget.store.list(query: _search.text);
      if (mounted) {
        setState(() {
          _entries = entries;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Catatan belum dapat dimuat. Coba lagi.');
      }
    }
  }

  Future<void> _create(JournalEntryType type) async {
    try {
      final entry = await widget.store.createDraft(type: type);
      if (!mounted) {
        return;
      }
      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              JournalEditorScreen(store: widget.store, entry: entry),
        ),
      );
      if (changed == true) {
        await _reload();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan belum dapat dibuat. Coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _open(JournalEntry entry) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => JournalEditorScreen(store: widget.store, entry: entry),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _checkInMood() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MoodCheckInSheet(store: widget.wellbeingStore),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Jurnal',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: _checkInMood,
                  icon: const Icon(Icons.mood_outlined),
                  tooltip: 'Catat suasana',
                ),
                PopupMenuButton<JournalEntryType>(
                  tooltip: 'Buat catatan',
                  onSelected: _create,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: JournalEntryType.free,
                      child: Text('Catatan bebas'),
                    ),
                    PopupMenuItem(
                      value: JournalEntryType.guided,
                      child: Text('Refleksi terpandu'),
                    ),
                  ],
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                labelText: 'Cari catatan',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: entries == null
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: FilledButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  )
                : entries.isEmpty
                ? _JournalEmpty(onCreate: _create)
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: entries.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return ListTile(
                        onTap: () => _open(entry),
                        title: Text(
                          entry.title?.isNotEmpty == true
                              ? entry.title!
                              : 'Tanpa judul',
                        ),
                        subtitle: Text(
                          entry.body.isEmpty
                              ? 'Draf kosong'
                              : entry.body.replaceAll('\n', ' '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          entry.status == JournalEntryStatus.draft
                              ? 'Draf'
                              : 'Tersimpan',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _JournalEmpty extends StatelessWidget {
  const _JournalEmpty({required this.onCreate});

  final ValueChanged<JournalEntryType> onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Belum ada catatan.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tulis bebas atau gunakan satu pertanyaan sebagai awal.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => onCreate(JournalEntryType.free),
              child: const Text('Tulis catatan'),
            ),
          ],
        ),
      ),
    );
  }
}
