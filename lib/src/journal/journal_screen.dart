import 'package:flutter/material.dart';
import 'package:prokopa/src/journal/journal_editor_screen.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/wellbeing/mood_check_in_sheet.dart';
import 'package:prokopa/src/wellbeing/mood_history_screen.dart';
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
  static const _pageSize = 40;
  final _search = TextEditingController();
  List<JournalEntryPreview>? _entries;
  String? _error;
  JournalEntryType? _type;
  String? _mood;
  var _hasMore = false;
  var _loadingMore = false;
  int _loadVersion = 0;

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
    final version = ++_loadVersion;
    try {
      final entries = await widget.store.list(
        query: _search.text,
        type: _type,
        mood: _mood,
        limit: _pageSize + 1,
      );
      if (mounted && version == _loadVersion) {
        setState(() {
          _entries = entries.take(_pageSize).toList();
          _hasMore = entries.length > _pageSize;
          _loadingMore = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Catatan belum dapat dimuat. Coba lagi.');
      }
    }
  }

  Future<void> _loadMore() async {
    final entries = _entries;
    if (entries == null || _loadingMore || !_hasMore) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final next = await widget.store.list(
        query: _search.text,
        type: _type,
        mood: _mood,
        limit: _pageSize + 1,
        offset: entries.length,
      );
      if (mounted) {
        setState(() {
          _entries = [...entries, ...next.take(_pageSize)];
          _hasMore = next.length > _pageSize;
          _loadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingMore = false;
          _error = 'Catatan berikutnya belum dapat dimuat. Coba lagi.';
        });
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

  Future<void> _open(JournalEntryPreview preview) async {
    try {
      final entry = await widget.store.load(preview.id);
      if (entry == null) {
        await _reload();
        return;
      }
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
            content: Text('Catatan belum dapat dibuka. Coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _checkInMood() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MoodCheckInSheet(store: widget.wellbeingStore),
    );
  }

  Future<void> _filter() async {
    final selected = await showModalBottomSheet<_JournalFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _JournalFilterSheet(type: _type, mood: _mood),
    );
    if (selected == null) {
      return;
    }
    setState(() {
      _type = selected.type;
      _mood = selected.mood;
    });
    await _reload();
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
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          MoodHistoryScreen(store: widget.wellbeingStore),
                    ),
                  ),
                  icon: const Icon(Icons.history_outlined),
                  tooltip: 'Riwayat suasana',
                ),
                IconButton(
                  onPressed: _filter,
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter catatan',
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
          if (_type != null || _mood != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Filter aktif: ${_filterLabel()}',
                style: Theme.of(context).textTheme.bodySmall,
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
                    itemCount:
                        entries.length + (_hasMore || _loadingMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index == entries.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: _loadingMore
                                ? const CircularProgressIndicator()
                                : OutlinedButton(
                                    onPressed: _loadMore,
                                    child: const Text('Muat lebih banyak'),
                                  ),
                          ),
                        );
                      }
                      final entry = entries[index];
                      return ListTile(
                        onTap: () => _open(entry),
                        title: Text(
                          entry.title?.isNotEmpty == true
                              ? entry.title!
                              : 'Tanpa judul',
                        ),
                        subtitle: Text(
                          entry.bodyPreview.isEmpty
                              ? 'Draf kosong'
                              : entry.bodyPreview.replaceAll('\n', ' '),
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

  String _filterLabel() {
    final labels = <String>[];
    if (_type != null) {
      labels.add(_type == JournalEntryType.free ? 'bebas' : 'terpandu');
    }
    if (_mood != null) {
      labels.add(_moodLabel(_mood!));
    }
    return labels.join(', ');
  }

  String _moodLabel(String value) => switch (value) {
    'very_low' => 'sangat rendah',
    'low' => 'rendah',
    'neutral' => 'netral',
    'good' => 'baik',
    'very_good' => 'sangat baik',
    _ => value,
  };
}

class _JournalFilter {
  const _JournalFilter({this.type, this.mood});

  final JournalEntryType? type;
  final String? mood;
}

class _JournalFilterSheet extends StatefulWidget {
  const _JournalFilterSheet({this.type, this.mood});

  final JournalEntryType? type;
  final String? mood;

  @override
  State<_JournalFilterSheet> createState() => _JournalFilterSheetState();
}

class _JournalFilterSheetState extends State<_JournalFilterSheet> {
  late JournalEntryType? _type;
  late String? _mood;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _mood = widget.mood;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter catatan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<JournalEntryType?>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Jenis catatan'),
              items: const [
                DropdownMenuItem<JournalEntryType?>(
                  value: null,
                  child: Text('Semua jenis'),
                ),
                DropdownMenuItem(
                  value: JournalEntryType.free,
                  child: Text('Catatan bebas'),
                ),
                DropdownMenuItem(
                  value: JournalEntryType.guided,
                  child: Text('Refleksi terpandu'),
                ),
              ],
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _mood,
              decoration: const InputDecoration(labelText: 'Suasana'),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Semua suasana'),
                ),
                DropdownMenuItem(
                  value: 'very_low',
                  child: Text('Sangat rendah'),
                ),
                DropdownMenuItem(value: 'low', child: Text('Rendah')),
                DropdownMenuItem(value: 'neutral', child: Text('Netral')),
                DropdownMenuItem(value: 'good', child: Text('Baik')),
                DropdownMenuItem(
                  value: 'very_good',
                  child: Text('Sangat baik'),
                ),
              ],
              onChanged: (value) => setState(() => _mood = value),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(_JournalFilter(type: _type, mood: _mood)),
              child: const Text('Terapkan filter'),
            ),
          ],
        ),
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
