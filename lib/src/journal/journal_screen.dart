import 'package:flutter/material.dart';
import 'package:prokopa/src/journal/journal_editor_screen.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';
import 'package:prokopa/src/app/app_theme.dart';

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
        setState(() => _error = 'Gagal memuat catatan.');
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
          _error = 'Gagal memuat catatan berikutnya.';
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

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ProkopaSpacing.xl, vertical: ProkopaSpacing.xxl),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Jurnal',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
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
                  icon: const Icon(Icons.add_circle, size: 32),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
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
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: ProkopaSpacing.xl),
                    itemCount: entries.length + (_hasMore || _loadingMore ? 1 : 0),
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: ProkopaSpacing.md),
                        child: _JournalCard(
                          entry: entry,
                          onTap: () => _open(entry),
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

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry, required this.onTap});

  final JournalEntryPreview entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = entry.title?.isNotEmpty == true ? entry.title! : 'Tanpa judul';
    final preview = entry.bodyPreview.isEmpty ? 'Draf kosong' : entry.bodyPreview.replaceAll('\n', ' ');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: ProkopaRadius.lgBorder,
        child: Padding(
          padding: ProkopaSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.status == JournalEntryStatus.draft)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Draf',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: ProkopaSpacing.sm),
              Text(
                preview,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
    return Padding(
      padding: ProkopaSpacing.screenPadding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: ProkopaSpacing.xxxl),
            Text(
              'Belum ada catatan.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: ProkopaSpacing.sm),
            Text(
              'Tulis bebas atau gunakan satu pertanyaan sebagai awal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ProkopaSpacing.xxxl),
            FilledButton.icon(
              onPressed: () => onCreate(JournalEntryType.free),
              icon: const Icon(Icons.edit),
              label: const Text('Tulis Jurnal'),
            ),
          ],
        ),
      ),
    );
  }
}
