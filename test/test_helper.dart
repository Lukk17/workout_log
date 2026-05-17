import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_log/data/db/db_provider.dart';

/// Call once from every test main() before any DB-touching code.
void initSqfliteForTests() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Allocate an isolated DB path under the system temp dir and point the
/// singleton DBProvider at it. Returns the temp directory so the caller can
/// clean up in tearDown.
Future<Directory> useTemporaryDatabase() async {
  final tempDir = await Directory.systemTemp.createTemp('workout_log_test_');
  DBProvider.databasePathOverride =
      '${tempDir.path}${Platform.pathSeparator}worklog.db';
  await DBProvider.instance.resetForTesting();
  return tempDir;
}
