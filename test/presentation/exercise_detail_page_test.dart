import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail_page.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';

import '../helpers/test_app.dart';
import '../test_helper.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  initSqfliteForTests();

  late DaoTestEnv env;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'is_dark': true,
      'background_image': false,
    });
    env = await DaoTestEnv.create();
  });

  tearDown(() => env.dispose());

  void useTallSurface(WidgetTester tester) {
    // setSurfaceSize doesn't fully propagate through MediaQuery before
    // the first build runs, so the page's _Layout is computed against
    // the default 800x600 surface and overflows. Updating tester.view
    // directly + pixel ratio 1.0 makes the size visible to MediaQuery
    // from the first frame.
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget wrap(WorkLog workLog) => testApp(
        child: ExerciseDetailPage(workLog: workLog),
        overrides: [
          appDatabaseProvider.overrideWithValue(env.appDatabase),
          exerciseDaoProvider.overrideWithValue(env.exerciseDao),
          workLogDaoProvider.overrideWithValue(env.workLogDao),
        ],
      );

  WorkLog seedWorkLog() {
    final ex = Exercise.create(
      name: 'Bench Press',
      bodyParts: {BodyPart.chest},
      secondaryBodyParts: {BodyPart.arm},
    );
    return WorkLog.create(exercise: ex, on: DateTime(2026, 5, 16)).copyWith(
      series: {'1': '10', '2': '8'},
      load: {'1': '60', '2': '60'},
    );
  }

  testWidgets('Renders exercise name + table header + every series row',
      (tester) async {
    useTallSurface(tester);
    final w = seedWorkLog();
    // sqflite_ffi opens a real DB file, which won't complete inside the
    // FakeAsync zone testWidgets installs; runAsync lets the I/O escape
    // to the real scheduler and run to completion.
    await tester.runAsync(() => env.workLogDao.insert(w));

    await tester.pumpWidget(wrap(w));
    await _settle(tester);

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('series'), findsOneWidget);
    expect(find.text('load'), findsOneWidget);
    expect(find.text('repeats'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('60'), findsNWidgets(2));
  });

  testWidgets('Body-part section lists Primary and Secondary labels',
      (tester) async {
    useTallSurface(tester);
    final w = seedWorkLog();
    await tester.runAsync(() => env.workLogDao.insert(w));

    await tester.pumpWidget(wrap(w));
    await _settle(tester);

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('chest'), findsOneWidget);
    expect(find.text('arm'), findsOneWidget);
  });

  testWidgets('Renders 1-based series numbers in the leftmost column',
      (tester) async {
    useTallSurface(tester);
    final w = seedWorkLog();
    await tester.runAsync(() => env.workLogDao.insert(w));

    await tester.pumpWidget(wrap(w));
    await _settle(tester);

    // Series column reads "1" and "2" for a workLog with two sets —
    // *not* "0" and "1" — because the column header is "series" and
    // users expect 1-based labelling.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Tapping a load cell opens _SetValueDialog with Edit load title',
      (tester) async {
    useTallSurface(tester);
    final w = seedWorkLog();
    await tester.runAsync(() => env.workLogDao.insert(w));

    await tester.pumpWidget(wrap(w));
    await _settle(tester);

    // Both load cells render '60'; the first matches the cell button.
    await tester.tap(find.text('60').first);
    await _settle(tester);

    expect(find.text('Edit load value'), findsOneWidget);
    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
  });
}
