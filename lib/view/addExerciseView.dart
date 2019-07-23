import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/storage.dart';
import 'package:workout_log/util/util.dart';

import 'helloWorldView.dart';

class AddExerciseView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddExerciseView();
}

class _AddExerciseView extends State<AddExerciseView> {
  //  get DB from singleton global provider
  DBProvider db = DBProvider.db;

  Set<BodyPart> bodyParts = Set();

  bool _chest = false;
  bool _back = false;
  bool _arm = false;
  bool _leg = false;
  bool _abdominal = false;
  bool _cardio = false;

  Orientation screenOrientation;
  String editedName;
  TextEditingController myController;
  GlobalKey<ScaffoldState> key;

  @override
  void initState() {
    super.initState();

    key = GlobalKey();

    ///  set initial textField text
    myController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      screenOrientation = orientation;
      return Scaffold(
        key: key,
        appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Add Exercises",
              style: TextStyle(
                color: AppThemeSettings.titleColor,
                fontSize: AppThemeSettings.fontSize,
              ),
            ),
            backgroundColor: AppThemeSettings.appBarColor),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: myController,
                      style: TextStyle(
                        fontSize: AppThemeSettings.headerSize,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text("CHEST"),
                          Checkbox(
                              value: _chest,
                              onChanged: (value) {
                                setState(() {
                                  _chest = value;
                                  updateBP(BodyPart.CHEST, value);
                                });
                              }),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text("BACK"),
                          Checkbox(
                              value: _back,
                              onChanged: (value) {
                                setState(() {
                                  _back = value;
                                  updateBP(BodyPart.BACK, value);
                                });
                              }),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text("ARM"),
                          Checkbox(
                              value: _arm,
                              onChanged: (value) {
                                setState(() {
                                  _arm = value;
                                  updateBP(BodyPart.ARM, value);
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text("LEG"),
                          Checkbox(
                              value: _leg,
                              onChanged: (value) {
                                setState(() {
                                  _leg = value;
                                  updateBP(BodyPart.LEG, value);
                                });
                              }),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text("ABDOMINAL"),
                          Checkbox(
                              value: _abdominal,
                              onChanged: (value) {
                                setState(() {
                                  _abdominal = value;
                                  updateBP(BodyPart.ABDOMINAL, value);
                                });
                              }),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text("CARDIO"),
                          Checkbox(
                              value: _cardio,
                              onChanged: (value) {
                                setState(() {
                                  _cardio = value;
                                  updateBP(BodyPart.CARDIO, value);
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () => saveExercise(),
                    height: (screenOrientation == Orientation.portrait)
                        ? MediaQuery.of(context).size.height * 0.06
                        : MediaQuery.of(context).size.height * 0.1,
                    minWidth: (screenOrientation == Orientation.portrait)
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width * 0.27,
                    color: AppThemeSettings.greenButtonColor,
                    splashColor: AppThemeSettings.buttonSplashColor,
                    textColor: AppThemeSettings.buttonTextColor,
                    child: Text("SAVE"),
                  ),
                  Util.spacerSelectable(top: 30),
                  MaterialButton(
                    onPressed: () => {
                      //  hide keyboard before navigate to previous view
                      FocusScope.of(context).requestFocus(new FocusNode()),
                      Navigator.pop(context),
                    },
                    height: (screenOrientation == Orientation.portrait)
                        ? MediaQuery.of(context).size.height * 0.06
                        : MediaQuery.of(context).size.height * 0.1,
                    minWidth: (screenOrientation == Orientation.portrait)
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width * 0.27,
                    color: AppThemeSettings.cancelButtonColor,
                    splashColor: AppThemeSettings.buttonSplashColor,
                    textColor: AppThemeSettings.buttonTextColor,
                    child: Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void saveExercise() async {
    if (myController.text == null || myController.text.isEmpty) {
      key.currentState.showSnackBar(SnackBar(content: Text("You forgot about exercise name :)")));
      return;
    }

    if (bodyParts == null || bodyParts.isEmpty) {
      key.currentState.showSnackBar(SnackBar(content: Text("You forgot about exercise body part :)")));
      return;
    }

    await addWorkLog(Exercise(myController.text, bodyParts));

    //  hide keyboard before navigate to previous view
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
  }

  Future<WorkLog> addWorkLog(Exercise exercise) async {
    //  get all workLogs from that day
    List<WorkLog> workLogList = await db.getDateAllWorkLogs();

    //  check if workLogs have same exercise name
    for (var w in workLogList) {
      if (w.exercise.name == exercise.name) {
        //  if there is workLog with that exercise name on this day,
        //  but with different bodyPart
        //  update db with this new body part
        w.exercise.bodyParts.addAll(exercise.bodyParts);
        db.updateExercise(w.exercise);
        print("\n [addworklog] UPDATE EXERCISE BP  : ============>  ${w.exercise.toString()}\n ");
        return w;
      }
    }
    WorkLog workLog = WorkLog(exercise);
    workLog.exercise.bodyParts = exercise.bodyParts; // bodyPart as Set()
    workLog.created = HelloWorldView.date;
    String json = jsonEncode(workLog);

    print("\n [addworklog] ADDING NEW WORKLOG  : ============>  ${workLog.toString()}\n ");

    /// save to json
    Storage.writeToFile(json);

    ///  save workLog to DB
    await db.newWorkLog(workLog);

    return workLog;
  }

  void updateBP(BodyPart bodyPart, bool value) {
    if (value)
      bodyParts.add(bodyPart);
    else
      bodyParts.remove(bodyPart);
  }
}
