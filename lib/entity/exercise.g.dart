// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  return Exercise(
      json['name'] as String,
      (json['bodyParts'] as List)
          ?.map((e) => _$enumDecodeNullable(_$BodyPartEnumMap, e))
          ?.toSet())
    ..id = json['id'] as String
    ..secondaryBodyParts = (json['secondaryBodyParts'] as List)
        ?.map((e) => _$enumDecodeNullable(_$BodyPartEnumMap, e))
        ?.toSet();
}

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bodyParts':
          instance.bodyParts?.map((e) => _$BodyPartEnumMap[e])?.toList(),
      'secondaryBodyParts': instance.secondaryBodyParts
          ?.map((e) => _$BodyPartEnumMap[e])
          ?.toList()
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$BodyPartEnumMap = <BodyPart, dynamic>{
  BodyPart.CHEST: 'CHEST',
  BodyPart.BACK: 'BACK',
  BodyPart.ARM: 'ARM',
  BodyPart.LEG: 'LEG',
  BodyPart.ABDOMINAL: 'ABDOMINAL',
  BodyPart.CARDIO: 'CARDIO',
  BodyPart.UNDEFINED: 'UNDEFINED'
};
