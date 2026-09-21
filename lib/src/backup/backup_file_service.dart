import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prokopa/src/backup/backup_service.dart';
import 'package:share_plus/share_plus.dart';

class BackupFileService {
  Future<void> exportAndShare(BackupService backup) async {
    final source = await backup.export();
    final directory = await getTemporaryDirectory();
    final name =
        'prokopa-backup-${DateTime.now().toUtc().toIso8601String().replaceAll(':', '-')}.json';
    final file = File('${directory.path}${Platform.pathSeparator}$name');
    await file.writeAsString(source, encoding: utf8, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        fileNameOverrides: [name],
        text: 'Backup lokal Prokopa',
      ),
    );
  }

  Future<String?> pickImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final selected = result?.files.singleOrNull;
    if (selected == null) {
      return null;
    }
    final bytes = selected.bytes ?? await File(selected.path!).readAsBytes();
    return utf8.decode(bytes, allowMalformed: false);
  }
}
