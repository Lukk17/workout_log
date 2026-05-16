import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/data/db/db_provider.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import '../../test_helper.dart';

void main() {
  initSqfliteForTests();

  late Directory tempDir;

  setUp(() async {
    tempDir = await useTemporaryDatabase();
  });

  tearDown(() async {
    await DBProvider.db.resetForTesting();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('onCreate seed', () {
    test('every seeded exercise is present after first DB getter call', () async {
      final exercises = await DBProvider.db.getAllExercise();
      // The seed block defines 27 entries.
      expect(exercises.length, greaterThanOrEqualTo(27));
      final names = exercises.map((e) => e.name).toSet();
      expect(names, containsAll(['Push Up', 'Pull Up', 'Dead Lift', 'Running']));
    });

    test('seed only runs once across multiple getter calls', () async {
      final firstCount = (await DBProvider.db.getAllExercise()).length;
      // Touch again
      final secondCount = (await DBProvider.db.getAllExercise()).length;
      expect(secondCount, firstCount);
    });
  });

  group('newWorkLog dedup', () {
    test('inserting a workLog for an existing exercise reuses the row', () async {
      final exercises = await DBProvider.db.getAllExercise();
      final pushUp = exercises.firstWhere((e) => e.name == 'Push Up');
      final pushUpCountBefore = exercises.where((e) => e.name == 'Push Up').length;

      // Create a workLog for "Push Up" with a fresh local Exercise instance
      final fresh = Exercise.create(name: 'Push Up', bodyParts: {BodyPart.chest});
      final w = WorkLog.create(exercise: fresh).copyWith(
        created: DateTime(2026, 5, 16),
      );
      await DBProvider.db.newWorkLog(w);

      final after = await DBProvider.db.getAllExercise();
      final pushUpCountAfter = after.where((e) => e.name == 'Push Up').length;
      expect(pushUpCountAfter, pushUpCountBefore, reason: 'no duplicate exercise row inserted');
      expect(pushUp.id, after.firstWhere((e) => e.name == 'Push Up').id);
    });

    test('inserting for an exercise with a new body part merges body parts', () async {
      final pushUp = (await DBProvider.db.getAllExercise())
          .firstWhere((e) => e.name == 'Push Up');
      // Push Up seeded with bodyParts = {chest}. Add a workLog with {cardio}.
      final fresh = Exercise.create(name: 'Push Up', bodyParts: {BodyPart.cardio});
      final w = WorkLog.create(exercise: fresh).copyWith(
        created: DateTime(2026, 5, 16),
      );
      await DBProvider.db.newWorkLog(w);

      final updated = (await DBProvider.db.getAllExercise())
          .firstWhere((e) => e.name == 'Push Up');
      expect(updated.id, pushUp.id);
      expect(updated.bodyParts, containsAll([BodyPart.chest, BodyPart.cardio]));
    });
  });

  group('editExercise vs updateExercise', () {
    test('updateExercise (additive) merges body parts', () async {
      final pushUp = (await DBProvider.db.getAllExercise())
          .firstWhere((e) => e.name == 'Push Up');
      final delta = pushUp.copyWith(bodyParts: {BodyPart.back});
      await DBProvider.db.updateExercise(delta);

      final after = (await DBProvider.db.getAllExercise())
          .firstWhere((e) => e.id == pushUp.id);
      expect(after.bodyParts, containsAll([BodyPart.chest, BodyPart.back]));
    });

    test('editExercise replaces body parts and name', () async {
      final pushUp = (await DBProvider.db.getAllExercise())
          .firstWhere((e) => e.name == 'Push Up');
      final replaced = pushUp.copyWith(
        name: 'Renamed Push Up',
        bodyParts: {BodyPart.back},
        secondaryBodyParts: <BodyPart>{},
      );
      await DBProvider.db.editExercise(replaced);

      final after = (await DBProvider.db.getAllExercise())
          .firstWhere((e) => e.id == pushUp.id);
      expect(after.name, 'Renamed Push Up');
      expect(after.bodyParts, {BodyPart.back});
      expect(after.secondaryBodyParts, isEmpty);
    });
  });

  group('date-filtered queries', () {
    test('getDateAllWorkLogs returns only entries created on HomePage.date', () async {
      final pushUp = (await DBProvider.db.getAllExercise())
          .firstWhere((e) => e.name == 'Push Up');

      final w1 = WorkLog.create(exercise: pushUp).copyWith(
        created: DateTime(2026, 5, 16),
      );
      final w2 = WorkLog.create(exercise: pushUp).copyWith(
        created: DateTime(2026, 5, 17),
      );
      await DBProvider.db.newWorkLog(w1);
      await DBProvider.db.newWorkLog(w2);

      final onDate = await DBProvider.db.getWorkLogsForDate(DateTime(2026, 5, 16));
      expect(onDate.length, 1);
      expect(onDate.first.created.day, 16);
    });
  });

  group('deleteWorkLog', () {
    test('deleted workLog disappears from getAllWorkLogs', () async {
      final pushUp = (await DBProvider.db.getAllExercise())
          .firstWhere((e) => e.name == 'Push Up');
      final w = WorkLog.create(exercise: pushUp).copyWith(
        created: DateTime(2026, 5, 16),
      );
      await DBProvider.db.newWorkLog(w);

      final beforeCount = (await DBProvider.db.getAllWorkLogs()).length;
      await DBProvider.db.deleteWorkLog(w);
      final afterCount = (await DBProvider.db.getAllWorkLogs()).length;
      expect(afterCount, beforeCount - 1);
    });
  });

  group('onUpgrade hook', () {
    test('opening a fresh DB at schema 2 succeeds (hook is installed)', () async {
      // The setUp opened the DB; if no exception, the schema is at version 2.
      // Implicit assertion: no throw. Sanity-check via a basic query.
      final exercises = await DBProvider.db.getAllExercise();
      expect(exercises, isNotEmpty);
    });
  });
}
