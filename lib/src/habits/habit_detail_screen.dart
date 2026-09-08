import 'package:flutter/material.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_form_screen.dart';
import 'package:prokopa/src/habits/habit_store.dart';

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({
    super.key,
    required this.store,
    required this.habit,
  });

  final HabitStore store;
  final Habit habit;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit _habit;
  List<HabitExecution>? _history;
  var _streak = 0;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _reload();
  }

  Future<void> _reload() async {
    try {
      final current = (await widget.store.list(includeArchived: true))
          .where((habit) => habit.id == _habit.id)
          .firstOrNull;
      if (current == null) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
        return;
      }
      final history = await widget.store.history(current);
      final streak = await widget.store.dailyStreak(current);
      if (mounted) {
        setState(() {
          _habit = current;
          _history = history;
          _streak = streak;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Detail kebiasaan belum dapat dimuat. Coba lagi.';
        });
      }
    }
  }

  Future<void> _edit() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HabitFormScreen(store: widget.store, habit: _habit),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _pauseOrResume() async {
    if (_habit.state == HabitState.paused) {
      await widget.store.resume(_habit);
    } else {
      await widget.store.pause(_habit);
    }
    await _reload();
  }

  Future<void> _archive() async {
    await widget.store.archive(_habit);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kebiasaan?'),
        content: const Text(
          'Riwayat kebiasaan ini akan dihapus dari perangkat ini.',
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
      await widget.store.delete(_habit);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: FilledButton(
            onPressed: _reload,
            child: const Text('Coba lagi'),
          ),
        ),
      );
    }
    final history = _history!;
    final hasLapse = history.any(
      (record) => record.state == HabitExecutionState.missed,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebiasaan'),
        actions: [
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Ubah kebiasaan',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'pause':
                  _pauseOrResume();
                case 'archive':
                  _archive();
                case 'delete':
                  _delete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pause',
                child: Text(
                  _habit.state == HabitState.paused ? 'Lanjutkan' : 'Jeda',
                ),
              ),
              const PopupMenuItem(value: 'archive', child: Text('Arsipkan')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _habit.draft.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_habit.draft.purpose != null) ...[
              const SizedBox(height: 8),
              Text(_habit.draft.purpose!),
            ],
            const SizedBox(height: 20),
            Text('Jadwal', style: Theme.of(context).textTheme.titleMedium),
            Text(_scheduleText(_habit.draft)),
            if (_habit.draft.cueWhen != null ||
                _habit.draft.cueWhere != null ||
                _habit.draft.cueAction != null) ...[
              const SizedBox(height: 20),
              Text('Cue', style: Theme.of(context).textTheme.titleMedium),
              if (_habit.draft.cueWhen != null)
                Text('Kapan: ${_habit.draft.cueWhen}'),
              if (_habit.draft.cueWhere != null)
                Text('Di mana: ${_habit.draft.cueWhere}'),
              if (_habit.draft.cueAction != null)
                Text('Tindakan: ${_habit.draft.cueAction}'),
            ],
            if (_habit.draft.minimumVersion != null) ...[
              const SizedBox(height: 20),
              Text(
                'Versi minimum',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(_habit.draft.minimumVersion!),
            ],
            const SizedBox(height: 20),
            Text('Konsistensi', style: Theme.of(context).textTheme.titleMedium),
            Text(
              _habit.draft.frequency == HabitFrequency.weeklyTarget
                  ? '${history.where((record) => record.state == HabitExecutionState.completed).length} repetisi tercatat'
                  : 'Streak saat ini: $_streak',
            ),
            if (hasLapse) ...[
              const SizedBox(height: 20),
              Text('Kembali', style: Theme.of(context).textTheme.titleMedium),
              const Text(
                'Kamu dapat melanjutkan, menyesuaikan kebiasaan, atau menjedakannya.',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _edit,
                    child: const Text('Ubah kebiasaan'),
                  ),
                  OutlinedButton(
                    onPressed: _pauseOrResume,
                    child: const Text('Jeda'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Text('Riwayat', style: Theme.of(context).textTheme.titleMedium),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Belum ada catatan pelaksanaan.'),
              )
            else
              for (final record in history.take(30))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localDateKey(record.plannedDate)),
                  trailing: Text(_stateText(record.state)),
                ),
          ],
        ),
      ),
    );
  }

  String _scheduleText(HabitDraft draft) => switch (draft.frequency) {
    HabitFrequency.daily => 'Setiap hari',
    HabitFrequency.specificDays => 'Hari tertentu',
    HabitFrequency.weeklyTarget => '${draft.weeklyTarget} kali per minggu',
  };

  String _stateText(HabitExecutionState state) => switch (state) {
    HabitExecutionState.completed => 'Selesai',
    HabitExecutionState.skipped => 'Dilewati',
    HabitExecutionState.missed => 'Terlewat',
  };
}
