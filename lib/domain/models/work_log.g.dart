// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkLog _$WorkLogFromJson(Map<String, dynamic> json) =>
    _WorkLog(
      id: json['id'] as String,
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      created: DateTime.parse(json['created'] as String),
      series:
      (json['series'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
      ) ??
          const <String, String>{},
      load:
      (json['load'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
      ) ??
          const <String, String>{},
      bodyWeight: (json['bodyWeight'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$WorkLogToJson(_WorkLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exercise,
      'created': instance.created.toIso8601String(),
      'series': instance.series,
      'load': instance.load,
      'bodyWeight': instance.bodyWeight,
    };
