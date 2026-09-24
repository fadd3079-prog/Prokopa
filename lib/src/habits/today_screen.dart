import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:prokopa/src/app/app_components.dart';
import 'package:prokopa/src/app/app_date_controller.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_form_screen.dart';
import 'package:prokopa/src/habits/habit_list_screen.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';
import 'package:prokopa/src/wellbeing/sleep_input_sheet.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    required this.store,
    this.reminderService,
    this.journalStore,
    this.wellbeingStore,
    this.dateController,
    this.onSettings,
    this.profileName,
    this.refreshVersion = 0,
  });

  final HabitStore store;
  final HabitReminderService? reminderService;
  final JournalStore? journalStore;
  final WellbeingStore? wellbeingStore;
  final AppDateController? dateController;
  final VoidCallback? onSettings;
  final String? profileName;
  final int refreshVersion;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late final AppDateController _dateController;
  late final bool _ownsDateController;
  List<TodayHabit>? _habits;
  Map<String, HabitProgress> _progressByHabit = const {};
  SleepRecord? _sleep;
  var _loading = true;
  var _loadVersion = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ownsDateController = widget.dateController == null;
    _dateController = widget.dateController ?? AppDateController();
    _dateController.addListener(_reload);
    _reload();
  }

  @override
  void didUpdateWidget(covariant TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _reload();
    }
  }

  @override
  void dispose() {
    _dateController.removeListener(_reload);
    if (_ownsDateController) {
      _dateController.dispose();
    }
    super.dispose();
  }

  Future<void> _reload() async {
    final version = ++_loadVersion;
    if (mounted && _habits == null) {
      setState(() => _loading = true);
    }
    try {
      final date = _dateController.selectedDate;
      final habits = await widget.store.loadToday(now: date);
      final progress = await widget.store.progress(now: date);
      SleepRecord? sleep;
      final wellbeingStore = widget.wellbeingStore;
      if (wellbeingStore != null) {
        sleep = (await wellbeingStore.listSleep(
          from: date,
          to: date,
        )).firstOrNull;
      }
      if (mounted && version == _loadVersion) {
        setState(() {
          _habits = habits;
          _progressByHabit = {for (final item in progress) item.habit.id: item};
          _sleep = sleep;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted && version == _loadVersion) {
        setState(() {
          _loading = false;
          _error = 'Kebiasaan belum dapat dimuat. Coba lagi.';
        });
      }
    }
  }

  Future<void> _createHabit() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HabitFormScreen(
          store: widget.store,
          reminderService: widget.reminderService,
        ),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _toggleComplete(TodayHabit today) async {
    try {
      if (today.isComplete) {
        await widget.store.undo(
          today.habit,
          date: _dateController.selectedDate,
        );
      } else {
        await widget.store.complete(
          today.habit,
          date: _dateController.selectedDate,
        );
      }
      await HapticFeedback.selectionClick();
      await _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status pada tanggal ini belum dapat diubah.'),
          ),
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
            if (habit.draft.frequency != HabitFrequency.weeklyTarget)
              ListTile(
                leading: const ExcludeSemantics(
                  child: Icon(Icons.skip_next_outlined),
                ),
                title: const Text('Lewati hari ini'),
                onTap: () => Navigator.of(context).pop(_HabitAction.skip),
              ),
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.pause_outlined),
              ),
              title: const Text('Jeda'),
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
            builder: (_) => HabitFormScreen(
              store: widget.store,
              habit: habit,
              reminderService: widget.reminderService,
            ),
          ),
        );
        if (changed == true) {
          await _reload();
        }
      case _HabitAction.skip:
        await widget.store.skip(habit, date: _dateController.selectedDate);
        await _reload();
      case _HabitAction.pause:
        await widget.store.pause(habit);
        await widget.reminderService?.cancel(habit);
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
          await widget.reminderService?.cancel(habit);
          await widget.store.delete(habit);
          await _reload();
        }
    }
  }

  Future<void> _openHabitList() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => HabitListScreen(
          store: widget.store,
          reminderService: widget.reminderService,
        ),
      ),
    );
    await _reload();
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
        record: _sleep,
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Memuat kebiasaan'),
        ),
      );
    }
    if (_error case final error?) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _reload,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final habits = _habits!;
    final completed = habits.where((habit) => habit.isComplete).length;
    final progress = habits.isEmpty ? 0.0 : completed / habits.length;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HabitsHeader(
                        date: _dateController.selectedDate,
                        completed: completed,
                        total: habits.length,
                        onCreate: _createHabit,
                        onSettings: widget.onSettings ?? () {},
                      ),
                      const SizedBox(height: 24),
                      _DateBar(controller: _dateController),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (habits.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                    ),
                    child: _EmptyHabits(onCreate: _createHabit),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16,
                  ),
                  sliver: SliverList.separated(
                    itemCount: habits.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final today = habits[index];
                      return _HabitCard(
                        key: ValueKey(today.habit.id),
                        today: today,
                        progress: _progressByHabit[today.habit.id],
                        sortOrder: index.toDouble(),
                        onToggle: () => _toggleComplete(today),
                        onManage: () => _manageHabit(today.habit),
                      );
                    },
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _TodayProgress(progress: progress),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _HabitsSleepCard(record: _sleep, onTap: _openSleep),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 48),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: _openHabitList,
                      icon: const ExcludeSemantics(
                        child: Icon(Icons.tune, size: 18),
                      ),
                      label: const Text('Kelola semua kebiasaan'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitsHeader extends StatelessWidget {
  const _HabitsHeader({
    required this.date,
    required this.completed,
    required this.total,
    required this.onCreate,
    required this.onSettings,
  });

  final DateTime date;
  final int completed;
  final int total;
  final VoidCallback onCreate;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        return AppPageHeader(
          title: 'Habits',
          subtitle: '${formatFullDate(date)} · $completed/$total selesai',
          onSettings: onSettings,
          trailing: compact
              ? Semantics(
                  button: true,
                  label: 'Tambah kebiasaan',
                  child: IconButton.filled(
                    onPressed: onCreate,
                    tooltip: 'Tambah kebiasaan',
                    icon: const ExcludeSemantics(child: Icon(Icons.add)),
                  ),
                )
              : FilledButton.icon(
                  onPressed: onCreate,
                  icon: const ExcludeSemantics(
                    child: Icon(Icons.add, size: 18),
                  ),
                  label: const Text('Tambah'),
                ),
        );
      },
    );
  }
}

class _DateBar extends StatefulWidget {
  const _DateBar({required this.controller});

  final AppDateController controller;

  @override
  State<_DateBar> createState() => _DateBarState();
}

class _DateBarState extends State<_DateBar> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _center() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      final target = (_scrollController.position.maxScrollExtent / 2).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.fast,
        curve: AppMotion.curve,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final active = widget.controller.selectedDate;
        final textScaler = MediaQuery.textScalerOf(context);
        final chipHeight =
            32 +
            (textScaler.scale(10) * 1.3 * 2) +
            (textScaler.scale(18) * 1.3);
        final dates = List.generate(
          15,
          (index) => active.add(Duration(days: index - 7)),
        );
        _center();
        return SizedBox(
          height: chipHeight + 16,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            itemCount: dates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) => _DateChip(
              date: dates[index],
              selected: index == 7,
              onTap: () => widget.controller.selectDate(dates[index]),
            ),
          ),
        );
      },
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = date == today;
    final isFuture = date.isAfter(today);
    final theme = Theme.of(context);
    final scaledWidth = MediaQuery.textScalerOf(context).scale(52);
    return Semantics(
      button: true,
      selected: selected,
      enabled: !isFuture,
      label: formatFullDate(date),
      child: InkWell(
        onTap: isFuture ? null : onTap,
        borderRadius: AppRadius.mdBorder,
        child: Ink(
          width: scaledWidth < 52 ? 52 : scaledWidth,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.indigo600
                : isToday
                ? AppColors.indigo50
                : theme.colorScheme.surface,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: selected
                  ? AppColors.indigo600
                  : isToday
                  ? AppColors.indigo200
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _dayLabel(date.weekday),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: selected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${date.day}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    color: selected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  shortMonths[date.month - 1],
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: selected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _dayLabel(int weekday) =>
      const ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'][weekday - 1];
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    super.key,
    required this.today,
    required this.progress,
    required this.sortOrder,
    required this.onToggle,
    required this.onManage,
  });

  final TodayHabit today;
  final HabitProgress? progress;
  final double sortOrder;
  final VoidCallback onToggle;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final completed = today.isComplete;
    final accent = _habitColor(today.habit.draft.color);
    final metadata = today.isWeeklyTarget
        ? '${today.completedThisWeek}/${today.weeklyTarget} minggu ini'
        : _frequencyLabel(today.habit.draft.frequency);
    final streak = progress?.currentStreak ?? 0;
    return Semantics(
      button: !completed || !today.isWeeklyTarget,
      label: today.habit.draft.title,
      value: completed ? 'Selesai' : 'Belum selesai',
      hint: completed && today.isWeeklyTarget
          ? 'Target minggu ini tercapai. Tekan lama untuk mengelola.'
          : 'Ketuk untuk mengubah status. Tekan lama untuk mengelola.',
      sortKey: OrdinalSortKey(sortOrder),
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.fast,
        decoration: BoxDecoration(
          color: completed
              ? AppColors.emerald50
              : Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: completed
                ? AppColors.emerald100
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.lgBorder,
          child: InkWell(
            onTap: completed && today.isWeeklyTarget ? null : onToggle,
            onLongPress: onManage,
            borderRadius: AppRadius.lgBorder,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const SizedBox(width: 4, height: 40),
                    ),
                    const SizedBox(width: 12),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.emerald600
                            : Colors.transparent,
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(
                          color: completed
                              ? AppColors.emerald600
                              : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: SizedBox.square(
                        dimension: 36,
                        child: Icon(
                          completed ? Icons.check : Icons.circle_outlined,
                          size: 20,
                          color: completed
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            today.habit.draft.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  decoration: completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            metadata,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (streak > 0) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.local_fire_department_outlined,
                        size: 16,
                        color: AppColors.amber700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$streak',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.amber700),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _habitColor(String? value) {
    if (value == null) {
      return AppColors.indigo500;
    }
    final normalized = value.replaceFirst('#', '');
    final parsed = int.tryParse(normalized, radix: 16);
    return parsed == null ? AppColors.indigo500 : Color(0xFF000000 | parsed);
  }

  String _frequencyLabel(HabitFrequency frequency) => switch (frequency) {
    HabitFrequency.daily => 'Setiap hari',
    HabitFrequency.specificDays => 'Hari tertentu',
    HabitFrequency.weeklyTarget => 'Target mingguan',
  };
}

class _TodayProgress extends StatelessWidget {
  const _TodayProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return BentoCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Progress Hari Ini',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text('$percent%', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppMotion.progress,
                curve: AppMotion.curve,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  color: AppColors.emerald500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsSleepCard extends StatelessWidget {
  const _HabitsSleepCard({required this.record, required this.onTap});

  final SleepRecord? record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final detail = record == null
        ? 'Ketuk untuk mencatat tidur'
        : '${record!.durationMinutes ~/ 60}j ${record!.durationMinutes % 60}m';
    return Semantics(
      button: true,
      label: 'Sleep Tracker, $detail',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? const [AppColors.indigo50, AppColors.purple50]
                  : const [Color(0xFF24214A), Color(0xFF34204F)],
            ),
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.purple200),
          ),
          child: ExcludeSemantics(
            child: Row(
              children: [
                const Icon(
                  Icons.bedtime_outlined,
                  size: 24,
                  color: AppColors.violet600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Tracker',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  const _EmptyHabits({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.track_changes_outlined, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada kebiasaan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan satu kebiasaan untuk mulai mencatat progress.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onCreate,
            child: const Text('Tambah kebiasaan'),
          ),
        ],
      ),
    );
  }
}

enum _HabitAction { edit, skip, pause, delete }
