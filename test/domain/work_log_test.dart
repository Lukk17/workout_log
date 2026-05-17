import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';

void main() {
  Exercise sampleExercise() => Exercise(
        id: 'ex-1',
        name: 'Bench',
        bodyParts: {BodyPart.chest},
      );

  group('WorkLog (freezed)', () {
    test('value equality', () {
      final created = DateTime(2026, 5, 16);
      final a = WorkLog(id: 'w-1', exercise: sampleExercise(), created: created);
      final b = WorkLog(id: 'w-1', exercise: sampleExercise(), created: created);
      expect(a, equals(b));
    });

    test('copyWith does not mutate the original', () {
      final original = WorkLog.create(exercise: sampleExercise());
      final updated = original.copyWith(bodyWeight: 80);
      expect(updated.bodyWeight, 80);
      expect(original.bodyWeight, 0);
    });

    test('WorkLog.create assigns a v4 UUID', () {
      final w = WorkLog.create(exercise: sampleExercise());
      expect(w.id.length, greaterThanOrEqualTo(36));
      expect(w.id[14], '4');
    });
  });

  group('WorkLog.create date normalization', () {
    test('default `created` is start-of-day local time', () {
      final w = WorkLog.create(exercise: sampleExercise());
      expect(w.created.hour, 0);
      expect(w.created.minute, 0);
      expect(w.created.second, 0);
      expect(w.created.millisecond, 0);
    });

    test('`on:` parameter is truncated to start-of-day', () {
      final w = WorkLog.create(
        exercise: sampleExercise(),
        on: DateTime(2026, 5, 16, 23, 59, 59, 999),
      );
      expect(w.created, DateTime(2026, 5, 16));
    });

    test('fromMap normalizes legacy full-ISO timestamps to start-of-day', () {
      final row = {
        'id': 'w-1',
        'bodyWeight': 0.0,
        'exercise_id': 'ex-1',
        'series': '{}',
        'load': '{}',
        // Legacy install wrote a full ISO timestamp via toIso8601String.
        'created': '2026-05-16T23:59:59.999',
      };
      final w = WorkLog.fromMap(row, sampleExercise());
      expect(w.created, DateTime(2026, 5, 16));
    });
  });

  group('getRepsSum', () {
    test('sums string-typed series values', () {
      final w = WorkLog(
        id: 'w-1',
        exercise: sampleExercise(),
        created: DateTime(2026, 5, 16),
        series: {'1': '10', '2': '8', '3': '6'},
      );
      expect(w.getRepsSum(), '24');
    });

    test('empty series sums to 0', () {
      final w = WorkLog.create(exercise: sampleExercise());
      expect(w.getRepsSum(), '0');
    });
  });

  group('fromMap', () {
    test('coerces hostile mixed int/string series into Map<String,String>', () {
      final row = {
        'id': 'w-1',
        'bodyWeight': 75.0,
        'exercise_id': 'ex-1',
        'series': jsonEncode({'1': 10, '2': '8'}),
        'load': jsonEncode({'1': '50'}),
        'created': '2026-05-16',
      };
      final w = WorkLog.fromMap(row, sampleExercise());
      expect(w.series, equals({'1': '10', '2': '8'}));
      expect(w.load, equals({'1': '50'}));
      expect(w.bodyWeight, 75.0);
      expect(w.created, DateTime(2026, 5, 16));
    });

    test('null bodyWeight coerces to 0', () {
      final row = {
        'id': 'w-2',
        'bodyWeight': null,
        'exercise_id': 'ex-1',
        'series': jsonEncode(<String, String>{}),
        'load': jsonEncode(<String, String>{}),
        'created': '2026-05-16',
      };
      final w = WorkLog.fromMap(row, sampleExercise());
      expect(w.bodyWeight, 0.0);
    });
  });

  group('toMap', () {
    test('encodes series and load as JSON strings', () {
      final w = WorkLog(
        id: 'w-1',
        exercise: sampleExercise(),
        created: DateTime(2026, 5, 16),
        series: {'1': '10'},
        load: {'1': '50'},
        bodyWeight: 75.0,
      );
      final map = w.toMap();
      expect(map['series'], jsonEncode({'1': '10'}));
      expect(map['load'], jsonEncode({'1': '50'}));
      expect(map['created'], '2026-05-16');
      expect(map['exercise_id'], 'ex-1');
    });
  });
}
