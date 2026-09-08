import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';

class JournalEditorScreen extends StatefulWidget {
  const JournalEditorScreen({
    super.key,
    required this.store,
    required this.entry,
  });

  final JournalStore store;
  final JournalEntry entry;

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  static const _prompts = [
    'Apa yang sedang kamu alami hari ini?',
    'Apa yang membantu atau mempersulitmu?',
    'Apa langkah ringan yang ingin kamu coba berikutnya?',
  ];

  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _tags;
  late JournalEntry _entry;
  Timer? _autosave;
  var _saving = false;
  var _saved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _title = TextEditingController(text: _entry.title ?? '');
    _body = TextEditingController(text: _currentBody());
    _tags = TextEditingController(text: _entry.tags.join(', '));
    _title.addListener(_scheduleAutosave);
    _body.addListener(_scheduleAutosave);
    _tags.addListener(_scheduleAutosave);
  }

  @override
  void dispose() {
    _autosave?.cancel();
    unawaited(widget.store.save(_updated(status: JournalEntryStatus.draft)));
    _title.dispose();
    _body.dispose();
    _tags.dispose();
    super.dispose();
  }

  String _currentBody() {
    if (_entry.type == JournalEntryType.guided) {
      return _entry.guidedResponses[_prompts[_entry.promptIndex]] ?? '';
    }
    return _entry.body;
  }

  void _scheduleAutosave() {
    _autosave?.cancel();
    _autosave = Timer(const Duration(milliseconds: 600), _saveDraft);
  }

  JournalEntry _updated({JournalEntryStatus? status}) {
    final guided = {..._entry.guidedResponses};
    final body = _body.text;
    if (_entry.type == JournalEntryType.guided) {
      guided[_prompts[_entry.promptIndex]] = body;
    }
    return _entry.copyWith(
      title: _title.text,
      body: _entry.type == JournalEntryType.guided
          ? guided.values.join('\n\n')
          : body,
      tags: _tags.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList(),
      guidedResponses: guided,
      status: status,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _saveDraft() async {
    if (_saving) {
      return;
    }
    setState(() {
      _saving = true;
      _saved = false;
      _error = null;
    });
    try {
      final updated = _updated(status: JournalEntryStatus.draft);
      await widget.store.save(updated);
      if (mounted) {
        setState(() {
          _entry = updated;
          _saving = false;
          _saved = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Draf belum tersimpan. Coba lagi.';
        });
      }
    }
  }

  Future<void> _finish() async {
    _autosave?.cancel();
    try {
      final updated = _updated(status: JournalEntryStatus.saved);
      await widget.store.finish(updated);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Catatan belum tersimpan. Coba lagi.');
      }
    }
  }

  Future<void> _changePrompt(int delta) async {
    await _saveDraft();
    final next = (_entry.promptIndex + delta).clamp(0, _prompts.length - 1);
    setState(() {
      _entry = _entry.copyWith(promptIndex: next);
      _body.text = _currentBody();
    });
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus catatan?'),
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
      await widget.store.delete(_entry.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guided = _entry.type == JournalEntryType.guided;
    return Scaffold(
      appBar: AppBar(
        title: Text(guided ? 'Refleksi terpandu' : 'Catatan'),
        actions: [
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus catatan',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (guided)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Text(
                  _prompts[_entry.promptIndex],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: 'Judul opsional',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _body,
                    minLines: 10,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: guided
                          ? 'Tulis jika ingin.'
                          : 'Tulis catatanmu di sini.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tags,
                    decoration: const InputDecoration(
                      labelText: 'Tag opsional, pisahkan dengan koma',
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (guided)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _entry.promptIndex == 0
                          ? null
                          : () => _changePrompt(-1),
                      child: const Text('Kembali'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _entry.promptIndex == _prompts.length - 1
                          ? null
                          : () => _changePrompt(1),
                      child: const Text('Lanjutkan'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _saving
                          ? 'Menyimpan'
                          : _saved
                          ? 'Tersimpan lokal'
                          : 'Draf',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  FilledButton(onPressed: _finish, child: const Text('Simpan')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
