import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/work_log.dart';

/// Raised when external (shared) storage is not available on the device,
/// so backup/restore cannot read or write the backup file.
class ExternalStorageUnavailableException implements Exception {
  final String message;
  ExternalStorageUnavailableException(
      [this.message = 'External storage not available']);
  @override
  String toString() => message;
}

/// JSON backup / restore of the entire workout log. Writes a single file at
/// `<externalStorage>/backup.json` containing a JSON array of every WorkLog.
class BackupService {
  BackupService(this._workLogDao);

  final WorkLogDao _workLogDao;
  final Logger _log = Logger('BackupService');

  /// Override the external-storage directory lookup. Tests inject a temp
  /// directory; production code leaves this null and gets the OS dir.
  static Future<Directory> Function()? externalStorageOverride;

  Future<void> backup() async {
    final dir = await _externalStorageDir();
    final backupPath = join(dir.path, 'backup.json');

    final list = await _workLogDao.getAll();
    final encoded = jsonEncode(list);
    await File(backupPath).writeAsString(encoded);
    _log.fine('[backup] wrote ${list.length} workLogs to $backupPath');
  }

  Future<void> restore() async {
    final dir = await _externalStorageDir();
    final backupPath = join(dir.path, 'backup.json');
    final file = File(backupPath);
    if (!await file.exists()) {
      throw ExternalStorageUnavailableException(
          'backup file not found at $backupPath');
    }
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as List<dynamic>;
    for (final entry in decoded) {
      await _workLogDao.insert(WorkLog.fromJson(entry as Map<String, dynamic>));
    }
    _log.fine('[restore] imported ${decoded.length} workLogs from $backupPath');
  }

  Future<Directory> _externalStorageDir() async {
    if (externalStorageOverride != null) {
      return externalStorageOverride!();
    }
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw ExternalStorageUnavailableException();
      }
      return dir;
    } on ExternalStorageUnavailableException {
      rethrow;
    } catch (e) {
      throw ExternalStorageUnavailableException(
          'failed to access external storage: $e');
    }
  }
}
