import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_log/entity/bodyPart.dart';

part 'exercise.g.dart';

// needs to run in terminal within project dir:
// flutter packages pub run build_runner watch
// or
// flutter packages pub run build_runner build
// commend in project root to generate this file
// clearing flutter cache maybe be necessary

@JsonSerializable()
class Exercise {
  static final Logger _log = new Logger("Exercise");

  //  ID generate based on time (UUID.v1)
  String id = Uuid().v1();

  //  initialize name to avoid nullPointer when user will not add any name
  String name = "";

  Set<BodyPart> bodyParts;
  Set<BodyPart> secondaryBodyParts = Set();

  Exercise(this.name, this.bodyParts, [secondaryBodyParts]) {
    this.secondaryBodyParts = secondaryBodyParts;
  }

  // for Json serializable
  // auto-create addition files for file XXX.dart - XXX.g.dart
  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  //  needed for SQLite
  factory Exercise.fromMap(Map<String, dynamic> json) {
    Set<BodyPart> bp = recreateBodyPart(json["bodyPart"]);
    Set<BodyPart> secondaryBp = recreateBodyPart(json["secondaryBodyPart"]);

    Exercise e = Exercise(
      //  get from given map
      json["name"],
      bp,
      secondaryBp,
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
        "bodyPart": bodyPartsToString(bodyParts),
        "secondaryBodyPart": bodyPartsToString(secondaryBodyParts),
      };

  String bodyPartsToString(Set<BodyPart> bodyPartsList) {
    StringBuffer result = StringBuffer();

    for (var b in bodyPartsList) {
      result.write(b.toString().substring(b.toString().indexOf('.') + 1));
      result.write("&");
    }
    return result.toString();
  }

  static Set<BodyPart> recreateBodyPart(String bodyPart) {
    Set<BodyPart> result = Set();
    //  BodyParts are divided by "&" symbol
    //  need to split by it and compare with enum types
    // try/catch if list is empty
    try {
      List<String> bodyParts = bodyPart.split("&");

      for (var s in bodyParts) {
        if (s.isNotEmpty) {
          switch (s) {
            case "CHEST":
              result.add(BodyPart.CHEST);
              break;

            case "BACK":
              result.add(BodyPart.BACK);
              break;

            case "LEG":
              result.add(BodyPart.LEG);
              break;

            case "ARM":
              result.add(BodyPart.ARM);
              break;

            case "CARDIO":
              result.add(BodyPart.CARDIO);
              break;

            case "ABDOMINAL":
              result.add(BodyPart.ABDOMINAL);
              break;

            default:
              result.add(BodyPart.UNDEFINED);
              break;
          }
        }
      }
    } on Exception catch (e) {
      _log.warning("empty list", e.toString());
    }
    return result;
  }

  String toString() {
    StringBuffer result = StringBuffer();

    result.write(" EXERCISE: \t");
    result.write(" ID: ");
    result.write(this.id);
    result.write(" NAME: ");
    result.write(this.name);
    result.write(" BODY PARTS: ");
    result.write(this.bodyParts.toString());
    result.write(" SECONDARY BODY PARTS: ");
    result.write(this.secondaryBodyParts.toString());

    return result.toString();
  }
}
