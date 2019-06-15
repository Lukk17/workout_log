import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appTheme.dart';

class Util {
  static TextEditingController _textController = TextEditingController();

  static TextEditingController textController() {
    _textController.clear();
    return _textController;
  }

  static String pattern = "yyyy-MM-dd";
  static DateFormat formatter = new DateFormat(pattern);

  static BodyPart recreateBodyPart(String bodyPart) {
    print("enum $bodyPart");
    switch (bodyPart) {
      case "CHEST":
        return BodyPart.CHEST;

      case "BACK":
        return BodyPart.BACK;

      case "LEG":
        return BodyPart.LEG;

      case "ARM":
        return BodyPart.ARM;

      case "CARDIO":
        return BodyPart.CARDIO;

      default:
        return BodyPart.UNDEFINED;
    }
  }

  //  TODO use it
  static Future editExerciseNameDialog(
    BuildContext context,
    TextEditingController textController,
    BodyPart bodyPart,
    WorkLog workLog,
  ) {
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text("Edit exercise name")),
            contentPadding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(
                // use text controller to save given by user String
                controller: textController,
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(hintText: workLog.exercise.name),
                maxLength: 50,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // TODO call setState to change in UI
                          workLog.exercise.name = textController.text;
                          Navigator.pop(context);
                        }),
                    FlatButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ]),
            ],
          ),
    );
  }

  static Widget addHorizontalLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppThemeSettings.borderColor),
        ),
      ),
    );
  }

  static Widget addVerticalLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppThemeSettings.borderColor),
        ),
      ),
    );
  }
}
