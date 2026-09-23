import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_date_controller.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/habits/dashboard_content.dart';
import 'package:prokopa/src/habits/dashboard_snapshot.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_form_screen.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/journal/journal_entry.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/sleep_input_sheet.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    this.progressStore,
    this.journalStore,
    this.wellbeingStore,
    this.dateController,
    this.profileName,
    this.refreshVersion = 0,
    this.onSettings,
    this.onManageHabits,
    this.onOpenJournal,
  });

  final HabitStore store;
  final ProgressStore? progressStore;
  final JournalStore? journalStore;
  final WellbeingStore? wellbeingStore;
  final AppDateController? dateController;
  final String? profileName;
  final int refreshVersion;
  final VoidCallback? onSettings;
  final VoidCallback? onManageHabits;
  final VoidCallback? onOpenJournal;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final AppDateController _dateController;
  late final bool _ownsDateController;
  DashboardSnapshot? _snapshot;
  String? _error;
  var _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _ownsDateController = widget.dateController == null;
    _dateController = widget.dateController ?? AppDateController();
    _dateController.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    _dateController.removeListener(_reload);
    if (_ownsDateController) {
      _dateController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _reload();
    }
  }

  Future<void> _reload() async {
    final version = ++_loadVersion;
    try {
      final today = await widget.store.loadToday();
      final progress = await widget.store.progress();
      final activeProgress = progress
          .where((item) => item.habit.state == HabitState.active)
          .toList();
      final monthStart = _dateController.displayedMonth;
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
      final month = await widget.progressStore?.snapshot(monthStart, monthEnd);
      final selectedDate = _dateController.selectedDate;
      JournalEntryPreview? journal;
      final journalStore = widget.journalStore;
      if (journalStore != null) {
        final entries = await journalStore.list(limit: 40);
        journal = entries
            .where((entry) => _sameDay(entry.date, selectedDate))
            .firstOrNull;
      }
      SleepRecord? sleep;
      final wellbeingStore = widget.wellbeingStore;
      if (wellbeingStore != null) {
        final records = await wellbeingStore.listSleep(
          from: selectedDate,
          to: selectedDate,
        );
        sleep = records.firstOrNull;
      }
      if (!mounted || version != _loadVersion) {
        return;
      }
      setState(() {
        _snapshot = DashboardSnapshot(
          completedToday: today.where((item) => item.isComplete).length,
          scheduledToday: today.length,
          habitProgress: List.unmodifiable(activeProgress),
          todayHabits: List.unmodifiable(today),
          month: month,
          journal: journal,
          sleep: sleep,
        );
        _error = null;
      });
    } catch (_) {
      if (mounted && version == _loadVersion) {
        setState(() => _error = 'Dashboard belum dapat dimuat. Coba lagi.');
      }
    }
  }

  Future<void> _toggleHabit(TodayHabit today) async {
    try {
      if (today.isComplete) {
        await widget.store.undo(today.habit);
      } else {
        await widget.store.complete(today.habit);
      }
      await _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status kebiasaan belum dapat diubah.')),
        );
      }
    }
  }

  Future<void> _manageHabit(Habit habit) async {
    final action = await showModalBottomSheet<_HabitAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const ExcludeSemantics(child: Icon(Icons.edit_outlined)),
              title: const Text('Edit'),
              onTap: () => Navigator.of(context).pop(_HabitAction.edit),
            ),
            ListTile(
              leading: ExcludeSemantics(
                child: Icon(
                  habit.state == HabitState.paused
                      ? Icons.play_arrow_outlined
                      : Icons.pause_outlined,
                ),
              ),
              title: Text(
                habit.state == HabitState.paused ? 'Lanjutkan' : 'Jeda',
              ),
              onTap: () => Navigator.of(context).pop(_HabitAction.pause),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Hapus',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => Navigator.of(context).pop(_HabitAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) {
      return;
    }
    switch (action) {
      case _HabitAction.edit:
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => HabitFormScreen(store: widget.store, habit: habit),
          ),
        );
        if (changed == true) {
          await _reload();
        }
      case _HabitAction.pause:
        if (habit.state == HabitState.paused) {
          await widget.store.resume(habit);
        } else {
          await widget.store.pause(habit);
        }
        await _reload();
      case _HabitAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus kebiasaan?'),
            content: Text(
              '${habit.draft.title} dan seluruh riwayatnya akan dihapus dari perangkat ini.',
            ),
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
          await widget.store.delete(habit);
          await _reload();
        }
    }
  }

  Future<void> _openSleep() async {
    final store = widget.wellbeingStore;
    if (store == null) {
      return;
    }
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SleepInputSheet(
        store: store,
        date: _dateController.selectedDate,
        record: _snapshot?.sleep,
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (snapshot == null && _error == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Memuat dashboard'),
        ),
      );
    }
    if (_error case final error?) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DashboardContent(
      snapshot: snapshot!,
      dateController: _dateController,
      profileName: widget.profileName,
      onRefresh: _reload,
      onSettings: widget.onSettings ?? () {},
      onToggleHabit: _toggleHabit,
      onManageHabit: _manageHabit,
      onManageHabits: widget.onManageHabits ?? () {},
      onOpenSleep: _openSleep,
      onOpenJournal: widget.onOpenJournal ?? () {},
    );
  }

  bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

enum _HabitAction { edit, pause, delete }
