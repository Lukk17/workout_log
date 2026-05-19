import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail/exercise_detail_page.dart';
import 'package:workout_log/presentation/pages/work_log/work_log_page.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';

import '../../../helpers/test_app.dart';

WorkLog _seedWorkLog(String name, DateTime date,
    {Set<BodyPart> bodyParts = const {BodyPart.chest}}) {
  return WorkLog.create(
    exercise: Exercise.create(name: name, bodyParts: bodyParts),
    on: date,
  );
}

void main() {
  testWidgets('Selected date renders as "Today" when it is DateTime.now()', (tester) async {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    await tester.pumpWidget(
      testApp(
        overrides: [
          selectedDateProvider.overrideWith((ref) => normalizedToday),
          workLogsForSelectedDateProvider
              .overrideWith((ref) async => <WorkLog>[]),
        ],
        child: const Scaffold(body: WorkLogPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('Other dates render as YYYY-MM-DD', (tester) async {
    await tester.pumpWidget(
      testApp(
        overrides: [
          selectedDateProvider.overrideWith((ref) => DateTime(2026, 5, 16)),
          workLogsForSelectedDateProvider
              .overrideWith((ref) async => <WorkLog>[]),
        ],
        child: const Scaffold(body: WorkLogPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026-05-16'), findsOneWidget);
  });

  testWidgets('Renders a Card for each workout returned by the provider',
      (tester) async {
    final date = DateTime(2026, 5, 16);
    final workouts = [
      _seedWorkLog('Push Up', date),
      _seedWorkLog('Pull Up', date, bodyParts: {BodyPart.back}),
    ];

    await tester.pumpWidget(
      testApp(
        overrides: [
          selectedDateProvider.overrideWith((ref) => date),
          workLogsForSelectedDateProvider.overrideWith((ref) async => workouts),
        ],
        child: const Scaffold(body: WorkLogPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Push Up'), findsOneWidget);
    expect(find.text('Pull Up'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
  });

  testWidgets('A workout with no series shows Series: 0 / Reps: 0',
      (tester) async {
    final date = DateTime(2026, 5, 16);
    await tester.pumpWidget(
      testApp(
        overrides: [
          selectedDateProvider.overrideWith((ref) => date),
          workLogsForSelectedDateProvider
              .overrideWith((ref) async => [_seedWorkLog('Push Up', date)]),
        ],
        child: const Scaffold(body: WorkLogPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Series: 0'), findsOneWidget);
    expect(find.text('Reps: 0'), findsOneWidget);
  });

  testWidgets('Shows spinner while workouts are loading', (tester) async {
    final date = DateTime(2026, 5, 16);
    await tester.pumpWidget(
      testApp(
        overrides: [
          selectedDateProvider.overrideWith((ref) => date),
          workLogsForSelectedDateProvider.overrideWith((ref) async {
            final c = Completer<List<WorkLog>>();
            return c.future;
          }),
        ],
        child: const Scaffold(body: WorkLogPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows an error widget when the provider throws',
      (tester) async {
    final date = DateTime(2026, 5, 16);
    await tester.pumpWidget(
      testApp(
        overrides: [
          selectedDateProvider.overrideWith((ref) => date),
          workLogsForSelectedDateProvider
              .overrideWith((ref) async => throw Exception('db down')),
        ],
        child: const Scaffold(body: WorkLogPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load workouts'), findsOneWidget);
    expect(find.textContaining('db down'), findsOneWidget);
  });

  testWidgets('Body-part leading column shows at most 3 names', (tester) async {
    final date = DateTime(2026, 5, 16);
    final manyParts = WorkLog.create(
      exercise: Exercise.create(
        name: 'Many Parts',
        bodyParts: {BodyPart.chest, BodyPart.back, BodyPart.arm, BodyPart.leg},
      ),
      on: date,
    );

    await tester.pumpWidget(
      testApp(
        overrides: [
          selectedDateProvider.overrideWith((ref) => date),
          workLogsForSelectedDateProvider
              .overrideWith((ref) async => [manyParts]),
        ],
        child: const Scaffold(body: WorkLogPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Each body-part label appears as a Text widget inside the leading column.
    final bpLabels = {'chest', 'back', 'arm', 'leg'};
    final visible = bpLabels
        .where((label) => find.text(label).evaluate().isNotEmpty)
        .length;
    expect(visible, 3);
  });

  testWidgets('Tapping a workout card navigates to ExerciseDetailPage',
      (tester) async {
    final date = DateTime(2026, 5, 16);
    final w = _seedWorkLog('Push Up', date);

    await tester.pumpWidget(
      testApp(
        overrides: [
          selectedDateProvider.overrideWith((ref) => date),
          workLogsForSelectedDateProvider.overrideWith((ref) async => [w]),
        ],
        child: const Scaffold(body: WorkLogPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Card));
    await tester.pumpAndSettle();

    // Navigation to ExerciseDetailPage requires workLogDao at the
    // destination, but the route push itself happens before that —
    // the page-detail tests cover end-state behaviour separately.
    expect(find.byType(ExerciseDetailPage), findsOneWidget);
  });
}

// Note: tests that exercise the real DAO save/delete flow live in
// test/data/db/work_log_dao_test.dart. Stitching them through
// pumpWidget here would require running real sqflite_ffi inside
// flutter_test's FakeAsync zone, which deadlocks the I/O completion
// callback. The page-level UI is covered by the provider-override
// tests above; the persistence path is covered by the DAO tests.
