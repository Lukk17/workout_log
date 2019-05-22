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

  //TODO series as List, where each position number is series number and value stored is repeat number
  //TODO for example: list[1]=5 > mean that in 1 series there were 5 repeats
  Map<dynamic, String> series = Map();


  //  Date for SQLite must be in format:
  //  YYYY-MM-DD
  DateTime created = DateTime.now();

  WorkLog(this.exercise);

  // for Json serializable
  // auto-create addition files for file XXX.dart - XXX.g.dart
  factory WorkLog.fromJson(Map<String, dynamic> json) =>
      _$WorkLogFromJson(json);

  Map<String, dynamic> toJson() => _$WorkLogToJson(this);

  //  needed for SQLite
  factory WorkLog.fromMap(Map<String, dynamic> json, Exercise e) {
    print('$json');
    WorkLog result = WorkLog(e);
    result.id = json["id"];
    result.series = seriesFromString(json["series"]);
    result.created = DateTime.parse(json["created"]);
    return result;
  }

  static Map<dynamic, String> seriesFromString(String series){

    Map<dynamic, String> result = Map();

    // TODO repair repeats
    if(series.contains("=")) {
      List<String> multiSet = series.split(",");
      for (String set in multiSet) {
        List<String> singleSet = set.split("=");
        // singleSet[0] set
        // singleSet[1] repeats
        result.putIfAbsent(singleSet[0], () => singleSet[1]);
      }
    }

    return result;
  }


  Map<String, dynamic> toMap() => {
        "id": id,
        "exercise_id": exercise.id,
        "series": series,
        "created": Util.formatter.format(created),
      };
}
