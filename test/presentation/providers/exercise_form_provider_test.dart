import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/presentation/providers/exercise_form_provider.dart';

void main() {
  group('ExerciseFormState.from', () {
    test('null exercise -> two empty sets', () {
      final s = ExerciseFormState.from(null);

      expect(s.primary, isEmpty);
      expect(s.secondary, isEmpty);
    });

    test('existing exercise -> seeds both sets from its body parts',
        () {
      final ex = Exercise.create(
        name: 'Bench',
        bodyParts: {BodyPart.chest, BodyPart.arm},
        secondaryBodyParts: {BodyPart.back},
      );

      final s = ExerciseFormState.from(ex);

      expect(s.primary, {BodyPart.chest, BodyPart.arm});
      expect(s.secondary, {BodyPart.back});
    });
  });

  group('togglePrimary', () {
    test('adds to primary when value=true', () {
      final n = ExerciseFormNotifier(null);

      n.togglePrimary(BodyPart.chest, value: true);

      expect(n.state.primary, {BodyPart.chest});
      expect(n.state.secondary, isEmpty);
    });

    test('removes from primary when value=false', () {
      final n = ExerciseFormNotifier(null)..togglePrimary(BodyPart.chest, value: true);

      n.togglePrimary(BodyPart.chest, value: false);

      expect(n.state.primary, isEmpty);
    });

    test('value=true moves an existing secondary into primary', () {
      // Otherwise the same body part would sit in both sets at once,
      // which is exactly the bug the toggle is supposed to prevent.
      final n = ExerciseFormNotifier(null)
        ..toggleSecondary(BodyPart.chest, value: true);

      n.togglePrimary(BodyPart.chest, value: true);

      expect(n.state.primary, {BodyPart.chest});
      expect(n.state.secondary, isEmpty);
    });
  });

  group('toggleSecondary', () {
    test('adds to secondary when value=true', () {
      final n = ExerciseFormNotifier(null);

      n.toggleSecondary(BodyPart.back, value: true);

      expect(n.state.secondary, {BodyPart.back});
      expect(n.state.primary, isEmpty);
    });

    test('value=true moves an existing primary into secondary', () {
      final n = ExerciseFormNotifier(null)
        ..togglePrimary(BodyPart.back, value: true);

      n.toggleSecondary(BodyPart.back, value: true);

      expect(n.state.secondary, {BodyPart.back});
      expect(n.state.primary, isEmpty);
    });

    test('removes from secondary when value=false', () {
      final n = ExerciseFormNotifier(null)
        ..toggleSecondary(BodyPart.arm, value: true);

      n.toggleSecondary(BodyPart.arm, value: false);

      expect(n.state.secondary, isEmpty);
    });
  });
}
