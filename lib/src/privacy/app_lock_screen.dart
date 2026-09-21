import 'package:flutter/material.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    super.key,
    required this.store,
    required this.onUnlocked,
    required this.onDataReset,
    this.notificationService,
  });

  final AppLockStore store;
  final VoidCallback onUnlocked;
  final VoidCallback onDataReset;
  final LocalNotificationService? notificationService;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _pin = TextEditingController();
  var _deviceAvailable = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDeviceAvailability();
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceAvailability() async {
    final available = await widget.store.canUseDeviceAuthentication();
    if (mounted) {
      setState(() => _deviceAvailable = available);
    }
  }

  Future<void> _unlockPin() async {
    if (await widget.store.verifyPin(_pin.text)) {
      widget.onUnlocked();
    } else {
      setState(() => _error = 'PIN tidak cocok. Coba lagi.');
    }
  }

  Future<void> _unlockDevice() async {
    if (await widget.store.unlockWithDevice()) {
      widget.onUnlocked();
    } else if (mounted) {
      setState(() => _error = 'Perangkat belum dapat membuka Prokopa.');
    }
  }

  Future<void> _forgotPin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data lokal?'),
        content: const Text(
          'Tanpa akun atau cloud, PIN tidak dapat dipulihkan. Reset akan menghapus profil, kebiasaan, jurnal, suasana, tidur, dan pengaturan dari perangkat ini. Backup yang sudah kamu simpan di tempat lain tidak dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset data'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await widget.notificationService?.cancelAll();
      await widget.store.deleteAllData();
      if (mounted) {
        widget.onDataReset();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Data belum dapat direset. Coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Prokopa terkunci',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Masukkan PIN lokal untuk melanjutkan.'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pin,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'PIN'),
                    onSubmitted: (_) => _unlockPin(),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _unlockPin,
                    child: const Text('Buka'),
                  ),
                  if (_deviceAvailable) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _unlockDevice,
                      child: const Text('Gunakan keamanan perangkat'),
                    ),
                  ],
                  TextButton(
                    onPressed: _forgotPin,
                    child: const Text('Lupa PIN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
