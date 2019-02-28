import 'package:workout_log/entity/exercise.dart';
import 'package:json_annotation/json_annotation.dart';

// needs to run
// flutter packages pub run build_runner watch
// or
// flutter packages pub run build_runner build
// commend in project root to generate this file
// clearing flutter cashe maybe be necessary
part 'workLog.g.dart';


@JsonSerializable()
class WorkLog {
  int id;
  Exercise exercise;
  int series = 0;
  int repeat = 0;

  WorkLog(this.exercise);

  factory WorkLog.fromJson(Map<String, dynamic> json) => _$WorkLogFromJson(json);

  Map<String, dynamic> toJson() => _$WorkLogToJson(this);
}
