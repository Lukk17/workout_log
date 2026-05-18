import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/util/log.dart';

class ExternalStorageUnavailableException implements Exception {
  final String message;
  ExternalStorageUnavailableException(
      [this.message = 'External storage not available']);
  @override
  String toString() => message;
}

class BackupService {
  BackupService(
    this._workLogDao, {
    Future<Directory> Function()? storageDir,
  }) : _storageDir = storageDir ?? _defaultStorageDir;

  final WorkLogDao _workLogDao;
  final Future<Directory> Function() _storageDir;
  static const _tag = 'BackupService';
  static const _fileName = 'backup.json';

  Future<String> get backupFilePath async {
    final dir = await _storageDir();
    return join(dir.path, _fileName);
  }

  Future<void> backup() async {
    final path = await backupFilePath;
    final list = await _workLogDao.getAll();
    await File(path).writeAsString(jsonEncode(list));
    logFine('wrote ${list.length} workLogs to $path', name: _tag);
  }

  Future<void> restore() async {
    final path = await backupFilePath;
    final file = File(path);
    if (!await file.exists()) {
      throw ExternalStorageUnavailableException(
          'backup file not found at $path');
    }
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as List<dynamic>;
    for (final entry in decoded) {
      await _workLogDao.insert(WorkLog.fromJson(entry as Map<String, dynamic>));
    }
    logFine('imported ${decoded.length} workLogs from $path', name: _tag);
  }
}

Future<Directory> _defaultStorageDir() async {
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
