import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';

import '../../test_helper.dart';

void main() {
  initSqfliteForTests();

  late DaoTestEnv env;

  setUp(() async {
    env = await DaoTestEnv.create();
  });

  tearDown(() => env.dispose());

  group('insert dedup', () {
    test('inserting a workLog for an existing exercise reuses the row', () async {
      final exercises = await env.exerciseDao.getAll();
      final pushUp = exercises.firstWhere((e) => e.name == 'Push Up');
      final beforeCount =
          exercises.where((e) => e.name == 'Push Up').length;

      final fresh = Exercise.create(
          name: 'Push Up', bodyParts: {BodyPart.chest});
      final w = WorkLog.create(
        exercise: fresh,
        on: DateTime(2026, 5, 16),
      );
      await env.workLogDao.insert(w);

      final after = await env.exerciseDao.getAll();
      final afterCount = after.where((e) => e.name == 'Push Up').length;
      expect(afterCount, beforeCount,
          reason: 'no duplicate exercise row inserted');
      expect(pushUp.id,
          after.firstWhere((e) => e.name == 'Push Up').id);
    });

    test('inserting with a new body part merges body parts', () async {
      final pushUp = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Push Up');
      final fresh = Exercise.create(
          name: 'Push Up', bodyParts: {BodyPart.cardio});
      final w = WorkLog.create(
        exercise: fresh,
        on: DateTime(2026, 5, 16),
      );
      await env.workLogDao.insert(w);

      final updated = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Push Up');
      expect(updated.id, pushUp.id);
      expect(updated.bodyParts, containsAll([BodyPart.chest, BodyPart.cardio]));
    });
  });

  group('getForDate', () {
    test('returns only entries on that date', () async {
      final pushUp = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Push Up');
      final w1 = WorkLog.create(exercise: pushUp, on: DateTime(2026, 5, 16));
      final w2 = WorkLog.create(exercise: pushUp, on: DateTime(2026, 5, 17));
      await env.workLogDao.insert(w1);
      await env.workLogDao.insert(w2);

      final onDate = await env.workLogDao.getForDate(DateTime(2026, 5, 16));
      expect(onDate.length, 1);
      expect(onDate.first.created.day, 16);
    });

    test('empty list when no workouts on that date', () async {
      final none = await env.workLogDao.getForDate(DateTime(2099, 1, 1));
      expect(none, isEmpty);
    });
  });

  group('getForDateAndBodyPart', () {
    test('filters by primary body part', () async {
      final pushUp = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Push Up');
      final running = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Running');
      final date = DateTime(2026, 5, 16);
      await env.workLogDao.insert(WorkLog.create(exercise: pushUp, on: date));
      await env.workLogDao.insert(WorkLog.create(exercise: running, on: date));

      final chestOnly = await env.workLogDao.getForDateAndBodyPart(
          date, BodyPart.chest);
      expect(chestOnly.length, 1);
      expect(chestOnly.first.exercise.name, 'Push Up');
    });
  });

  group('delete', () {
    test('deleted workLog disappears from getAll', () async {
      final pushUp = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Push Up');
      final w = WorkLog.create(exercise: pushUp, on: DateTime(2026, 5, 16));
      await env.workLogDao.insert(w);

      final beforeCount = (await env.workLogDao.getAll()).length;
      await env.workLogDao.delete(w);
      final afterCount = (await env.workLogDao.getAll()).length;
      expect(afterCount, beforeCount - 1);
    });
  });

  group('onUpgrade hook', () {
    test('opening a fresh DB at schema 2 succeeds', () async {
      // setUp opened the DB; no exception => version 2 active.
      final exercises = await env.exerciseDao.getAll();
      expect(exercises, isNotEmpty);
    });
  });

  group('insert (brand-new exercise path)', () {
    test('a workLog with a never-seen exercise inserts both rows', () async {
      final fresh = Exercise.create(
        name: 'Front Lever',
        bodyParts: {BodyPart.back, BodyPart.arm},
      );
      final w = WorkLog.create(exercise: fresh, on: DateTime(2026, 5, 16));

      await env.workLogDao.insert(w);

      final exercises = await env.exerciseDao.getAll();
      expect(
        exercises.where((e) => e.name == 'Front Lever'),
        hasLength(1),
        reason: 'new exercise row was inserted alongside the workLog',
      );
      final stored = (await env.workLogDao.getAll())
          .firstWhere((wl) => wl.exercise.name == 'Front Lever');
      expect(stored.exercise.bodyParts, {BodyPart.back, BodyPart.arm});
    });
  });

  group('insert (duplicate id path)', () {
    test('inserting the same WorkLog twice returns 0 the second time',
        () async {
      final pushUp = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Push Up');
      final w = WorkLog.create(exercise: pushUp, on: DateTime(2026, 5, 16));

      final first = await env.workLogDao.insert(w);
      final second = await env.workLogDao.insert(w);

      expect(first, greaterThan(0));
      expect(second, 0, reason: 'DatabaseException swallowed -> 0');
      expect((await env.workLogDao.getAll()).length, 1);
    });
  });

  group('update', () {
    test('rewrites series/load/bodyWeight for an existing workLog', () async {
      final pushUp = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Push Up');
      final original = WorkLog.create(
        exercise: pushUp,
        on: DateTime(2026, 5, 16),
      );
      await env.workLogDao.insert(original);
      final edited = original.copyWith(
        series: {'1': '10', '2': '8'},
        load: {'1': '20', '2': '20'},
        bodyWeight: 80,
      );

      final affected = await env.workLogDao.update(edited);

      expect(affected, 1);
      final reloaded = await env.workLogDao.getById(original.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.series, {'1': '10', '2': '8'});
      expect(reloaded.load, {'1': '20', '2': '20'});
      expect(reloaded.bodyWeight, 80);
    });
  });

  group('getById', () {
    test('returns null when no workLog with that id exists', () async {
      final missing = await env.workLogDao.getById('does-not-exist');
      expect(missing, isNull);
    });

    test('round-trips a stored workLog including its exercise', () async {
      final pushUp = (await env.exerciseDao.getAll())
          .firstWhere((e) => e.name == 'Push Up');
      final w = WorkLog.create(exercise: pushUp, on: DateTime(2026, 5, 16));
      await env.workLogDao.insert(w);

      final fetched = await env.workLogDao.getById(w.id);

      expect(fetched, isNotNull);
      expect(fetched!.id, w.id);
      expect(fetched.exercise.name, 'Push Up');
    });
  });
}
