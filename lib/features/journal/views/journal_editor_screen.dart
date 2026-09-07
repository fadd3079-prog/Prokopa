import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/shared/models/enums.dart';
import 'package:habitflow/core/services/gamification_service.dart';

/// Screen for creating or editing a journal entry.
class JournalEditorScreen extends ConsumerStatefulWidget {
  final int? journalId;

  const JournalEditorScreen({super.key, this.journalId});

  @override
  ConsumerState<JournalEditorScreen> createState() =>
      _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  final _contentController = TextEditingController();
  String _type = 'morning';
  MoodType _mood = MoodType.normal;
  double _energyLevel = 3.0;
  bool _isLoading = false;

  static const String _morningHint =
      'What do I want to achieve today?\nMy main priority:\nToday\'s intention:';
  static const String _eveningHint =
      'What went well today?\nWhat can I improve?\nWhat am I grateful for?';

  @override
  void initState() {
    super.initState();
    if (widget.journalId != null) {
      _loadJournal();
    }
  }

  Future<void> _loadJournal() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseProvider);
    try {
      final journal = await db.journalDao.getJournal(widget.journalId!);
      if (mounted) {
        setState(() {
          _contentController.text = journal.content;
          _type = journal.type;
          _mood = MoodType.fromScore(journal.mood);
          _energyLevel = journal.energyLevel.toDouble();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveJournal() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write something')));
      return;
    }

    final db = ref.read(databaseProvider);
    final moodScore = _mood.score;

    if (widget.journalId == null) {
      await db.journalDao.createJournal(
        JournalsCompanion.insert(
          content: content,
          mood: Value(moodScore),
          energyLevel: Value(_energyLevel.toInt()),
          type: Value(_type),
          date: DateTime.now(),
        ),
      );
      await ref.read(gamificationServiceProvider).evaluateJournalAchievements();
    } else {
      await db.journalDao.updateJournal(
        widget.journalId!,
        JournalsCompanion(
          content: Value(content),
          mood: Value(moodScore),
          energyLevel: Value(_energyLevel.toInt()),
          type: Value(_type),
        ),
      );
    }

    if (mounted) context.pop();
  }

  Future<void> _deleteJournal() async {
    if (widget.journalId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this journal entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.journalDao.deleteJournal(widget.journalId!);
      if (mounted) context.pop();
    }
  }

  String _getEmojiForMood(MoodType mood) => mood.emoji;

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.journalId != null;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteJournal,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type selector
            Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(
                  label: const Text('☀️ Morning'),
                  selected: _type == 'morning',
                  onSelected: (selected) {
                    if (selected) setState(() => _type = 'morning');
                  },
                ),
                ChoiceChip(
                  label: const Text('🌙 Evening'),
                  selected: _type == 'evening',
                  onSelected: (selected) {
                    if (selected) setState(() => _type = 'evening');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content editor
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 8,
              decoration: InputDecoration(
                hintText: _type == 'morning' ? _morningHint : _eveningHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Mood selector
            const Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: MoodType.values.map((mood) {
                final isSelected = _mood == mood;
                return GestureDetector(
                  onTap: () => setState(() => _mood = mood),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                                .withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          _getEmojiForMood(mood),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Energy level
            Text(
              'Energy Level: ${_energyLevel.round()}/5',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _energyLevel,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              label: _energyLevel.round().toString(),
              onChanged: (value) => setState(() => _energyLevel = value),
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _saveJournal,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Save Changes' : 'Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
