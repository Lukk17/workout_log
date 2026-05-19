import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/exercise_detail_provider.dart';

import '../../helpers/test_app.dart' show riverpodContainer;
import '../../test_helper.dart';

void main() {
  initSqfliteForTests();

  late DaoTestEnv env;

  setUp(() async {
    env = await DaoTestEnv.create();
  });

  tearDown(() => env.dispose());

  WorkLog seed() {
    final ex = Exercise.create(
      name: 'Bench Press',
      bodyParts: {BodyPart.chest},
    );

    return WorkLog.create(exercise: ex, on: DateTime(2026, 5, 16)).copyWith(
      series: {'1': '10', '2': '8'},
      load: {'1': '60', '2': '60'},
    );
  }

  test('editLoad rewrites that set\'s load entry + persists', () async {
    final initial = seed();
    await env.workLogDao.insert(initial);
    final container = riverpodContainer(env);
    // autoDispose family: hold a subscription open for the duration of
    // the awaited DAO write, otherwise the notifier disposes between
    // .read(...notifier) and the next .read(state).
    final sub = container.listen(exerciseDetailProvider(initial), (_, _) {});
    addTearDown(sub.close);

    await container
        .read(exerciseDetailProvider(initial).notifier)
        .editLoad('1', '85');

    final state = container.read(exerciseDetailProvider(initial));
    expect(state.load['1'], '85');
    expect(state.load['2'], '60');

    final fromDb = await env.workLogDao.getById(initial.id);
    expect(fromDb!.load['1'], '85');
  });

  test('editRepeats rewrites that set\'s series entry + persists',
      () async {
    final initial = seed();
    await env.workLogDao.insert(initial);
    final container = riverpodContainer(env);
    final sub = container.listen(exerciseDetailProvider(initial), (_, _) {});
    addTearDown(sub.close);

    await container
        .read(exerciseDetailProvider(initial).notifier)
        .editRepeats('2', '12');

    final fromDb = await env.workLogDao.getById(initial.id);
    expect(fromDb!.series['2'], '12');
    expect(fromDb.series['1'], '10');
  });

  test('addSeries appends a new index initialised to "0" / "0"', () async {
    final initial = seed();
    await env.workLogDao.insert(initial);
    final container = riverpodContainer(env);
    final sub = container.listen(exerciseDetailProvider(initial), (_, _) {});
    addTearDown(sub.close);

    await container
        .read(exerciseDetailProvider(initial).notifier)
        .addSeries();

    final state = container.read(exerciseDetailProvider(initial));
    expect(state.series.containsKey('3'), isTrue);
    expect(state.series['3'], '0');
    expect(state.load['3'], '0');
  });

  test('deleteSeries removes the row and shifts later indices down by 1',
      () async {
    final initial = seed().copyWith(
      series: {'1': '10', '2': '8', '3': '6'},
      load: {'1': '60', '2': '65', '3': '70'},
    );
    await env.workLogDao.insert(initial);
    final container = riverpodContainer(env);
    final sub = container.listen(exerciseDetailProvider(initial), (_, _) {});
    addTearDown(sub.close);

    // Delete the middle row (index 1, i.e. set "2") — index 2 should
    // shift down to become "2".
    await container
        .read(exerciseDetailProvider(initial).notifier)
        .deleteSeries(2);

    final state = container.read(exerciseDetailProvider(initial));
    expect(state.series.keys.toList(), ['1', '2']);
    expect(state.series['1'], '10');
    expect(state.series['2'], '6');
    expect(state.load['1'], '60');
    expect(state.load['2'], '70');
  });
}
