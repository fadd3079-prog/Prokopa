import 'package:flutter/material.dart';
import 'package:prokopa/src/backup/backup_file_service.dart';
import 'package:prokopa/src/backup/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.backup});

  final BackupService backup;

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
          content: Text(
            'Backup ini berisi ${preview.counts.values.fold<int>(0, (sum, count) => sum + count)} catatan dan akan mengganti data lokal saat ini.',
          ),
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
      await widget.backup.replace(source);
      if (mounted) {
        setState(() {
          _working = false;
          _message = 'Backup dipulihkan.';
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
              'Backup dibuat hanya ketika kamu memilihnya. Tidak ada sinkronisasi cloud.',
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
