import 'package:flutter/material.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/journal/journal_body.dart';
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
    required this.insightStore,
    this.refreshVersion = 0,
  });

  final JournalStore store;
  final WellbeingStore wellbeingStore;
  final InsightStore insightStore;
  final int refreshVersion;

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

  @override
  void didUpdateWidget(covariant JournalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _reload();
    }
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
            padding: const EdgeInsets.symmetric(
              horizontal: ProkopaSpacing.xl,
              vertical: ProkopaSpacing.xxl,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Jurnal',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: ProkopaSpacing.xs),
                      Text(
                        _formatDate(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ProkopaSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: ProkopaRadius.mdBorder,
                  ),
                  child: PopupMenuButton<JournalEntryType>(
                    tooltip: 'Buat catatan',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
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
                    iconColor: Theme.of(context).colorScheme.onPrimary,
                    icon: const ExcludeSemantics(child: Icon(Icons.add)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: JournalBody(
              entries: entries,
              error: _error,
              hasMore: _hasMore,
              isLoadingMore: _loadingMore,
              insightStore: widget.insightStore,
              refreshVersion: widget.refreshVersion,
              onRefresh: _reload,
              onLoadMore: _loadMore,
              onOpen: _open,
              onCreate: _create,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
