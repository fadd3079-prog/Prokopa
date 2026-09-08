import 'package:flutter/material.dart';
import 'package:prokopa/src/privacy/app_lock_store.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({
    super.key,
    required this.store,
    required this.onDataReset,
  });

  final AppLockStore store;
  final VoidCallback onDataReset;

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  var _enabled = false;
  var _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final enabled = await widget.store.isEnabled();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _configure() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            _AppLockSettings(store: widget.store, enabled: _enabled),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua data lokal?'),
        content: const Text(
          'Profil, kebiasaan, jurnal, suasana, tidur, dan pengaturan akan dihapus dari perangkat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus semua'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await widget.store.deleteAllData();
      widget.onDataReset();
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Data belum dapat dihapus. Coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Privasi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Data Prokopa tersimpan secara lokal. Tidak ada akun atau sinkronisasi cloud.',
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Kunci aplikasi'),
              subtitle: Text(_enabled ? 'Aktif' : 'Tidak aktif'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _configure,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hapus semua data lokal'),
              subtitle: const Text('Tindakan ini tidak dapat dibatalkan.'),
              trailing: const Icon(Icons.delete_outline),
              onTap: _deleteAll,
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_message!),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppLockSettings extends StatefulWidget {
  const _AppLockSettings({required this.store, required this.enabled});

  final AppLockStore store;
  final bool enabled;

  @override
  State<_AppLockSettings> createState() => _AppLockSettingsState();
}

class _AppLockSettingsState extends State<_AppLockSettings> {
  final _pin = TextEditingController();
  final _confirmation = TextEditingController();
  var _timeout = 1;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_pin.text != _confirmation.text) {
      setState(() => _error = 'PIN dan konfirmasi tidak sama.');
      return;
    }
    try {
      await widget.store.enablePin(_pin.text, timeout: _timeout);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ArgumentError catch (error) {
      setState(() => _error = error.message?.toString());
    } catch (_) {
      setState(
        () => _error = 'Kunci aplikasi belum dapat disimpan. Coba lagi.',
      );
    }
  }

  Future<void> _disable() async {
    if (!await widget.store.verifyPin(_pin.text)) {
      setState(() => _error = 'PIN tidak cocok.');
      return;
    }
    await widget.store.disable();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabling = !widget.enabled;
    return Scaffold(
      appBar: AppBar(title: const Text('Kunci aplikasi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              enabling ? 'Buat PIN lokal' : 'Nonaktifkan kunci aplikasi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'PIN disimpan menggunakan penyimpanan aman perangkat ini.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pin,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN'),
            ),
            if (enabling) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmation,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Konfirmasi PIN'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _timeout,
                decoration: const InputDecoration(
                  labelText: 'Kunci setelah aplikasi di latar belakang',
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Segera')),
                  DropdownMenuItem(value: 1, child: Text('1 menit')),
                  DropdownMenuItem(value: 5, child: Text('5 menit')),
                  DropdownMenuItem(value: 15, child: Text('15 menit')),
                ],
                onChanged: (value) => setState(() => _timeout = value!),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: enabling ? _save : _disable,
              child: Text(enabling ? 'Aktifkan kunci' : 'Nonaktifkan kunci'),
            ),
          ],
        ),
      ),
    );
  }
}
