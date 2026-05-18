import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/presentation/pages/exercise_list_page.dart';
import 'package:workout_log/presentation/pages/home_page.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';

import '../helpers/test_app.dart';
import '../test_helper.dart';

// We cannot use pumpAndSettle because WorkLogPage's FutureProvider may
// still be resolving when the spinner appears, and a Material spinner
// schedules new frames forever. pump() with explicit durations gives
// every test a deterministic settle window.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  initSqfliteForTests();

  late DaoTestEnv env;

  setUp(() async {
    // Background false -> _BlurredBackground is never instantiated, so
    // AssetImage decoding never runs (asset bundles aren't shipped to
    // the test surface).
    SharedPreferences.setMockInitialValues({
      'is_dark': true,
      'background_image': false,
    });
    env = await DaoTestEnv.create();
  });

  tearDown(() => env.dispose());

  List<Override> daoOverrides() => [
        appDatabaseProvider.overrideWithValue(env.appDatabase),
        exerciseDaoProvider.overrideWithValue(env.exerciseDao),
        workLogDaoProvider.overrideWithValue(env.workLogDao),
      ];

  Widget wrap() => testApp(
        child: HomePage(callback: (_) {}),
        overrides: daoOverrides(),
      );

  Future<void> useTallSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('Renders Log + Timer tabs and the gear/calendar actions',
      (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await _settle(tester);

    expect(find.text('Log'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
  });

  testWidgets('Tapping the Timer tab swaps the body to TimerPage',
      (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await _settle(tester);

    await tester.tap(find.text('Timer'));
    await _settle(tester);

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('Settings drawer opens via the gear icon', (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.settings));
    await _settle(tester);

    expect(find.text('Dark mode:'), findsOneWidget);
    expect(find.text('Background image:'), findsOneWidget);
    expect(find.text('Backup'), findsOneWidget);
    expect(find.text('Edit Exercises'), findsOneWidget);
  });

  testWidgets('Toggling dark mode switch flips themeModeProvider',
      (tester) async {
    await useTallSurface(tester);
    late ProviderContainer container;
    await tester.pumpWidget(testApp(
      child: Builder(builder: (context) {
        container = ProviderScope.containerOf(context);
        return HomePage(callback: (_) {});
      }),
      overrides: daoOverrides(),
    ));
    await _settle(tester);

    expect(container.read(themeModeProvider), ThemeMode.dark);

    await tester.tap(find.byIcon(Icons.settings));
    await _settle(tester);
    await tester.tap(find.byType(Switch).first);
    await _settle(tester);

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  testWidgets('Edit Exercises drawer button navigates to ExerciseListPage',
      (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.settings));
    await _settle(tester);
    await tester.tap(find.text('Edit Exercises'));
    await _settle(tester);

    expect(find.byType(ExerciseListPage), findsOneWidget);
  });
}
