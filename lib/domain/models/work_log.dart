import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/util/util.dart';

part 'work_log.freezed.dart';
part 'work_log.g.dart';

@freezed
sealed class WorkLog with _$WorkLog {
  const WorkLog._();

  factory WorkLog({
    required String id,
    required Exercise exercise,
    required DateTime created,
    @Default(<String, String>{}) Map<String, String> series,
    @Default(<String, String>{}) Map<String, String> load,
    @Default(0.0) double bodyWeight,
  }) = _WorkLog;

  factory WorkLog.create({required Exercise exercise}) => WorkLog(
        id: const Uuid().v4(),
        exercise: exercise,
        created: DateTime.now(),
      );

  factory WorkLog.fromJson(Map<String, dynamic> json) =>
      _$WorkLogFromJson(json);

  /// sqflite row -> WorkLog. Coerces hostile series/load JSON (mixed
  /// int/string values from legacy code) into typed `Map<String, String>`.
  factory WorkLog.fromMap(Map<String, dynamic> map, Exercise e) {
    final seriesRaw = jsonDecode(map['series'] as String) as Map<String, dynamic>;
    final loadRaw = jsonDecode(map['load'] as String) as Map<String, dynamic>;
    return WorkLog(
      id: map['id'] as String,
      exercise: e,
      created: DateTime.parse(map['created'] as String),
      series: seriesRaw.map((k, v) => MapEntry(k, v.toString())),
      load: loadRaw.map((k, v) => MapEntry(k, v.toString())),
      bodyWeight: (map['bodyWeight'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'bodyWeight': bodyWeight,
        'exercise_id': exercise.id,
        'series': jsonEncode(series),
        'load': jsonEncode(load),
        'created': Util.formatter.format(created),
      };

  String getReps(String set) => series[set] ?? '';

  String getLoad(String set) => load[set] ?? '';

  String getRepsSum() {
    final sum = series.values.fold<int>(0, (s, v) => s + int.parse(v));
    return sum.toString();
  }
}
