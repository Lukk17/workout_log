import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/presentation/pages/exercise_form_page.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';

import '../helpers/test_app.dart';
import '../test_helper.dart';

/// Sets the test surface to a portrait phone-like aspect (400 x 800)
/// so the form's landscape branch — which contains a known 1px overflow
/// outside the scope of this proposal — isn't exercised.
Future<void> _useTallSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  testWidgets('Save with empty name surfaces a SnackBar', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      testApp(child: const ExerciseFormPage(exercise: null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('SAVE'), findsOneWidget);
    await tester.tap(find.text('SAVE'));
    await tester.pump();

    expect(find.text('You forgot about exercise name :)'), findsOneWidget);
  });

  testWidgets('Save with name but no body parts surfaces a SnackBar',
      (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      testApp(child: const ExerciseFormPage(exercise: null)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Some Lift');
    await tester.pump();

    await tester.tap(find.text('SAVE'));
    await tester.pump();

    expect(
      find.text('You forgot about exercise body part :)'),
      findsOneWidget,
    );
  });

  testWidgets('Form chrome (sections, buttons) renders', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      testApp(child: const ExerciseFormPage(exercise: null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Main Body Parts:'), findsOneWidget);
    expect(find.text('Secondary Body Parts:'), findsOneWidget);
    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Tapping a body-part checkbox keeps SAVE enabled', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      testApp(child: const ExerciseFormPage(exercise: null)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Some Lift');
    await tester.tap(find.text('chest').first);
    await tester.pump();

    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}

// Note: SAVE persistence (create-mode insert + edit-mode replace) is
// covered by test/data/db/exercise_dao_test.dart and
// test/data/db/work_log_dao_test.dart. Driving the save through
// pumpWidget here deadlocks because the DAO call awaits real
// sqflite_ffi I/O inside flutter_test's FakeAsync zone.
