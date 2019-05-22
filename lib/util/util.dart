import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_log/bodyPart/bodyPartInterface.dart';
import 'package:workout_log/bodyPart/workLogView.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appTheme.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/storage.dart';

class Util {
  static TextEditingController textController = TextEditingController();

  //  get DB from singleton global provider
  static DBProvider db = DBProvider.db;

  static String pattern = "yyyy-MM-dd";
  static DateFormat formatter = new DateFormat(pattern);

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
                          addWorkLog(exercise, bp, bodyPart);
                          //  after saving new record bp state need to be updated:
                          bp.updateWorkLogFromDB();
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

  static addWorkLog(
      Exercise exercise, BodyPartInterface bp, BodyPart bodyPart) {
    WorkLog workLog = WorkLog(exercise);
    workLog.exercise.bodyPart = bodyPart;
    String json = jsonEncode(workLog);
    print(json);
    // save to json
    Storage.writeToFile(json);
    //  save workLog to DB
    db.newWorkLog(workLog);
  }

  /// create workLog entry in given bodyPart page
  /// require:
  /// workLog which will be added to widget
  /// BodyPartInterface class which implement it (usually it will call this)
  /// context of application (for screen dimension)
  /// BodyPart of class which call this method
  static Widget createWorkLogRowWidget(
    WorkLog workLog,
    BodyPartInterface bp,
    BuildContext context,
    BodyPart bodyPart,
  ) {
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
              //  sum of workLog series
              workLog.series.length.toString(),
              style: TextStyle(fontSize: AppTheme.fontSize),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.15,

            ///  needs to have 0.15 due to parent widget - flatButton,
            /// which consumed space
            width: MediaQuery.of(context).size.width * 0.15,
            alignment: FractionalOffset(0.8, 0.5),
            child: Text(
              // TODO  sum of workLog repeats
              workLog.series.length.toString(),
              style: TextStyle(fontSize: AppTheme.fontSize),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),

      ///  push workLog and bodyPartInterface to new screen to display it's details
      onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(

                  ///  using Navigator.then to update parent state as well
                  builder: (context) => WorkLogView(workLog: workLog, bp: bp)))
          .then((v) => bp.updateState()),
    );
  }

  static addSeries(BodyPartInterface bp, WorkLog workLog) {
    //  add new series (with incremented number) to workLog with 0 repeats
    workLog.series.putIfAbsent(workLog.series.length + 1, () => "0");
    print("series after +1        " + workLog.series.length.toString());
    bp.updateWorkLogToDB(workLog);
  }

//  static Future editSeriesDialog(
//    BodyPartInterface bp,
//    BuildContext context,
//    WorkLog workLog,
//  ) {
//    return showDialog(
//      context: context,
//      builder: (_) => SimpleDialog(
//            title: Center(child: Text("Edit series number")),
//            contentPadding: EdgeInsets.all(20),
//            children: <Widget>[
//              TextField(
//                // use text controller to save given by user String
//                controller: Util.textController,
//                autofocus: true,
//                autocorrect: true,
//                keyboardType: TextInputType.number,
//                decoration:
//                    InputDecoration(hintText: (workLog.series + 1).toString()),
//                maxLength: 4,
//              ),
//              Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                  children: <Widget>[
//                    FlatButton(
//                        child: const Text('SAVE'),
//                        onPressed: () {
//                          // TODO call setState to change in UI
//                          workLog.series = int.parse(textController.text);
//                          bp.updateWorkLogToDB(workLog);
//                          Navigator.pop(context);
//                        }),
//                    FlatButton(
//                        child: const Text('CANCEL'),
//                        onPressed: () {
//                          Navigator.pop(context);
//                        }),
//                  ]),
//            ],
//          ),
//    );
//  }

  static Future editRepeatsDialog(
      BodyPartInterface bp,
      BuildContext context,
      WorkLog workLog,
      int set) {
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text("Edit repeats number")),
            contentPadding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(
                // use text controller to save given by user String
                controller: Util.textController,
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(hintText: workLog.series[set].toString()),
                maxLength: 4,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // TODO call setState to change in UI
                          //  set repeat number of this set
                          workLog.series[set] = textController.text;
                          bp.updateWorkLogToDB(workLog);
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

  //  TODO use it
  static Future editExerciseNameDialog(
    BodyPartInterface bp,
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
