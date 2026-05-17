import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/data/backup/backup_service.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';

import '../../test_helper.dart';

void main() {
  initSqfliteForTests();

  late DaoTestEnv env;
  late Directory backupDir;
  late BackupService service;

  setUp(() async {
    env = await DaoTestEnv.create();
    backupDir = await Directory.systemTemp.createTemp('workout_log_backup_');
    BackupService.externalStorageOverride = () async => backupDir;
    service = BackupService(env.workLogDao);
  });

  tearDown(() async {
    BackupService.externalStorageOverride = null;
    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
    }
    await env.dispose();
  });

  test('backup writes a JSON file with every workLog', () async {
    final pushUp = (await env.exerciseDao.getAll())
        .firstWhere((e) => e.name == 'Push Up');
    await env.workLogDao
        .insert(WorkLog.create(exercise: pushUp, on: DateTime(2026, 5, 16)));

    await service.backup();

    final file = File('${backupDir.path}/backup.json');
    expect(await file.exists(), isTrue);
    final content = await file.readAsString();
    expect(content, contains('Push Up'));
    expect(content, startsWith('['));
  });

  test('restore round-trips through backup.json', () async {
    final pushUp = (await env.exerciseDao.getAll())
        .firstWhere((e) => e.name == 'Push Up');
    final w = WorkLog.create(exercise: pushUp, on: DateTime(2026, 5, 16));
    await env.workLogDao.insert(w);

    final beforeCount = (await env.workLogDao.getAll()).length;
    await service.backup();
    await env.workLogDao.delete(w);
    final afterDelete = (await env.workLogDao.getAll()).length;
    expect(afterDelete, beforeCount - 1);

    await service.restore();
    final afterRestore = (await env.workLogDao.getAll()).length;
    expect(afterRestore, beforeCount);
  });

  test('restore throws ExternalStorageUnavailable when no backup file', () async {
    expect(
      () => service.restore(),
      throwsA(isA<ExternalStorageUnavailableException>()),
    );
  });

  test('insert via restore preserves body parts', () async {
    final ex = Exercise.create(
      name: 'Custom Lift',
      bodyParts: {BodyPart.arm, BodyPart.back},
    );
    final w = WorkLog.create(exercise: ex, on: DateTime(2026, 5, 16));
    await env.workLogDao.insert(w);

    await service.backup();
    await env.workLogDao.delete(w);
    await service.restore();

    final restored = (await env.workLogDao.getAll())
        .firstWhere((wl) => wl.exercise.name == 'Custom Lift');
    expect(restored.exercise.bodyParts, containsAll([BodyPart.arm, BodyPart.back]));
  });
}
