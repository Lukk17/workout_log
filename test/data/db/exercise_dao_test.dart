import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';

import '../../test_helper.dart';

void main() {
  initSqfliteForTests();

  late DaoTestEnv env;

  setUp(() async {
    env = await DaoTestEnv.create();
  });

  tearDown(() => env.dispose());

  group('seed', () {
    test('every seeded exercise is present after the first read', () async {
      final exercises = await env.exerciseDao.getAll();
      expect(exercises.length, greaterThanOrEqualTo(27));
      final names = exercises.map((e) => e.name).toSet();
      expect(
        names,
        containsAll(['Push Up', 'Pull Up', 'Dead Lift', 'Running']),
      );
    });

    test('seed only runs once across multiple reads', () async {
      final first = (await env.exerciseDao.getAll()).length;
      final second = (await env.exerciseDao.getAll()).length;
      expect(second, first);
    });
  });

  group('findByName', () {
    test('returns the matching exercise', () async {
      final pushUp = await env.exerciseDao.findByName('Push Up');
      expect(pushUp, isNotNull);
      expect(pushUp!.bodyParts, contains(BodyPart.chest));
    });

    test('returns null when no match', () async {
      final missing = await env.exerciseDao.findByName('Nonexistent Lift');
      expect(missing, isNull);
    });
  });

  group('mergeBodyParts (additive)', () {
    test('adds new body parts onto an existing exercise', () async {
      final pushUp = (await env.exerciseDao.getAll()).firstWhere(
        (e) => e.name == 'Push Up',
      );
      final delta = pushUp.copyWith(bodyParts: {BodyPart.back});
      await env.exerciseDao.mergeBodyParts(delta);

      final after = (await env.exerciseDao.getAll()).firstWhere(
        (e) => e.id == pushUp.id,
      );
      expect(after.bodyParts, containsAll([BodyPart.chest, BodyPart.back]));
    });
  });

  group('replace', () {
    test('replaces name + body parts', () async {
      final pushUp = (await env.exerciseDao.getAll()).firstWhere(
        (e) => e.name == 'Push Up',
      );
      final replaced = pushUp.copyWith(
        name: 'Renamed Push Up',
        bodyParts: {BodyPart.back},
        secondaryBodyParts: <BodyPart>{},
      );
      await env.exerciseDao.replace(replaced);

      final after = (await env.exerciseDao.getAll()).firstWhere(
        (e) => e.id == pushUp.id,
      );
      expect(after.name, 'Renamed Push Up');
      expect(after.bodyParts, {BodyPart.back});
      expect(after.secondaryBodyParts, isEmpty);
    });
  });

  group('getById', () {
    test('returns the exercise', () async {
      final pushUp = (await env.exerciseDao.getAll()).firstWhere(
        (e) => e.name == 'Push Up',
      );
      final fetched = await env.exerciseDao.getById(pushUp.id);
      expect(fetched.name, 'Push Up');
    });

    test('throws for missing id', () async {
      expect(() => env.exerciseDao.getById('no-such-id'), throwsException);
    });
  });
}
