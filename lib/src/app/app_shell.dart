import 'package:flutter/material.dart';
import 'package:prokopa/src/achievements/achievement_store.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:prokopa/src/habits/dashboard_screen.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/habits/today_screen.dart';
import 'package:prokopa/src/journal/journal_screen.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_screen.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';
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
    NavigationDestination(
      icon: ExcludeSemantics(child: Icon(Icons.dashboard_outlined)),
      selectedIcon: ExcludeSemantics(child: Icon(Icons.dashboard)),
      label: 'Home',
    ),
    NavigationDestination(
      icon: ExcludeSemantics(child: Icon(Icons.checklist_outlined)),
      selectedIcon: ExcludeSemantics(child: Icon(Icons.checklist)),
      label: 'Habits',
    ),
    NavigationDestination(
      icon: ExcludeSemantics(child: Icon(Icons.book_outlined)),
      selectedIcon: ExcludeSemantics(child: Icon(Icons.book)),
      label: 'Journal',
    ),
    NavigationDestination(
      icon: ExcludeSemantics(child: Icon(Icons.assessment_outlined)),
      selectedIcon: ExcludeSemantics(child: Icon(Icons.assessment)),
      label: 'Progress',
    ),
    NavigationDestination(
      icon: ExcludeSemantics(child: Icon(Icons.person_outline)),
      selectedIcon: ExcludeSemantics(child: Icon(Icons.person)),
      label: 'Profile',
    ),
  ];

  int _selectedIndex = 0;
  final _visited = <int>{0};
  final _refreshVersions = List<int>.filled(_destinations.length, 0);

  @override
  Widget build(BuildContext context) {
    final screens = [
      if (widget.habitStore != null)
        DashboardScreen(
          store: widget.habitStore!,
          profileName: widget.profile?.name,
          refreshVersion: _refreshVersions[0],
        )
      else
        const _PlaceholderDestination(label: 'Home'),
      if (widget.habitStore != null)
        TodayScreen(
          store: widget.habitStore!,
          reminderService: widget.habitReminderService,
          journalStore: widget.journalStore,
          wellbeingStore: widget.wellbeingStore,
          profileName: widget.profile?.name,
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
          refreshVersion: _refreshVersions[2],
        )
      else
        const _PlaceholderDestination(label: 'Journal'),
      if (widget.progressStore != null && widget.wellbeingStore != null)
        ProgressScreen(
          store: widget.progressStore!,
          wellbeingStore: widget.wellbeingStore!,
          habitStore: widget.habitStore,
        )
      else
        const _PlaceholderDestination(label: 'Progress'),
      if (widget.profile != null &&
          widget.profileStore != null &&
          widget.onProfileChanged != null)
        ProfileScreen(
          profile: widget.profile!,
          store: widget.profileStore!,
          onChanged: widget.onProfileChanged!,
          backupService: widget.backupService,
          onDataRestored: widget.onDataRestored,
          appLockStore: widget.appLockStore,
          onDataReset: widget.onDataReset,
          notificationStore: widget.notificationStore,
          notificationService: widget.notificationService,
          habitReminderService: widget.habitReminderService,
          achievementStore: widget.achievementStore,
        )
      else
        const _PlaceholderDestination(label: 'Profile'),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (var index = 0; index < screens.length; index++)
            _visited.contains(index) ? screens[index] : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() {
          _selectedIndex = index;
          _visited.add(index);
          _refreshVersions[index]++;
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
