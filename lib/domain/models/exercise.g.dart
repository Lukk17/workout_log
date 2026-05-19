// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) =>
    _Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      bodyParts: (json['bodyParts'] as List<dynamic>)
          .map((e) => $enumDecode(_$BodyPartEnumMap, e))
          .toSet(),
      secondaryBodyParts:
      (json['secondaryBodyParts'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$BodyPartEnumMap, e))
          .toSet() ??
          const <BodyPart>{},
    );

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bodyParts': instance.bodyParts
          .map((e) => _$BodyPartEnumMap[e]!)
          .toList(),
      'secondaryBodyParts': instance.secondaryBodyParts
          .map((e) => _$BodyPartEnumMap[e]!)
          .toList(),
    };

const _$BodyPartEnumMap = {
  BodyPart.chest: 'chest',
  BodyPart.back: 'back',
  BodyPart.arm: 'arm',
  BodyPart.leg: 'leg',
  BodyPart.abdominal: 'abdominal',
  BodyPart.cardio: 'cardio',
  BodyPart.undefined: 'undefined',
};
