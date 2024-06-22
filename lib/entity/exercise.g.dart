// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      json['name'] as String,
      (json['bodyParts'] as List<dynamic>)
          .map((e) => $enumDecode(_$BodyPartEnumMap, e))
          .toSet(),
      json['secondaryBodyParts'],
    )..id = json['id'] as String;

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bodyParts':
          instance.bodyParts.map((e) => _$BodyPartEnumMap[e]!).toList(),
      'secondaryBodyParts': instance.secondaryBodyParts
          .map((e) => _$BodyPartEnumMap[e]!)
          .toList(),
    };

const _$BodyPartEnumMap = {
  BodyPart.CHEST: 'CHEST',
  BodyPart.BACK: 'BACK',
  BodyPart.ARM: 'ARM',
  BodyPart.LEG: 'LEG',
  BodyPart.ABDOMINAL: 'ABDOMINAL',
  BodyPart.CARDIO: 'CARDIO',
  BodyPart.UNDEFINED: 'UNDEFINED',
};
