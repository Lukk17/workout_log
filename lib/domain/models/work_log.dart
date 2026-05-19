import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/util/date_format.dart';

part 'work_log.freezed.dart';
part 'work_log.g.dart';

// Truncating to start-of-day prevents same-day workouts from sorting
// across day boundaries when constructed near midnight, and matches the
// sqflite `created` column format (YYYY-MM-DD).
DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

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

  factory WorkLog.create({required Exercise exercise, DateTime? on}) =>
      WorkLog(
        id: const Uuid().v4(),
        exercise: exercise,
        created: _startOfDay(on ?? DateTime.now()),
      );

  factory WorkLog.fromJson(Map<String, dynamic> json) =>
      _$WorkLogFromJson(json);

  factory WorkLog.fromMap(Map<String, dynamic> map, Exercise e) {
    // The map<String,dynamic> cast on series/load handles legacy rows
    // that wrote int values where we now store strings.
    final seriesRaw =
        jsonDecode(map['series'] as String) as Map<String, dynamic>;
    final loadRaw = jsonDecode(map['load'] as String) as Map<String, dynamic>;
    return WorkLog(
      id: map['id'] as String,
      exercise: e,
      created: _startOfDay(DateTime.parse(map['created'] as String)),
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
        'created': dateFormatter.format(created),
      };

  String getReps(String set) => series[set] ?? '';

  String getLoad(String set) => load[set] ?? '';

  String getRepsSum() {
    final sum = series.values.fold<int>(0, (s, v) => s + int.parse(v));
    return sum.toString();
  }
}
