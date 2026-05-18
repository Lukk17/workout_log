import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/data/db/work_log_dao.dart';

void initSqfliteForTests() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

class DaoTestEnv {
  DaoTestEnv._(this.tempDir, this.appDatabase, this.exerciseDao, this.workLogDao);

  final Directory tempDir;
  final AppDatabase appDatabase;
  final ExerciseDao exerciseDao;
  final WorkLogDao workLogDao;

  static Future<DaoTestEnv> create() async {
    final tempDir = await Directory.systemTemp.createTemp('workout_log_test_');
    final appDatabase = AppDatabase(
      Future.value('${tempDir.path}${Platform.pathSeparator}worklog.db'),
    );
    final exerciseDao = ExerciseDao(appDatabase);
    final workLogDao = WorkLogDao(appDatabase, exerciseDao);
    return DaoTestEnv._(tempDir, appDatabase, exerciseDao, workLogDao);
  }

  Future<void> dispose() async {
    await appDatabase.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }
}
