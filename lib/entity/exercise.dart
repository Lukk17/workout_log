import 'package:json_annotation/json_annotation.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:uuid/uuid.dart';

// needs to run in terminal within project dir:
// flutter packages pub run build_runner watch
// or
// flutter packages pub run build_runner build
// commend in project root to generate this file
// clearing flutter cashe maybe be necessary
part 'exercise.g.dart';

@JsonSerializable()
class Exercise {
  //  ID generate based on time (UUID.v1)
  String id = Uuid().v1();

  String name;
  BodyPart bodyPart;

  Exercise(this.name, this.bodyPart);

  // for Json serializable
  // auto-create addition files for file XXX.dart - XXX.g.dart
  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
