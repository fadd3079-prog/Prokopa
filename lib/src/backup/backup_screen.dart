import 'package:flutter/material.dart';
import 'package:prokopa/src/backup/backup_file_service.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:prokopa/src/notifications/local_notification_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({
    super.key,
    required this.backup,
    this.notificationService,
    this.onRestored,
  });

  final BackupService backup;
  final LocalNotificationService? notificationService;
  final Future<String?> Function()? onRestored;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _files = BackupFileService();
  var _working = false;
  String? _message;

  Future<void> _export() async {
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      await _files.exportAndShare(widget.backup);
      if (mounted) {
        setState(() {
          _working = false;
          _message = 'Backup siap dibagikan atau disimpan.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _working = false;
          _message = 'Backup belum dapat dibuat. Coba lagi.';
        });
      }
    }
  }

  Future<void> _import() async {
    try {
      final source = await _files.pickImport();
      if (source == null || !mounted) {
        return;
      }
      final preview = widget.backup.preview(source);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pulihkan backup?'),
          content: _BackupPreviewContent(preview: preview),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Pulihkan'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
      setState(() {
        _working = true;
        _message = null;
      });
      await widget.notificationService?.cancelAll();
      await widget.backup.replace(source);
      final warning = await widget.onRestored?.call();
      if (mounted) {
        setState(() {
          _working = false;
          _message = warning ?? 'Backup dipulihkan.';
        });
      }
    } on BackupFormatException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Backup belum dapat dipulihkan. Coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup data')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Backup dibuat hanya ketika kamu memilihnya. File ini mencakup kebiasaan, jurnal, suasana, tidur, pengaturan, dan pencapaian lokal. Tidak ada sinkronisasi cloud.',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _working ? null : _export,
              child: const Text('Ekspor backup'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _working ? null : _import,
              child: const Text('Impor backup'),
            ),
            if (_working)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_message!),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackupPreviewContent extends StatelessWidget {
  const _BackupPreviewContent({required this.preview});

  final BackupPreview preview;

  @override
  Widget build(BuildContext context) {
    final createdAt = preview.createdAt.toLocal();
    int count(String table) => preview.counts[table] ?? 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dibuat ${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
        ),
        Text('Aplikasi ${preview.appVersion} · skema ${preview.schemaVersion}'),
        const SizedBox(height: 12),
        Text('${count('habits')} kebiasaan'),
        Text('${count('journal_entries')} jurnal'),
        Text('${count('mood_records')} catatan suasana'),
        Text('${count('sleep_records')} catatan tidur'),
        Text('${count('achievements')} pencapaian'),
        const SizedBox(height: 12),
        const Text(
          'Data lokal saat ini akan diganti setelah kamu melanjutkan.',
        ),
      ],
    );
  }
}
