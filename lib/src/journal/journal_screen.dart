import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_components.dart';
import 'package:prokopa/src/app/app_date_controller.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/journal/journal_archive_screen.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    required this.store,
    required this.wellbeingStore,
    required this.insightStore,
    this.dateController,
    this.onSettings,
    this.refreshVersion = 0,
  });

  final JournalStore store;
  final WellbeingStore wellbeingStore;
  final InsightStore insightStore;
  final AppDateController? dateController;
  final VoidCallback? onSettings;
  final int refreshVersion;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final AppDateController _dateController;
  late final bool _ownsDateController;
  final _body = TextEditingController();
  Timer? _autosave;
  JournalEntry? _entry;
  String? _mood;
  String? _error;
  var _loading = true;
  var _saving = false;
  var _saved = false;
  var _settingBody = false;
  var _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _ownsDateController = widget.dateController == null;
    _dateController = widget.dateController ?? AppDateController();
    _dateController.addListener(_dateChanged);
    _body.addListener(_bodyChanged);
    _load();
  }

  @override
  void didUpdateWidget(covariant JournalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _load();
    }
  }

  @override
  void dispose() {
    _autosave?.cancel();
    _dateController.removeListener(_dateChanged);
    if (_ownsDateController) {
      _dateController.dispose();
    }
    _body.dispose();
    super.dispose();
  }

  Future<void> _dateChanged() async {
    await _save();
    await _load();
  }

  Future<void> _load() async {
    final version = ++_loadVersion;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final selected = _dateController.selectedDate;
      final previews = await widget.store.list(limit: 200);
      final preview = previews
          .where((item) => _sameDay(item.date, selected))
          .firstOrNull;
      final entry = preview == null
          ? null
          : await widget.store.load(preview.id);
      if (!mounted || version != _loadVersion) {
        return;
      }
      _settingBody = true;
      _body.text = entry?.body ?? '';
      _settingBody = false;
      setState(() {
        _entry = entry;
        _mood = entry?.mood;
        _loading = false;
        _saving = false;
        _saved = entry != null;
      });
    } catch (_) {
      if (mounted && version == _loadVersion) {
        setState(() {
          _loading = false;
          _error = 'Catatan belum dapat dimuat. Coba lagi.';
        });
      }
    }
  }

  void _bodyChanged() {
    if (_settingBody) {
      return;
    }
    _autosave?.cancel();
    setState(() => _saved = false);
    _autosave = Timer(const Duration(milliseconds: 600), _save);
  }

  Future<JournalEntry> _ensureEntry() async {
    final current = _entry;
    if (current != null) {
      return current;
    }
    final created = await widget.store.createDraft(
      type: JournalEntryType.free,
      now: _dateController.selectedDate,
    );
    _entry = created;
    return created;
  }

  Future<void> _selectMood(String value) async {
    setState(() {
      _mood = value;
      _saved = false;
    });
    await _save();
  }

  Future<void> _save() async {
    _autosave?.cancel();
    if (_body.text.trim().isEmpty && _mood == null && _entry == null) {
      return;
    }
    if (_saving) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final entry = await _ensureEntry();
      final updated = entry.copyWith(
        body: _body.text,
        mood: _mood,
        clearMood: _mood == null,
        status: JournalEntryStatus.saved,
        updatedAt: DateTime.now(),
      );
      await widget.store.finish(updated);
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
          _error = 'Catatan belum tersimpan. Coba lagi.';
        });
      }
    }
  }

  Future<void> _openArchive() async {
    await _save();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => JournalArchiveScreen(
          store: widget.store,
          insightStore: widget.insightStore,
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 48),
          children: [
            AppPageHeader(
              title: 'Journal',
              subtitle: formatFullDate(_dateController.selectedDate),
              onSettings: widget.onSettings ?? () {},
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Semantics(
                  liveRegion: true,
                  label: _saving
                      ? 'Menyimpan catatan'
                      : _saved
                      ? 'Catatan tersimpan lokal'
                      : 'Catatan belum berubah',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_saving)
                        const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (_saved)
                        const ExcludeSemantics(
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.emerald700,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        _saving
                            ? 'Menyimpan'
                            : _saved
                            ? 'Tersimpan'
                            : 'Siap',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: _saved
                                  ? AppColors.emerald700
                                  : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _openArchive,
                  icon: const ExcludeSemantics(child: Icon(Icons.history)),
                  label: const Text('Riwayat jurnal'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _JournalDateBar(controller: _dateController),
            const SizedBox(height: 24),
            BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bagaimana perasaan Anda?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _MoodSelector(selected: _mood, onSelected: _selectMood),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Hari Ini',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Memuat catatan jurnal',
                        ),
                      ),
                    )
                  else
                    TextField(
                      controller: _body,
                      minLines: 12,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Tulis tentang hari Anda atau hal yang ingin diingat.',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.indigo500,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  if (_error case final error?) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _load,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExcludeSemantics(
                  child: Icon(Icons.lock_outline, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Catatan tersimpan otomatis di perangkat ini.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const moods = [
      ('very_low', 'Sangat buruk', Icons.sentiment_very_dissatisfied),
      ('low', 'Buruk', Icons.sentiment_dissatisfied),
      ('neutral', 'Netral', Icons.sentiment_neutral),
      ('good', 'Baik', Icons.sentiment_satisfied),
      ('very_good', 'Sangat baik', Icons.sentiment_very_satisfied),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 32) / 5;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final mood in moods)
              SizedBox(
                width: width,
                child: _MoodButton(
                  value: mood.$1,
                  label: mood.$2,
                  icon: mood.$3,
                  selected: selected == mood.$1,
                  onTap: () => onSelected(mood.$1),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? AppColors.indigo50 : Colors.transparent,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: selected
                    ? AppColors.indigo600
                    : theme.colorScheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: ExcludeSemantics(
              child: Icon(
                icon,
                size: 24,
                color: selected
                    ? AppColors.indigo700
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalDateBar extends StatelessWidget {
  const _JournalDateBar({required this.controller});

  final AppDateController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final active = controller.selectedDate;
        final textScaler = MediaQuery.textScalerOf(context);
        final chipHeight =
            16 + (textScaler.scale(18) * 1.3) + (textScaler.scale(11) * 1.3);
        final chipWidth = textScaler.scale(30) + 16;
        final dates = List.generate(
          15,
          (index) => active.add(Duration(days: index - 7)),
        );
        return SizedBox(
          height: chipHeight < 70 ? 70 : chipHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = dates[index];
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final selected = index == 7;
              final future = date.isAfter(today);
              return Semantics(
                button: true,
                selected: selected,
                enabled: !future,
                label: formatFullDate(date),
                child: InkWell(
                  onTap: future ? null : () => controller.selectDate(date),
                  borderRadius: AppRadius.mdBorder,
                  child: Ink(
                    width: chipWidth < 52 ? 52 : chipWidth,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.indigo600
                          : date == today
                          ? AppColors.indigo50
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(
                        color: selected
                            ? AppColors.indigo600
                            : date == today
                            ? AppColors.indigo200
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  color: selected ? Colors.white : null,
                                ),
                          ),
                          Text(
                            shortMonths[date.month - 1],
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: selected ? Colors.white : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
