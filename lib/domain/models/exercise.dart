import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_log/domain/models/body_part.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
sealed class Exercise with _$Exercise {
  const Exercise._();

  factory Exercise({
    required String id,
    required String name,
    required Set<BodyPart> bodyParts,
    @Default(<BodyPart>{}) Set<BodyPart> secondaryBodyParts,
  }) = _Exercise;

  factory Exercise.create({
    required String name,
    required Set<BodyPart> bodyParts,
    Set<BodyPart> secondaryBodyParts = const {},
  }) =>
      Exercise(
        id: const Uuid().v4(),
        name: name,
        bodyParts: bodyParts,
        secondaryBodyParts: secondaryBodyParts,
      );

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  /// sqflite row -> Exercise. Accepts both lowerCamelCase (new) and
  /// SCREAMING_CASE (legacy) body-part tokens.
  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        bodyParts: _decodeBodyParts(map['bodyPart'] as String?),
        secondaryBodyParts: _decodeBodyParts(map['secondaryBodyPart'] as String?),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'bodyPart': _encodeBodyParts(bodyParts),
        'secondaryBodyPart': _encodeBodyParts(secondaryBodyParts),
      };
}

String _encodeBodyParts(Set<BodyPart> parts) {
  if (parts.isEmpty) return '';
  return '${parts.map((b) => b.name).join('&')}&';
}

Set<BodyPart> _decodeBodyParts(String? raw) {
  if (raw == null || raw.isEmpty) return <BodyPart>{};
  return raw
      .split('&')
      .where((s) => s.isNotEmpty)
      .map(decodeBodyPart)
      .toSet();
}
