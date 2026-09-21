import 'package:flutter/material.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_detail_screen.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({
    super.key,
    required this.store,
    this.reminderService,
  });

  final HabitStore store;
  final HabitReminderService? reminderService;

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  List<Habit>? _habits;
  HabitState? _filter;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final habits = await widget.store.list(includeArchived: true);
      if (mounted) {
        setState(() {
          _habits = habits;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Kebiasaan belum dapat dimuat. Coba lagi.');
      }
    }
  }

  Future<void> _open(Habit habit) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HabitDetailScreen(
          store: widget.store,
          habit: habit,
          reminderService: widget.reminderService,
        ),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _habits;
    final visible = habits
        ?.where((habit) => _filter == null || habit.state == _filter)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola kebiasaan')),
      body: SafeArea(
        child: habits == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: FilledButton(
                  onPressed: _reload,
                  child: const Text('Coba lagi'),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: visible!.length + 1,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          (null, 'Semua'),
                          (HabitState.active, 'Aktif'),
                          (HabitState.paused, 'Dijeda'),
                          (HabitState.archived, 'Diarsipkan'),
                        ]
                            .map(
                              (option) => FilterChip(
                                label: Text(option.$2),
                                selected: _filter == option.$1,
                                onSelected: (_) =>
                                    setState(() => _filter = option.$1),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }
                  final habit = visible[index - 1];
                  return ListTile(
                    onTap: () => _open(habit),
                    title: Text(habit.draft.title),
                    subtitle: Text(_stateLabel(habit.state)),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              ),
      ),
    );
  }

  String _stateLabel(HabitState state) => switch (state) {
    HabitState.created => 'Dibuat',
    HabitState.active => 'Aktif',
    HabitState.paused => 'Dijeda',
    HabitState.archived => 'Diarsipkan',
  };
}
