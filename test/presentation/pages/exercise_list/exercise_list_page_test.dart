import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/presentation/pages/exercise_list_page.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('renders all exercises from the provider', (tester) async {
    final exercises = [
      Exercise(id: 'a', name: 'Bench', bodyParts: {BodyPart.chest}),
      Exercise(id: 'b', name: 'Squat', bodyParts: {BodyPart.leg}),
      Exercise(id: 'c', name: 'Pull Up', bodyParts: {BodyPart.back}),
    ];

    await tester.pumpWidget(
      testApp(
        overrides: [
          exercisesProvider.overrideWith((ref) async => exercises),
        ],
        child: const ExerciseListPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bench'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Pull Up'), findsOneWidget);
    expect(find.text('Exercises Edit'), findsOneWidget);
  });

  testWidgets('shows a spinner while exercises are loading', (tester) async {
    await tester.pumpWidget(
      testApp(
        overrides: [
          // A never-completing future leaves the provider in `loading` state.
          exercisesProvider.overrideWith((ref) async {
            final c = Completer<List<Exercise>>();
            return c.future;
          }),
        ],
        child: const ExerciseListPage(),
      ),
    );
    // No pumpAndSettle — spinner is animated; one pump is enough to render it.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an error message when the provider throws', (tester) async {
    await tester.pumpWidget(
      testApp(
        overrides: [
          exercisesProvider.overrideWith((ref) async => throw Exception('boom')),
        ],
        child: const ExerciseListPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load exercises'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
  });
}
