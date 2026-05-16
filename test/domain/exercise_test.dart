import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';

void main() {
  group('Exercise (freezed)', () {
    test('value equality: two exercises with same fields are equal', () {
      final a = Exercise(
        id: 'fixed-id',
        name: 'Bench',
        bodyParts: {BodyPart.chest},
        secondaryBodyParts: {BodyPart.arm},
      );
      final b = Exercise(
        id: 'fixed-id',
        name: 'Bench',
        bodyParts: {BodyPart.chest},
        secondaryBodyParts: {BodyPart.arm},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith produces a new instance', () {
      final original = Exercise.create(name: 'Bench', bodyParts: {BodyPart.chest});
      final updated = original.copyWith(name: 'Dip');
      expect(updated.name, 'Dip');
      expect(original.name, 'Bench');
      expect(identical(original, updated), isFalse);
    });

    test('Exercise.create assigns a v4 UUID', () {
      final ex = Exercise.create(name: 'X', bodyParts: {BodyPart.arm});
      // UUID v4: position 14 in canonical form is "4"
      expect(ex.id.length, greaterThanOrEqualTo(36));
      expect(ex.id[14], equals('4'));
    });
  });

  group('BodyPart serialization', () {
    test('legacy SCREAMING_CASE token deserializes to lowerCamelCase enum', () {
      final row = {
        'id': 'legacy-1',
        'name': 'Legacy',
        'bodyPart': 'CHEST&BACK&',
        'secondaryBodyPart': 'ARM&',
      };
      final ex = Exercise.fromMap(row);
      expect(ex.bodyParts, equals({BodyPart.chest, BodyPart.back}));
      expect(ex.secondaryBodyParts, equals({BodyPart.arm}));
    });

    test('new lowerCamelCase token deserializes round-trip', () {
      final row = {
        'id': 'new-1',
        'name': 'New',
        'bodyPart': 'chest&back&',
        'secondaryBodyPart': '',
      };
      final ex = Exercise.fromMap(row);
      expect(ex.bodyParts, equals({BodyPart.chest, BodyPart.back}));
      expect(ex.secondaryBodyParts, isEmpty);
    });

    test('unknown token falls back to BodyPart.undefined without throwing', () {
      final row = {
        'id': 'weird-1',
        'name': 'Weird',
        'bodyPart': 'NOSUCHPART&',
        'secondaryBodyPart': '',
      };
      final ex = Exercise.fromMap(row);
      expect(ex.bodyParts, equals({BodyPart.undefined}));
    });

    test('toMap encodes lowerCamelCase with trailing &', () {
      final ex = Exercise(
        id: 'x',
        name: 'X',
        bodyParts: {BodyPart.chest, BodyPart.back},
      );
      final map = ex.toMap();
      // Set iteration order is not guaranteed, so check both possibilities.
      expect(
        map['bodyPart'],
        anyOf('chest&back&', 'back&chest&'),
      );
    });

    test('empty body parts encode to empty string', () {
      final ex = Exercise(id: 'x', name: 'X', bodyParts: {});
      expect(ex.toMap()['bodyPart'], '');
    });
  });

  group('decodeBodyPart helper', () {
    test('accepts both cases for every known body part', () {
      expect(decodeBodyPart('chest'), BodyPart.chest);
      expect(decodeBodyPart('CHEST'), BodyPart.chest);
      expect(decodeBodyPart('Back'), BodyPart.back);
      expect(decodeBodyPart('CARDIO'), BodyPart.cardio);
    });

    test('garbage input falls back to undefined', () {
      expect(decodeBodyPart('foo'), BodyPart.undefined);
      expect(decodeBodyPart(''), BodyPart.undefined);
    });
  });
}
