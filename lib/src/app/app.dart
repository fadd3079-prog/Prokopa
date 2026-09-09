import 'package:flutter/material.dart';
import 'package:prokopa/src/achievements/achievement_store.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:prokopa/src/app/app_shell.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/onboarding/onboarding_flow.dart';
import 'package:prokopa/src/habits/habit_store.dart';
import 'package:prokopa/src/journal/journal_store.dart';
import 'package:prokopa/src/wellbeing/wellbeing_store.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:prokopa/src/progress/progress_store.dart';
import 'package:prokopa/src/insights/insight_store.dart';
import 'package:prokopa/src/privacy/app_lock_screen.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';
import 'package:prokopa/src/notifications/notification_store.dart';
import 'package:sqflite/sqflite.dart';

class ProkopaApp extends StatefulWidget {
  const ProkopaApp({
    super.key,
    this.database,
    this.enableFeatureScreens = true,
  });

  final Database? database;
  final bool enableFeatureScreens;

  @override
  State<ProkopaApp> createState() => _ProkopaAppState();
}

class _ProkopaAppState extends State<ProkopaApp> with WidgetsBindingObserver {
  ProfileStore? _profileStore;
  HabitStore? _habitStore;
  JournalStore? _journalStore;
  WellbeingStore? _wellbeingStore;
  ProgressStore? _progressStore;
  InsightStore? _insightStore;
  AchievementStore? _achievementStore;
  BackupService? _backupService;
  AppLockStore? _appLockStore;
  NotificationStore? _notificationStore;
  HabitReminderService? _habitReminderService;
  final _notificationService = LocalNotificationService();
  DateTime? _backgroundedAt;
  var _locked = false;
  LocalProfile? _profile;
  Object? _loadError;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.database != null) {
      _loading = true;
      _loadProfile(widget.database!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_profile == null || _appLockStore == null) {
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt ??= DateTime.now();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _lockAfterTimeout();
    }
  }

  Future<void> _lockAfterTimeout() async {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null || !await _appLockStore!.isEnabled()) {
      return;
    }
    final timeout = await _appLockStore!.timeoutMinutes();
    if (DateTime.now().difference(backgroundedAt).inMinutes >= timeout &&
        mounted) {
      setState(() => _locked = true);
    }
  }

  Future<void> _loadProfile(Database database) async {
    try {
      final store = ProfileStore(database);
      final lockStore = AppLockStore(database);
      final profile = await store.load();
      final completed = await store.isOnboardingComplete();
      if (!mounted) {
        return;
      }
      setState(() {
        _profileStore = store;
        _habitStore = HabitStore(database);
        _journalStore = JournalStore(database);
        _wellbeingStore = WellbeingStore(database);
        _progressStore = ProgressStore(database);
        _insightStore = InsightStore(database);
        _achievementStore = AchievementStore(database);
        _backupService = BackupService(database);
        _appLockStore = lockStore;
        _notificationStore = NotificationStore(database);
        _habitReminderService = HabitReminderService(
          database,
          _notificationService,
        );
        _profile = completed ? profile : null;
        _loading = false;
      });
      if (completed && await lockStore.isEnabled() && mounted) {
        setState(() => _locked = true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  Future<void> _completeOnboarding(LocalProfile profile) async {
    final store = _profileStore!;
    await store.completeOnboarding(profile);
    if (!mounted) {
      return;
    }
    setState(() => _profile = profile);
  }

  void _updateProfile(LocalProfile profile) {
    setState(() => _profile = profile);
  }

  void _unlock() {
    setState(() => _locked = false);
  }

  void _resetToOnboarding() {
    setState(() {
      _profile = null;
      _locked = false;
    });
  }

  Future<String?> _reloadDatabaseState() async {
    final database = widget.database;
    if (database == null || !mounted) {
      return null;
    }
    setState(() {
      _loading = true;
      _loadError = null;
      _locked = false;
    });
    await _loadProfile(database);
    if (_loadError != null) {
      return 'Backup dipulihkan, tetapi data belum dapat dibuka. Coba mulai ulang aplikasi.';
    }
    try {
      await _achievementStore?.evaluate();
      await _insightStore?.refresh();
      await NotificationStore(database).rebuildSchedules(_notificationService);
      await HabitReminderService(
        database,
        _notificationService,
      ).rescheduleEnabled();
      return null;
    } catch (_) {
      return 'Backup dipulihkan. Periksa kembali pengingat lokal.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearance = _profile?.appearance ?? AppAppearance.system;
    return MaterialApp(
      title: 'Prokopa: Habits and Jurnaling',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (appearance) {
        AppAppearance.light => ThemeMode.light,
        AppAppearance.dark => ThemeMode.dark,
        AppAppearance.system => ThemeMode.system,
      },
      home: _home(),
    );
  }

  Widget _home() {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Data Prokopa tidak dapat dibuka. Coba lagi.'),
          ),
        ),
      );
    }
    if (_profileStore != null && _profile == null) {
      return OnboardingFlow(onComplete: _completeOnboarding);
    }
    if (_locked && _appLockStore != null) {
      return AppLockScreen(
        store: _appLockStore!,
        onUnlocked: _unlock,
        onDataReset: _resetToOnboarding,
        notificationService: _notificationService,
      );
    }
    return AppShell(
      profile: _profile,
      profileStore: _profileStore,
      habitStore: widget.enableFeatureScreens ? _habitStore : null,
      journalStore: widget.enableFeatureScreens ? _journalStore : null,
      wellbeingStore: widget.enableFeatureScreens ? _wellbeingStore : null,
      progressStore: widget.enableFeatureScreens ? _progressStore : null,
      insightStore: widget.enableFeatureScreens ? _insightStore : null,
      achievementStore: widget.enableFeatureScreens ? _achievementStore : null,
      backupService: _backupService,
      appLockStore: _appLockStore,
      notificationStore: _notificationStore,
      notificationService: _notificationService,
      habitReminderService: _habitReminderService,
      onDataReset: _resetToOnboarding,
      onDataRestored: _reloadDatabaseState,
      onProfileChanged: _updateProfile,
    );
  }
}
