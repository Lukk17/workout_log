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
    service = BackupService(env.workLogDao, storageDir: () async => backupDir);
  });

  tearDown(() async {
    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
    }
    await env.dispose();
  });

  test('backupFilePath resolves to <storageDir>/backup.json', () async {
    final path = await service.backupFilePath;
    expect(path, '${backupDir.path}${Platform.pathSeparator}backup.json');
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

  test('backup of an empty DB writes an empty JSON array', () async {
    // Negative path: nothing to back up. We still want a well-formed
    // file so a subsequent restore is a clean no-op rather than a parse
    // error.
    for (final w in await env.workLogDao.getAll()) {
      await env.workLogDao.delete(w);
    }

    await service.backup();

    final file = File('${backupDir.path}/backup.json');
    expect(await file.exists(), isTrue);
    expect(await file.readAsString(), '[]');
  });

  test('restore throws FormatException on a malformed backup.json', () async {
    // Negative path: corrupted file on disk. BackupService must not
    // silently truncate or partially insert garbage; it must surface
    // the decode failure to the caller.
    final file = File('${backupDir.path}/backup.json');
    await file.writeAsString('this is not json');

    await expectLater(service.restore(), throwsA(isA<FormatException>()));
  });

  test('restore throws TypeError when JSON is valid but not a list',
      () async {
    // Negative path: a malformed but parseable backup.json (e.g. an
    // object at the root). The cast to List<dynamic> rejects it instead
    // of silently no-oping.
    final file = File('${backupDir.path}/backup.json');
    await file.writeAsString('{"nope": true}');

    await expectLater(service.restore(), throwsA(isA<TypeError>()));
  });

  test('restore round-trip preserves series + load + body weight', () async {
    final ex = Exercise.create(
      name: 'Bench Press',
      bodyParts: {BodyPart.chest},
    );
    final w = WorkLog.create(exercise: ex, on: DateTime(2026, 5, 16)).copyWith(
      series: {'1': '10', '2': '8', '3': '6'},
      load: {'1': '60', '2': '60', '3': '60'},
      bodyWeight: 80,
    );
    await env.workLogDao.insert(w);

    await service.backup();
    await env.workLogDao.delete(w);
    await service.restore();

    final restored = (await env.workLogDao.getAll())
        .firstWhere((wl) => wl.exercise.name == 'Bench Press');
    expect(restored.series, {'1': '10', '2': '8', '3': '6'});
    expect(restored.load, {'1': '60', '2': '60', '3': '60'});
    expect(restored.bodyWeight, 80);
  });
}
