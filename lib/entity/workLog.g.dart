// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workLog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkLog _$WorkLogFromJson(Map<String, dynamic> json) => WorkLog(
      Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
    )
      ..id = json['id'] as String
      ..series = json['series'] as Map<String, dynamic>
      ..load = json['load'] as Map<String, dynamic>
      ..created = DateTime.parse(json['created'] as String)
      ..bodyWeight = (json['bodyWeight'] as num).toDouble();

Map<String, dynamic> _$WorkLogToJson(WorkLog instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exercise,
      'series': instance.series,
      'load': instance.load,
      'created': instance.created.toIso8601String(),
      'bodyWeight': instance.bodyWeight,
    };
