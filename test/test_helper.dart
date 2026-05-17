import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/data/db/work_log_dao.dart';

/// Call once from every test main() before any DB-touching code.
void initSqfliteForTests() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Bundle of DAOs sharing one isolated AppDatabase pointed at an
/// on-disk temp file. Tests construct one of these per test via [setUp],
/// then tear it down (closing the DB + removing the temp dir) in [tearDown].
class DaoTestEnv {
  DaoTestEnv._(this.tempDir, this.factory, this.exerciseDao, this.workLogDao);

  final Directory tempDir;
  final AppDatabase factory;
  final ExerciseDao exerciseDao;
  final WorkLogDao workLogDao;

  static Future<DaoTestEnv> create() async {
    final tempDir = await Directory.systemTemp.createTemp('workout_log_test_');
    final factory = AppDatabase(
      pathOverride: '${tempDir.path}${Platform.pathSeparator}worklog.db',
    );
    final exerciseDao = ExerciseDao(factory);
    final workLogDao = WorkLogDao(factory, exerciseDao);
    return DaoTestEnv._(tempDir, factory, exerciseDao, workLogDao);
  }

  Future<void> dispose() async {
    await factory.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }
}
