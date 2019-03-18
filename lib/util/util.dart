import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workout_log/bodyPart/bodyPartInterface.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appTheme.dart';
import 'package:workout_log/util/storage.dart';

class Util {
  static TextEditingController textController = TextEditingController();

  static Future showAddWorkLogDialog(
    BodyPartInterface bp,
    String title,
    String hint,
    BuildContext context,
    BodyPart bodyPart,
  ) {
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text(title)),
            contentPadding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(
                // use text controller to save given by user String
                controller: textController,
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(hintText: hint),
                maxLength: 50,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // text is forwarded by controller from SimpleDialog text field
                          Exercise exercise =
                              Exercise(textController.text, bodyPart);
                          print("EXEEEERSISEEEEE         " + exercise.id);
                          addWorkLog(exercise, bp);
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

  static addWorkLog(Exercise exercise, BodyPartInterface bp) {
    print("adding worklog");
    WorkLog workLog = WorkLog(exercise);
    String json = jsonEncode(workLog);
    print(json);
    // save to json
    Storage.writeToFile(json);
    //  save worklog to DB
    bp.saveWorkLogToDB(workLog);
  }

  /// require:
  /// worklog which will be added to widget
  /// BodyPartInterface class which implement it (usually it will call this)
  /// context of application (for screen dimension)
  /// BodyPart of class which call this method
  static Widget createWorkLogRowWidget(
    WorkLog workLog,
    BodyPartInterface bp,
    BuildContext context,
    BodyPart bodyPart,
  ) {
//    context.findRenderObject();
    return FlatButton(
      child: Row(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.5,
            alignment: FractionalOffset(0.5, 0.5),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppTheme.borderColor),
              ),
            ),
              child: Text(
                workLog.exercise.name,
                style: TextStyle(fontSize: AppTheme.fontSize),
                textAlign: TextAlign.center,
              ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.25,
            alignment: FractionalOffset(0.5, 0.5),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            child: Text(
              workLog.series.toString(),
              style: TextStyle(fontSize: AppTheme.fontSize),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            //  needs to have 0.15 due to parent widget - flatbutton,
            // which consumed space
            width: MediaQuery.of(context).size.width * 0.15,
            alignment: FractionalOffset(0.8, 0.5),
            child: Text(
              workLog.repeat.toString(),
              style: TextStyle(fontSize: AppTheme.fontSize),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
      onPressed: () => editExerciseNameDialog(
          bp, context, textController, bodyPart, workLog),
    );
  }

  static Future editSeriesDialog(
    BodyPartInterface bp,
    BuildContext context,
    TextEditingController textController,
    BodyPart bodyPart,
    WorkLog worklog,
  ) {
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text("Edit series number")),
            contentPadding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(
                // use text controller to save given by user String
                controller: textController,
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(hintText: worklog.series.toString()),
                maxLength: 4,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // TODO call setState to change in UI
                          worklog.series = int.parse(textController.text);
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

  static Future editRepeatsDialog(
    BodyPartInterface bp,
    BuildContext context,
    TextEditingController textController,
    BodyPart bodyPart,
    WorkLog worklog,
  ) {
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text("Edit repeats number")),
            contentPadding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(
                // use text controller to save given by user String
                controller: textController,
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(hintText: worklog.repeat.toString()),
                maxLength: 4,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // TODO call setState to change in UI
                          worklog.repeat = int.parse(textController.text);
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

  static Future editExerciseNameDialog(
    BodyPartInterface bp,
    BuildContext context,
    TextEditingController textController,
    BodyPart bodyPart,
    WorkLog worklog,
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
                decoration: InputDecoration(hintText: worklog.exercise.name),
                maxLength: 50,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // TODO call setState to change in UI
                          worklog.exercise.name = textController.text;
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
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }

  static Widget addVerticalLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }
}
