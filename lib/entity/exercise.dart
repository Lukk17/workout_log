import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/util/util.dart';

part 'exercise.g.dart';

// needs to run in terminal within project dir:
// flutter packages pub run build_runner watch
// or
// flutter packages pub run build_runner build
// commend in project root to generate this file
// clearing flutter cache maybe be necessary

@JsonSerializable()
class Exercise {
  //  ID generate based on time (UUID.v1)
  String id = Uuid().v1();

  //  initialize name to avoid nullPointer when user will not add any name
  String name = "";

  BodyPart bodyPart;

  Exercise(this.name, this.bodyPart);

  // for Json serializable
  // auto-create addition files for file XXX.dart - XXX.g.dart
  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  //  needed for SQLite
  factory Exercise.fromMap(Map<String, dynamic> json) {

    BodyPart bp = Util.recreateBodyPart(json["bodyPart"]);

    Exercise e = Exercise(
      //  get from given map
      json["name"],
      bp,
    );
    ///  id needed to be saved as it is in json,
    ///  otherwise id will again generated,
    ///  which will be incoherent with DB entry
    e.id = json["id"];
    return e;
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "bodyPart":
            bodyPart.toString().substring(bodyPart.toString().indexOf('.') + 1),
      };

}
