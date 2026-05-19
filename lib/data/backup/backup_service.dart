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

class BackupNotFoundException implements Exception {
  BackupNotFoundException(this.path);
  final String path;
  @override
  String toString() => 'backup file not found at $path';
}

class BackupCorruptException implements Exception {
  BackupCorruptException(this.cause);
  final Object cause;
  @override
  String toString() => 'backup file is malformed: $cause';
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

  /// Restores the workouts in `backup.json` into the database, **replacing**
  /// the current set. Existing rows are deleted first; failing
  /// half-way through leaves a partially-restored DB, which is the
  /// same risk the previous append-mode had (with the extra surprise
  /// that duplicate ids were silently dropped).
  ///
  /// Throws [BackupNotFoundException] if no backup exists,
  /// [BackupCorruptException] if the file is not parseable as a JSON
  /// list of workLogs, and [ExternalStorageUnavailableException] if
  /// the storage directory itself is unreachable.
  Future<void> restore() async {
    final path = await backupFilePath;
    final file = File(path);
    if (!await file.exists()) {
      throw BackupNotFoundException(path);
    }
    final raw = await file.readAsString();
    final List<dynamic> decoded;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! List) {
        throw BackupCorruptException('expected a JSON list at the root');
      }
      decoded = parsed;
    } on FormatException catch (e) {
      throw BackupCorruptException(e);
    }
    final workLogs = <WorkLog>[];
    try {
      for (final entry in decoded) {
        workLogs.add(WorkLog.fromJson(entry as Map<String, dynamic>));
      }
    } catch (e) {
      throw BackupCorruptException(e);
    }

    // Replace, don't merge: the user is asking to restore from a
    // snapshot, and append-mode (the old behavior) silently dropped
    // duplicate ids without telling them.
    for (final existing in await _workLogDao.getAll()) {
      await _workLogDao.delete(existing);
    }
    for (final w in workLogs) {
      await _workLogDao.insert(w);
    }
    logFine('imported ${workLogs.length} workLogs from $path', name: _tag);
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
