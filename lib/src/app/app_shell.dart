import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:prokopa/src/achievements/achievement_store.dart';
import 'package:prokopa/src/app/app_date_controller.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:prokopa/src/habits/dashboard_screen.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/habits/today_screen.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/journal/journal_screen.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/notifications/notification_store.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_screen.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:prokopa/src/progress/progress_screen.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.profile,
    this.profileStore,
    this.habitStore,
    this.journalStore,
    this.wellbeingStore,
    this.progressStore,
    this.insightStore,
    this.achievementStore,
    this.backupService,
    this.appLockStore,
    this.onDataReset,
    this.onDataRestored,
    this.notificationStore,
    this.notificationService,
    this.habitReminderService,
    this.onProfileChanged,
  });

  final LocalProfile? profile;
  final ProfileStore? profileStore;
  final HabitStore? habitStore;
  final JournalStore? journalStore;
  final WellbeingStore? wellbeingStore;
  final ProgressStore? progressStore;
  final InsightStore? insightStore;
  final AchievementStore? achievementStore;
  final BackupService? backupService;
  final AppLockStore? appLockStore;
  final VoidCallback? onDataReset;
  final Future<String?> Function()? onDataRestored;
  final NotificationStore? notificationStore;
  final LocalNotificationService? notificationService;
  final HabitReminderService? habitReminderService;
  final ValueChanged<LocalProfile>? onProfileChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _destinations = [
    _AppDestination(
      label: 'Dashboard',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
    _AppDestination(
      label: 'Habits',
      icon: Icons.track_changes_outlined,
      selectedIcon: Icons.track_changes,
    ),
    _AppDestination(
      label: 'Journal',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
    ),
    _AppDestination(
      label: 'Stats',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
  ];

  late final AppDateController _dateController;
  int _selectedIndex = 0;
  final _visited = <int>{0};
  final _refreshVersions = List<int>.filled(_destinations.length, 0);

  @override
  void initState() {
    super.initState();
    _dateController = AppDateController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
      _visited.add(index);
      _refreshVersions[index]++;
    });
  }

  Future<void> _openSettings() async {
    final profile = widget.profile;
    final store = widget.profileStore;
    final onChanged = widget.onProfileChanged;
    if (profile == null || store == null || onChanged == null) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          profile: profile,
          store: store,
          onChanged: onChanged,
          backupService: widget.backupService,
          onDataRestored: widget.onDataRestored,
          appLockStore: widget.appLockStore,
          onDataReset: widget.onDataReset,
          notificationStore: widget.notificationStore,
          notificationService: widget.notificationService,
          habitReminderService: widget.habitReminderService,
          achievementStore: widget.achievementStore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      if (widget.habitStore != null)
        DashboardScreen(
          store: widget.habitStore!,
          progressStore: widget.progressStore,
          journalStore: widget.journalStore,
          wellbeingStore: widget.wellbeingStore,
          dateController: _dateController,
          profileName: widget.profile?.name,
          refreshVersion: _refreshVersions[0],
          onSettings: _openSettings,
          onManageHabits: () => _selectDestination(1),
          onOpenJournal: () => _selectDestination(2),
        )
      else
        const _PlaceholderDestination(label: 'Dashboard'),
      if (widget.habitStore != null)
        TodayScreen(
          store: widget.habitStore!,
          reminderService: widget.habitReminderService,
          journalStore: widget.journalStore,
          wellbeingStore: widget.wellbeingStore,
          dateController: _dateController,
          onSettings: _openSettings,
          refreshVersion: _refreshVersions[1],
        )
      else
        const _PlaceholderDestination(label: 'Habits'),
      if (widget.journalStore != null &&
          widget.wellbeingStore != null &&
          widget.insightStore != null)
        JournalScreen(
          store: widget.journalStore!,
          wellbeingStore: widget.wellbeingStore!,
          insightStore: widget.insightStore!,
          dateController: _dateController,
          onSettings: _openSettings,
          refreshVersion: _refreshVersions[2],
        )
      else
        const _PlaceholderDestination(label: 'Journal'),
      if (widget.progressStore != null && widget.wellbeingStore != null)
        ProgressScreen(
          store: widget.progressStore!,
          wellbeingStore: widget.wellbeingStore!,
          habitStore: widget.habitStore,
          dateController: _dateController,
          onSettings: _openSettings,
          refreshVersion: _refreshVersions[3],
        )
      else
        const _PlaceholderDestination(label: 'Stats'),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (var index = 0; index < screens.length; index++)
            _visited.contains(index) ? screens[index] : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _BottomNavigation(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onSelected: _selectDestination,
      ),
    );
  }
}

class _AppDestination {
  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_AppDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final textScale = textScaler.scale(1);
    final navigationHeight = 68 + ((textScale - 1) * 58);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: navigationHeight < 68 ? 68 : navigationHeight,
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _NavigationItem(
                    destination: destinations[index],
                    selected: selectedIndex == index,
                    sortOrder: index.toDouble(),
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.selected,
    required this.sortOrder,
    required this.onTap,
  });

  final _AppDestination destination;
  final bool selected;
  final double sortOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      key: ValueKey('app-nav-${destination.label}'),
      button: true,
      selected: selected,
      label: destination.label,
      sortKey: OrdinalSortKey(sortOrder),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppMotion.fast,
                  width: selected ? 22 : 4,
                  height: 3,
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 5),
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 22,
                  color: color,
                ),
                const SizedBox(height: 3),
                Text(
                  destination.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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

class _PlaceholderDestination extends StatelessWidget {
  const _PlaceholderDestination({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        header: true,
        child: Text(label, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}
