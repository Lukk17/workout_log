import 'package:json_annotation/json_annotation.dart';
import 'package:workout_log/entity/bodyPart.dart';

part 'exercise.g.dart';

@JsonSerializable()
class Exercise {
  String name;
  BodyPart bodyPart;

  Exercise(this.name, this.bodyPart);

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

}
