import 'package:flutter/material.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_detail_screen.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    required this.store,
    this.reminderService,
    this.journalStore,
    this.wellbeingStore,
    this.profileName,
  });

  final HabitStore store;
  final HabitReminderService? reminderService;
  final JournalStore? journalStore;
  final WellbeingStore? wellbeingStore;
  final String? profileName;

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
          _error = 'Gagal memuat kebiasaan.';
        });
      }
    }
  }

  Future<void> _openQuickCreate() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _QuickHabitCreationSheet(store: widget.store),
    );
    if (created == true) {
      await _reload();
    }
  }

  Future<void> _toggleComplete(TodayHabit today) async {
    if (today.isComplete) {
      await widget.store.undo(today.habit);
    } else {
      await widget.store.complete(today.habit);
    }
    await _reload();
  }

  Future<void> _openDetail(Habit habit) async {
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: _reload,
            child: const Text('Coba lagi'),
          ),
        ),
      );
    }
    
    final habits = _habits!;
    final completed = habits.where((h) => h.isComplete).length;
    final total = habits.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: ProkopaSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: ProkopaSpacing.sm),
                      _Header(name: widget.profileName),
                      const SizedBox(height: ProkopaSpacing.xxxl),
                      _ProgressHero(progress: progress, completed: completed, total: total),
                      const SizedBox(height: ProkopaSpacing.xxxl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kebiasaan hari ini', style: Theme.of(context).textTheme.titleLarge),
                          IconButton(
                            onPressed: _openQuickCreate,
                            icon: const Icon(Icons.add_circle),
                            color: Theme.of(context).colorScheme.primary,
                            iconSize: 32,
                            tooltip: 'Buat kebiasaan',
                          ),
                        ],
                      ),
                      const SizedBox(height: ProkopaSpacing.md),
                    ],
                  ),
                ),
              ),
              if (habits.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyToday(onCreate: _openQuickCreate),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: ProkopaSpacing.xl),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final today = habits[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: ProkopaSpacing.md),
                          child: _HabitCard(
                            today: today,
                            onToggle: () => _toggleComplete(today),
                            onTap: () => _openDetail(today.habit),
                          ),
                        );
                      },
                      childCount: habits.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: ProkopaSpacing.huge)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.name});
  final String? name;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name != null ? '$_greeting, $name' : _greeting,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: ProkopaSpacing.xs),
        Text(
          _formatDate(DateTime.now()),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.progress, required this.completed, required this.total});
  final double progress;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isDone = total > 0 && completed == total;
    
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: ProkopaAnimation.normal,
                curve: ProkopaAnimation.curve,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  color: isDone ? ProkopaPalette.success : Theme.of(context).colorScheme.primary,
                ),
              ),
              Center(
                child: isDone
                  ? const Icon(Icons.star_rounded, color: ProkopaPalette.success, size: 36)
                  : Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ProkopaSpacing.xxl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDone 
                  ? 'Selesai semua!' 
                  : total == 0 
                    ? 'Siap dimulai' 
                    : 'Terus melangkah',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: ProkopaSpacing.xs),
              Text(
                total == 0 
                  ? 'Tambahkan kebiasaan pertama.' 
                  : '$completed selesai dari $total terjadwal.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ProkopaSpacing.xl, vertical: ProkopaSpacing.huge),
      child: Container(
        padding: ProkopaSpacing.cardPadding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: ProkopaRadius.xlBorder,
          border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: ProkopaSpacing.xxl),
            Text(
              'Ruang ini masih kosong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ProkopaSpacing.sm),
            Text(
              'Mulai dengan satu tindakan kecil hari ini.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ProkopaSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCreate,
                child: const Text('Buat Kebiasaan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.today,
    required this.onToggle,
    required this.onTap,
  });

  final TodayHabit today;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = today.isComplete;
    
    return AnimatedContainer(
      duration: ProkopaAnimation.fast,
      curve: ProkopaAnimation.curve,
      decoration: BoxDecoration(
        color: completed 
            ? Theme.of(context).colorScheme.surfaceContainerLow 
            : Theme.of(context).colorScheme.surface,
        borderRadius: ProkopaRadius.lgBorder,
        border: Border.all(
          color: completed 
              ? Theme.of(context).colorScheme.surfaceContainerHighest 
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: completed ? 1 : 1.5,
        ),
        boxShadow: completed ? [] : [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: ProkopaRadius.lgBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: ProkopaRadius.lgBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedSwitcher(
                    duration: ProkopaAnimation.fast,
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: completed
                        ? Icon(
                            Icons.check_circle_rounded,
                            key: const ValueKey('checked'),
                            size: 32,
                            color: ProkopaPalette.success,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            key: const ValueKey('unchecked'),
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                ),
                const SizedBox(width: ProkopaSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: ProkopaAnimation.fast,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: completed 
                              ? Theme.of(context).colorScheme.onSurfaceVariant 
                              : Theme.of(context).colorScheme.onSurface,
                          decoration: completed ? TextDecoration.lineThrough : null,
                        ),
                        child: Text(today.habit.draft.title),
                      ),
                      if (today.isWeeklyTarget) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${today.completedThisWeek}/${today.weeklyTarget} minggu ini',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickHabitCreationSheet extends StatefulWidget {
  const _QuickHabitCreationSheet({required this.store});
  final HabitStore store;

  @override
  State<_QuickHabitCreationSheet> createState() => _QuickHabitCreationSheetState();
}

class _QuickHabitCreationSheetState extends State<_QuickHabitCreationSheet> {
  final _title = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    
    setState(() => _saving = true);
    try {
      await widget.store.create(
        HabitDraft(
          title: title,
          frequency: HabitFrequency.daily,
          startDate: DateTime.now(),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan kebiasaan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        32,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apa yang ingin kamu biasakan?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: ProkopaSpacing.xl),
          TextField(
            controller: _title,
            autofocus: true,
            enabled: !_saving,
            textCapitalization: TextCapitalization.sentences,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(
              hintText: 'Contoh: Bangun jam 5 pagi',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: ProkopaSpacing.xxxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              const SizedBox(width: ProkopaSpacing.sm),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Menyimpan...' : 'Tambah'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
