import 'package:flutter/material.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/habits/today_screen.dart';
import 'package:prokopa/src/journal/journal_screen.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/insights/insights_screen.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_screen.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/notifications/notification_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';
import 'package:prokopa/src/progress/progress_screen.dart';
import 'package:prokopa/src/progress/progress_store.dart';

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
    this.backupService,
    this.appLockStore,
    this.onDataReset,
    this.notificationStore,
    this.notificationService,
    this.onProfileChanged,
  });

  final LocalProfile? profile;
  final ProfileStore? profileStore;
  final HabitStore? habitStore;
  final JournalStore? journalStore;
  final WellbeingStore? wellbeingStore;
  final ProgressStore? progressStore;
  final InsightStore? insightStore;
  final BackupService? backupService;
  final AppLockStore? appLockStore;
  final VoidCallback? onDataReset;
  final NotificationStore? notificationStore;
  final LocalNotificationService? notificationService;
  final ValueChanged<LocalProfile>? onProfileChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.today_outlined),
      selectedIcon: Icon(Icons.today),
      label: 'Today',
    ),
    NavigationDestination(
      icon: Icon(Icons.book_outlined),
      selectedIcon: Icon(Icons.book),
      label: 'Journal',
    ),
    NavigationDestination(
      icon: Icon(Icons.assessment_outlined),
      selectedIcon: Icon(Icons.assessment),
      label: 'Progress',
    ),
    NavigationDestination(
      icon: Icon(Icons.lightbulb_outline),
      selectedIcon: Icon(Icons.lightbulb),
      label: 'Insights',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  int _selectedIndex = 0;
  final _visited = <int>{0};

  @override
  Widget build(BuildContext context) {
    final screens = [
      if (widget.habitStore != null)
        TodayScreen(store: widget.habitStore!)
      else
        const _PlaceholderDestination(label: 'Today'),
      if (widget.journalStore != null && widget.wellbeingStore != null)
        JournalScreen(
          store: widget.journalStore!,
          wellbeingStore: widget.wellbeingStore!,
        )
      else
        const _PlaceholderDestination(label: 'Journal'),
      if (widget.progressStore != null && widget.wellbeingStore != null)
        ProgressScreen(
          store: widget.progressStore!,
          wellbeingStore: widget.wellbeingStore!,
        )
      else
        const _PlaceholderDestination(label: 'Progress'),
      if (widget.insightStore != null)
        InsightsScreen(store: widget.insightStore!)
      else
        const _PlaceholderDestination(label: 'Insights'),
      if (widget.profile != null &&
          widget.profileStore != null &&
          widget.onProfileChanged != null)
        ProfileScreen(
          profile: widget.profile!,
          store: widget.profileStore!,
          onChanged: widget.onProfileChanged!,
          backupService: widget.backupService,
          appLockStore: widget.appLockStore,
          onDataReset: widget.onDataReset,
          notificationStore: widget.notificationStore,
          notificationService: widget.notificationService,
        )
      else
        const _PlaceholderDestination(label: 'Profile'),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            for (var index = 0; index < screens.length; index++)
              _visited.contains(index)
                  ? screens[index]
                  : const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() {
          _selectedIndex = index;
          _visited.add(index);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : null,
        destinations: _destinations,
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
