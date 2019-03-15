// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workLog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkLog _$WorkLogFromJson(Map<String, dynamic> json) {
  return WorkLog(json['exercise'] == null
      ? null
      : Exercise.fromJson(json['exercise'] as Map<String, dynamic>))
    ..id = json['id'] as String
    ..series = json['series'] as int
    ..repeat = json['repeat'] as int
    ..created = json['created'] == null
        ? null
        : DateTime.parse(json['created'] as String);
}

Map<String, dynamic> _$WorkLogToJson(WorkLog instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exercise,
      'series': instance.series,
      'repeat': instance.repeat,
      'created': instance.created?.toIso8601String()
    };
