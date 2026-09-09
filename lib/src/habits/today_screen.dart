import 'package:flutter/material.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_detail_screen.dart';
import 'package:prokopa/src/habits/habit_form_screen.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/app/prokopa_logo.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key, required this.store});

  final HabitStore store;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<TodayHabit>? _habits;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final habits = await widget.store.loadToday();
      if (mounted) {
        setState(() {
          _habits = habits;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Kebiasaan hari ini belum dapat dimuat. Coba lagi.';
        });
      }
    }
  }

  Future<void> _openForm([Habit? habit]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HabitFormScreen(store: widget.store, habit: habit),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _complete(TodayHabit today) async {
    try {
      await widget.store.complete(today.habit);
      await _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kebiasaan belum tersimpan. Coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _skip(TodayHabit today, String reason) async {
    try {
      await widget.store.skip(today.habit, reason: reason);
      await _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status dilewati belum tersimpan. Coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _openDetail(Habit habit) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HabitDetailScreen(store: widget.store, habit: habit),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return SafeArea(
        child: Center(
          child: FilledButton(
            onPressed: _reload,
            child: const Text('Coba lagi'),
          ),
        ),
      );
    }
    final habits = _habits!;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hari ini', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        habits.isEmpty
                            ? 'Belum ada kebiasaan yang terjadwal.'
                            : '${habits.where((habit) => habit.isComplete).length} dari ${habits.length} selesai.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const ProkopaLogo(height: 32),
              ],
            ),
            const SizedBox(height: 20),
            if (habits.isEmpty)
              _EmptyToday(onCreate: _openForm)
            else
              for (final today in habits)
                _TodayHabitTile(
                  today: today,
                  onComplete: () => _complete(today),
                  onSkip: (reason) => _skip(today, reason),
                  onOpen: () => _openDetail(today.habit),
                ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openForm,
              icon: const Icon(Icons.add),
              label: const Text('Buat kebiasaan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mulai dengan satu tindakan kecil.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Buat kebiasaan yang ingin kamu lakukan secara lokal di Prokopa.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onCreate,
            child: const Text('Buat kebiasaan'),
          ),
        ],
      ),
    );
  }
}

class _TodayHabitTile extends StatelessWidget {
  const _TodayHabitTile({
    required this.today,
    required this.onComplete,
    required this.onSkip,
    required this.onOpen,
  });

  final TodayHabit today;
  final VoidCallback onComplete;
  final ValueChanged<String> onSkip;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final completed = today.isComplete;
    final skipped = today.execution?.state == HabitExecutionState.skipped;
    final subtitle = today.isWeeklyTarget
        ? '${today.completedThisWeek}/${today.weeklyTarget} minggu ini'
        : completed
        ? 'Selesai'
        : skipped
        ? 'Dilewati'
        : 'Terjadwal';
    return Column(
      children: [
        ListTile(
          onTap: onOpen,
          title: Text(
            today.habit.draft.title,
            style: completed
                ? TextStyle(color: Theme.of(context).colorScheme.outline)
                : null,
          ),
          subtitle: Text(subtitle),
          trailing: completed
              ? const Icon(Icons.check_circle, semanticLabel: 'Selesai')
              : skipped
              ? const Icon(
                  Icons.remove_circle_outlined,
                  semanticLabel: 'Dilewati',
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!today.isWeeklyTarget)
                      PopupMenuButton<String>(
                        tooltip: 'Tandai dilewati',
                        onSelected: onSkip,
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'sick', child: Text('Sakit')),
                          PopupMenuItem(
                            value: 'travel',
                            child: Text('Perjalanan'),
                          ),
                          PopupMenuItem(
                            value: 'rest',
                            child: Text('Istirahat'),
                          ),
                          PopupMenuItem(
                            value: 'schedule_changed',
                            child: Text('Jadwal berubah'),
                          ),
                          PopupMenuItem(value: 'other', child: Text('Lainnya')),
                        ],
                      ),
                    IconButton(
                      tooltip: 'Selesaikan ${today.habit.draft.title}',
                      onPressed: onComplete,
                      icon: const Icon(Icons.radio_button_unchecked),
                    ),
                  ],
                ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
