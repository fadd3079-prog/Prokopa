import 'package:flutter/material.dart';
import 'package:prokopa/src/backup/backup_screen.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/profile/profile_store.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';
import 'package:prokopa/src/privacy/privacy_screen.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/notifications/notification_store.dart';
import 'package:prokopa/src/notifications/notifications_screen.dart';
import 'package:prokopa/src/app/prokopa_logo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.store,
    required this.onChanged,
    this.backupService,
    this.appLockStore,
    this.onDataReset,
    this.notificationStore,
    this.notificationService,
  });

  final LocalProfile profile;
  final ProfileStore store;
  final ValueChanged<LocalProfile> onChanged;
  final BackupService? backupService;
  final AppLockStore? appLockStore;
  final VoidCallback? onDataReset;
  final NotificationStore? notificationStore;
  final LocalNotificationService? notificationService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late String _avatar;
  late AppAppearance _appearance;
  var _editing = false;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _avatar = widget.profile.avatar;
    _appearance = widget.profile.appearance;
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
    final updated = widget.profile.copyWith(
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
    final name = widget.profile.name.trim();
    final initials = name.substring(0, 1).toUpperCase();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Semantics(
            label: 'Avatar ${widget.profile.name}',
            child: CircleAvatar(
              radius: 28,
              backgroundColor: _avatarColor(context, widget.profile.avatar),
              child: Text(initials),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.profile.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text('Profil ini tersimpan secara lokal di perangkat ini.'),
          const SizedBox(height: 20),
          if (!_editing)
            OutlinedButton(
              onPressed: () => setState(() => _editing = true),
              child: const Text('Edit profil'),
            )
          else
            _editor(context),
          if (widget.backupService != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BackupScreen(backup: widget.backupService!),
                ),
              ),
              child: const Text('Backup data'),
            ),
          ],
          if (widget.appLockStore != null && widget.onDataReset != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PrivacyScreen(
                    store: widget.appLockStore!,
                    onDataReset: widget.onDataReset!,
                  ),
                ),
              ),
              child: const Text('Privasi'),
            ),
          ],
          if (widget.notificationStore != null &&
              widget.notificationService != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(
                    store: widget.notificationStore!,
                    service: widget.notificationService!,
                  ),
                ),
              ),
              child: const Text('Pengingat'),
            ),
          ],
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                const ProkopaLogo(height: 36),
                const SizedBox(height: 8),
                Text(
                  'Prokopa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versi 0.1.0 (Habits and Journaling)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ruang kecil untuk kebiasaan dan refleksi harian.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _name,
          enabled: !_saving,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nama'),
        ),
        const SizedBox(height: 8),
        Text('Avatar', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: [
            for (final option in ['primary', 'secondary', 'tertiary'])
              ChoiceChip(
                label: Text(_avatarLabel(option)),
                selected: _avatar == option,
                onSelected: _saving
                    ? null
                    : (_) => setState(() => _avatar = option),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Tampilan', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
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
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Menyimpan' : 'Simpan perubahan'),
          ),
        ),
      ],
    );
  }

  Color _avatarColor(BuildContext context, String avatar) => switch (avatar) {
    'secondary' => Theme.of(context).colorScheme.secondaryContainer,
    'tertiary' => Theme.of(context).colorScheme.tertiaryContainer,
    _ => Theme.of(context).colorScheme.primaryContainer,
  };

  String _avatarLabel(String value) => switch (value) {
    'primary' => 'Indigo',
    'secondary' => 'Abu',
    _ => 'Aksen',
  };

  String _appearanceLabel(AppAppearance value) => switch (value) {
    AppAppearance.light => 'Terang',
    AppAppearance.dark => 'Gelap',
    AppAppearance.system => 'Sistem',
  };
}
