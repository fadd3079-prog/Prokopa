import 'package:flutter/material.dart';
import 'package:prokopa/src/achievements/achievement_store.dart';
import 'package:prokopa/src/achievements/achievements_screen.dart';
import 'package:prokopa/src/backup/backup_screen.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';
import 'package:prokopa/src/privacy/privacy_screen.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/notifications/habit_reminder_service.dart';
import 'package:prokopa/src/notifications/notification_store.dart';
import 'package:prokopa/src/notifications/notifications_screen.dart';
import 'package:prokopa/src/app/prokopa_logo.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/core/constants/brand_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.profile,
    required this.store,
    required this.onChanged,
    this.backupService,
    this.appLockStore,
    this.onDataReset,
    this.notificationStore,
    this.notificationService,
    this.achievementStore,
    this.onDataRestored,
    this.habitReminderService,
  });

  final LocalProfile profile;
  final ProfileStore store;
  final ValueChanged<LocalProfile> onChanged;
  final BackupService? backupService;
  final AppLockStore? appLockStore;
  final VoidCallback? onDataReset;
  final NotificationStore? notificationStore;
  final LocalNotificationService? notificationService;
  final AchievementStore? achievementStore;
  final Future<String?> Function()? onDataRestored;
  final HabitReminderService? habitReminderService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;
  late LocalProfile _profile;
  late String _avatar;
  late AppAppearance _appearance;
  var _editing = false;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _name = TextEditingController(text: _profile.name);
    _avatar = _profile.avatar;
    _appearance = _profile.appearance;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nama tidak boleh kosong.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final updated = _profile.copyWith(
      name: name,
      avatar: _avatar,
      appearance: _appearance,
    );
    try {
      await widget.store.save(updated);
      if (!mounted) {
        return;
      }
      widget.onChanged(updated);
      setState(() {
        _profile = updated;
        _saving = false;
        _editing = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Profil belum tersimpan. Coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile.name.trim();
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: ProkopaSpacing.xxl),
          children: [
            Padding(
              padding: ProkopaSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: ProkopaSpacing.xs),
                  Text(
                    'Kelola profil lokal, privasi, dan preferensi aplikasi.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: ProkopaSpacing.xxl),
                  Card(
                    child: Padding(
                      padding: ProkopaSpacing.cardPadding,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: _avatarColor(
                              context,
                              _profile.avatar,
                            ),
                            child: Text(
                              initials,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                            ),
                          ),
                          const SizedBox(width: ProkopaSpacing.xl),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: ProkopaSpacing.xs),
                                Text(
                                  'Profil lokal',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (!_editing)
                            IconButton(
                              onPressed: () => setState(() => _editing = true),
                              icon: const ExcludeSemantics(
                                child: Icon(Icons.edit_outlined),
                              ),
                              tooltip: 'Edit profil',
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ProkopaSpacing.xxxl),

            if (_editing)
              Padding(
                padding: ProkopaSpacing.screenPadding,
                child: _editor(context),
              )
            else ...[
              _SectionHeader('Preferensi & Keamanan'),
              if (widget.notificationStore != null &&
                  widget.notificationService != null)
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Pengingat',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NotificationsScreen(
                        store: widget.notificationStore!,
                        service: widget.notificationService!,
                        habitReminders: widget.habitReminderService,
                      ),
                    ),
                  ),
                ),
              if (widget.appLockStore != null && widget.onDataReset != null)
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Privasi',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PrivacyScreen(
                        store: widget.appLockStore!,
                        onDataReset: widget.onDataReset!,
                        notificationService: widget.notificationService,
                      ),
                    ),
                  ),
                ),
              if (widget.backupService != null)
                _SettingsTile(
                  icon: Icons.save_outlined,
                  title: 'Backup data',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BackupScreen(
                        backup: widget.backupService!,
                        notificationService: widget.notificationService,
                        onRestored: widget.onDataRestored,
                      ),
                    ),
                  ),
                ),

              if (widget.achievementStore != null) ...[
                const SizedBox(height: ProkopaSpacing.xl),
                _SectionHeader('Aktivitas'),
                _SettingsTile(
                  icon: Icons.military_tech_outlined,
                  title: 'Pencapaian',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AchievementsScreen(store: widget.achievementStore!),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: ProkopaSpacing.huge),
              Center(
                child: Column(
                  children: [
                    ProkopaLogo(
                      asset: Theme.of(context).brightness == Brightness.dark
                          ? BrandConstants.logoDark
                          : BrandConstants.logoLight,
                      height: 36,
                    ),
                    const SizedBox(height: ProkopaSpacing.sm),
                    Text(
                      'Prokopa',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: ProkopaSpacing.xs),
                    Text(
                      'Versi 1.2.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _editor(BuildContext context) {
    return Card(
      child: Padding(
        padding: ProkopaSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              enabled: !_saving,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: ProkopaSpacing.xl),
            Text('Tampilan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: ProkopaSpacing.sm),
            Wrap(
              spacing: 8,
              children: [
                for (final appearance in AppAppearance.values)
                  ChoiceChip(
                    label: Text(_appearanceLabel(appearance)),
                    selected: _appearance == appearance,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _appearance = appearance),
                  ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: ProkopaSpacing.md),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: ProkopaSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() {
                          _editing = false;
                          _name.text = _profile.name;
                          _appearance = _profile.appearance;
                        }),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: ProkopaSpacing.sm),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Menyimpan' : 'Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _avatarColor(BuildContext context, String avatar) => switch (avatar) {
    'secondary' => Theme.of(context).colorScheme.secondaryContainer,
    'tertiary' => Theme.of(context).colorScheme.tertiaryContainer,
    _ => Theme.of(context).colorScheme.primaryContainer,
  };

  String _appearanceLabel(AppAppearance value) => switch (value) {
    AppAppearance.light => 'Terang',
    AppAppearance.dark => 'Gelap',
    AppAppearance.system => 'Sistem',
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: ProkopaSpacing.xl,
        right: ProkopaSpacing.xl,
        bottom: ProkopaSpacing.sm,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        ProkopaSpacing.xl,
        0,
        ProkopaSpacing.xl,
        ProkopaSpacing.md,
      ),
      child: Card(
        child: ListTile(
          minTileHeight: 68,
          leading: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: ProkopaRadius.mdBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.all(ProkopaSpacing.md),
              child: ExcludeSemantics(
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
            ),
          ),
          title: Text(title, style: theme.textTheme.titleMedium),
          trailing: const ExcludeSemantics(
            child: Icon(Icons.chevron_right, size: 20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ProkopaSpacing.lg,
            vertical: ProkopaSpacing.xs,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
