import 'package:flutter/material.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/journal/journal_body.dart';
import 'package:prokopa/src/journal/journal_editor_screen.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';

class JournalArchiveScreen extends StatefulWidget {
  const JournalArchiveScreen({
    super.key,
    required this.store,
    required this.insightStore,
  });

  final JournalStore store;
  final InsightStore insightStore;

  @override
  State<JournalArchiveScreen> createState() => _JournalArchiveScreenState();
}

class _JournalArchiveScreenState extends State<JournalArchiveScreen> {
  static const _pageSize = 40;
  final _search = TextEditingController();
  List<JournalEntryPreview>? _entries;
  JournalEntryType? _type;
  String? _mood;
  String? _error;
  var _hasMore = false;
  var _loadingMore = false;
  var _refreshVersion = 0;
  var _loadVersion = 0;

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
      if (!mounted || version != _loadVersion) {
        return;
      }
      setState(() {
        _entries = entries.take(_pageSize).toList();
        _hasMore = entries.length > _pageSize;
        _loadingMore = false;
        _error = null;
      });
    } catch (_) {
      if (mounted && version == _loadVersion) {
        setState(() {
          _loadingMore = false;
          _error = 'Riwayat jurnal belum dapat dimuat.';
        });
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
          _error = 'Catatan berikutnya belum dapat dimuat.';
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
        if (mounted) {
          setState(() => _refreshVersion++);
        }
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
        if (mounted) {
          setState(() => _refreshVersion++);
        }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat jurnal'),
        actions: [
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
            icon: const ExcludeSemantics(child: Icon(Icons.add)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      labelText: 'Cari catatan',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final filters = [
                        DropdownButtonFormField<JournalEntryType?>(
                          isExpanded: true,
                          initialValue: _type,
                          decoration: const InputDecoration(labelText: 'Jenis'),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Semua')),
                            DropdownMenuItem(
                              value: JournalEntryType.free,
                              child: Text('Catatan bebas'),
                            ),
                            DropdownMenuItem(
                              value: JournalEntryType.guided,
                              child: Text('Refleksi terpandu'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _type = value);
                            _reload();
                          },
                        ),
                        DropdownButtonFormField<String?>(
                          isExpanded: true,
                          initialValue: _mood,
                          decoration: const InputDecoration(
                            labelText: 'Suasana',
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Semua')),
                            DropdownMenuItem(
                              value: 'very_low',
                              child: Text('Sangat buruk'),
                            ),
                            DropdownMenuItem(
                              value: 'low',
                              child: Text('Buruk'),
                            ),
                            DropdownMenuItem(
                              value: 'neutral',
                              child: Text('Netral'),
                            ),
                            DropdownMenuItem(
                              value: 'good',
                              child: Text('Baik'),
                            ),
                            DropdownMenuItem(
                              value: 'very_good',
                              child: Text('Sangat baik'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _mood = value);
                            _reload();
                          },
                        ),
                      ];
                      if (constraints.maxWidth < 480) {
                        return Column(
                          children: [
                            filters.first,
                            const SizedBox(height: 12),
                            filters.last,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: filters.first),
                          const SizedBox(width: 12),
                          Expanded(child: filters.last),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: JournalBody(
                entries: _entries,
                error: _error,
                hasMore: _hasMore,
                isLoadingMore: _loadingMore,
                insightStore: widget.insightStore,
                refreshVersion: _refreshVersion,
                onRefresh: _refreshAll,
                onLoadMore: _loadMore,
                onOpen: _open,
                onCreate: _create,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAll() async {
    await _reload();
    if (mounted) {
      setState(() => _refreshVersion++);
    }
  }
}
