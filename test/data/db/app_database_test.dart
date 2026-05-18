import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';

import '../../test_helper.dart';

void main() {
  initSqfliteForTests();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_database_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('opens the database at the path passed to the constructor', () async {
    final dbPath = p.join(tempDir.path, 'worklog.db');
    final db = AppDatabase(Future.value(dbPath));
    addTearDown(db.close);

    await db.database;

    expect(File(dbPath).existsSync(), isTrue);
  });

  test('default seed populates the exercise table on first launch', () async {
    final dbPath = p.join(tempDir.path, 'worklog.db');
    final db = AppDatabase(Future.value(dbPath));
    addTearDown(db.close);

    final raw = await db.database;
    final rows = await raw.query(exerciseTable);

    expect(rows.length, greaterThanOrEqualTo(27));
    final names = rows.map((r) => r['name']).toSet();
    expect(names, containsAll(['Push Up', 'Pull Up', 'Running']));
  });

  test('custom seed replaces the default catalog', () async {
    final dbPath = p.join(tempDir.path, 'worklog.db');
    final customSeed = [
      Exercise.create(name: 'Only Lift', bodyParts: {BodyPart.arm}),
    ];
    final db = AppDatabase(Future.value(dbPath), seed: customSeed);
    addTearDown(db.close);

    final raw = await db.database;
    final rows = await raw.query(exerciseTable);

    expect(rows.length, 1);
    expect(rows.first['name'], 'Only Lift');
  });
}
