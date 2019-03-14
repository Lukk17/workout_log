import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_log/entity/exercise.dart';

part 'workLog.g.dart';

// needs to run in terminal within project dir:
// flutter packages pub run build_runner watch
// or
// flutter packages pub run build_runner build
// commend in project root to generate this file
// clearing flutter cashe maybe be necessary

@JsonSerializable()
class WorkLog {
//  int id; OLD
//  ID generate based on time (UUID.v1)
  String id = Uuid().v1();

  Exercise exercise;
  int series = 0;
  int repeat = 0;

  //  Date for SQLITE must be in format:
  //  YYYY-MM-DD
  DateTime created = DateTime.now();

  WorkLog(this.exercise);

  // for Json serializable
  // auto-create addition files for file XXX.dart - XXX.g.dart
  factory WorkLog.fromJson(Map<String, dynamic> json) =>
      _$WorkLogFromJson(json);

  Map<String, dynamic> toJson() => _$WorkLogToJson(this);

  factory WorkLog.fromMap(Map<String, dynamic> json) => new WorkLog(
        //  get from given map
        json["exercise"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
//        "exercise": exercise,
        "series": series,
        "repeat": repeat,
//        "created": created,
      };
/*
    WITHOUT LAMBDA:

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      "id": id,
      "exercise": exercise,
      "series": series,
      "repeat": repeat,
      "created": created,
    };
    return map;
  }
  */
}
