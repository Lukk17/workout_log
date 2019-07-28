import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/util/util.dart';

part 'workLog.g.dart';

// needs to run in terminal within project dir:
// flutter packages pub run build_runner watch
// or
// flutter packages pub run build_runner build
// commend in project root to generate this file
// clearing flutter cache maybe be necessary

@JsonSerializable()
class WorkLog {
  //  int id; OLD
  //  ID generate based on time (UUID.v1)
  String id = Uuid().v1();

  Exercise exercise;

  Map<dynamic, dynamic> series = Map();
  Map<dynamic, dynamic> load = Map();

  //  Date for SQLite must be in format:
  //  YYYY-MM-DD
  DateTime created = DateTime.now();

  double bodyWeight = 0;

  WorkLog(this.exercise);

  // for Json serializable
  // auto-create addition files for file XXX.dart - XXX.g.dart
  factory WorkLog.fromJson(Map<String, dynamic> json) => _$WorkLogFromJson(json);

  Map<String, dynamic> toJson() => _$WorkLogToJson(this);

  //  needed for SQLite
  factory WorkLog.fromMap(Map<String, dynamic> map, Exercise e) {
    WorkLog result = WorkLog(e);
    result.id = map["id"];
    result.bodyWeight = map["bodyWeight"];
    //  decode json, which is string from DB to series map
    result.series = jsonDecode(map["series"]);
    result.load = jsonDecode(map["load"]);

    result.created = DateTime.parse(map["created"]);
    return result;
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "bodyWeight": bodyWeight,
        "exercise_id": exercise.id,
        //  encode map as json for easy storing as text in DB
        "series": json.encode(series),
        "load": json.encode(load),

        "created": Util.formatter.format(created),
      };

  String getReps(String set) {
    return series[set];
  }

  String getLoad(String set) {
    return load[set];
  }

  String getRepsSum() {
    int sum = 0;
    series.forEach((f, v) => {sum += int.parse(v)});
    return sum.toString();
  }

  String getBodyPart() {
    return exercise.bodyParts.toString().substring(exercise.bodyParts.toString().indexOf('.') + 1);
  }

  String toString() {
    StringBuffer result = StringBuffer();

    result.write(" WORKLOG \t");
    result.write(" ID: ");
    result.write(this.id);
    result.write(" CREATED: ");
    result.write(this.created);
    result.write(" SERIES: ");
    result.write(this.series.toString());
    result.write(" LOAD: ");
    result.write(this.load.toString());
    result.write("\t\t");
    result.write(this.exercise.toString());

    return result.toString();
  }
}
