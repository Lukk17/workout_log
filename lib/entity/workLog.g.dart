// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workLog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkLog _$WorkLogFromJson(Map<String, dynamic> json) {
  return WorkLog(json['exercise'] == null
      ? null
      : Exercise.fromJson(json['exercise'] as Map<String, dynamic>))
    ..id = json['id'] as int
    ..series = json['series'] as int
    ..repeat = json['repeat'] as int;
}

Map<String, dynamic> _$WorkLogToJson(WorkLog instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exercise,
      'series': instance.series,
      'repeat': instance.repeat
    };
