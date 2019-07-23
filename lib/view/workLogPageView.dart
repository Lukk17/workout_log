import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/storage.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/exerciseView.dart';
import 'package:workout_log/view/helloWorldView.dart';

import '../main.dart';
import 'addExerciseView.dart';

/// This is main WorkLog view.
///
/// It show actual date, and buttons with body parts.
/// Each buttons leads to BodyPartLogView page of selected body part.
class WorkLogPageView extends StatefulWidget {
  final Function(Widget) callback;
  final DateTime date;

  WorkLogPageView(this.callback, this.date);

  @override
  State<StatefulWidget> createState() => _WorkLogPageViewState();
}

class _WorkLogPageViewState extends State<WorkLogPageView> {
  Orientation screenOrientation;

  //  to save helloWorld scaffold key
  final GlobalKey<ScaffoldState> scaffoldKey = MyApp.globalKey;
  GlobalKey key = GlobalKey();

  //  get DB from singleton global provider
  DBProvider db = DBProvider.db;

  static List<Widget> wList = List();
  List<MaterialButton> exerciseList = List();

  @override
  void initState() {
    super.initState();
    updateWorkLogFromDB();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      screenOrientation = orientation;
      return Column(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            alignment: Alignment(0, 0.8),
            child: Text(
              Util.formatter.format(HelloWorldView.date) == Util.formatter.format(DateTime.now())
                  ? "Today"
                  : Util.formatter.format(HelloWorldView.date),
              textScaleFactor: 3,
              style: TextStyle(color: AppThemeSettings.textColor, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Column(
                      children: wList,
                    ),
                    //  container at bottom which make it possible to scroll down
                    //  and see last workLog fully
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Util.spacerSelectable(bottom: MediaQuery.of(context).size.height * 0.4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FloatingActionButton(
                          // text which will be shown after long press on button
                          tooltip: 'Add exercise',
                          // open pop-up on button press to add new exercise
                          onPressed: () async => {
                            await showAddExerciseDialog(),
                            await updateState(),
                          },
                          child: Icon(Icons.add),
                          backgroundColor: AppThemeSettings.buttonColor,
                          foregroundColor: AppThemeSettings.secondaryColor,
                        ),
                        Util.spacerSelectable(
                          right: MediaQuery.of(context).size.width * 0.1,
                        ),
                      ],
                    ),
                    Util.spacerSelectable(bottom: MediaQuery.of(context).size.height * 0.01)
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// create workLog for every entry in given day
  ///
  /// require:
  /// workLog which will be added to widget
  /// context of application (for screen dimension)
  Widget createWorkLogRowWidget(WorkLog workLog) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02, top: MediaQuery.of(context).size.height * 0.02),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01, top: MediaQuery.of(context).size.height * 0.01),
            child: IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => deleteWorkLog(workLog),
            ),
          )
        ],
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01, top: MediaQuery.of(context).size.height * 0.01),
            child: IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => deleteWorkLog(workLog),
            ),
          ),
        ],
        child: Card(
          color: AppThemeSettings.primaryColor,
          elevation: 8,
          child: ListTile(
            title: Container(
              margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
              child: Text(
                workLog.exercise.name,
                style: TextStyle(fontSize: AppThemeSettings.fontSize, color: AppThemeSettings.buttonTextColor),
                textAlign: TextAlign.center,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ///  sum of workLog series
                Container(
                  margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    "Series: ${workLog.series.length.toString()}",
                    style: TextStyle(fontSize: AppThemeSettings.fontSize, color: AppThemeSettings.textColor),
                  ),
                ),

                ///  sum of workLog reps in set
                Container(
                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    "Reps: ${workLog.getRepsSum()}",
                    style: TextStyle(fontSize: AppThemeSettings.fontSize, color: AppThemeSettings.textColor),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            trailing: Container(
              child: Icon(
                Icons.arrow_forward,
                color: AppThemeSettings.secondaryColor,
              ),
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
            ),

            ///  push workLog and bodyPartInterface to new screen to display it's details
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(

                    ///  using Navigator.then to update parent state as well
                    builder: (context) => ExerciseView(workLog: workLog))).then((v) => updateState()),
          ),
        ),
      ),
    );
  }

  getExercises() async {
    List<MaterialButton> result = List();
    List<Exercise> exercises = await db.getAllExercise();

    for (Exercise e in exercises) {
      result.add(
        MaterialButton(
          onPressed: () async {
            Exercise exercise = Exercise(
              e.name,
              // bodyPart as Set()
              e.bodyParts,
            );
            //  save workLog to db
            WorkLog workLog = await addWorkLog(exercise);
            setState(() {
              wList.add(createWorkLogRowWidget(workLog));
            });
            Navigator.pop(context);
          },
          child: Text(e.name),
        ),
      );
    }
    setState(() {
      exerciseList = result;
    });
  }

  showAddExerciseDialog() async {
    await getExercises();
    updateState();
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(
          "Select exercise",
          textAlign: TextAlign.center,
        ),
        children: <Widget>[
          Util.addHorizontalLine(),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: exerciseList.length,
                      itemBuilder: (context, index) => exerciseList[index],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Icon(Icons.arrow_upward),
                      Util.spacerSelectable(top: MediaQuery.of(context).size.height * 0.3, bottom: 0, left: 0, right: 0),
                      Icon(Icons.arrow_downward),
                    ],
                  )
                ],
              ),
              Util.addHorizontalLine(),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                        color: AppThemeSettings.greenButtonColor,
                        child: Text("New"),
                        onPressed: () async => {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => AddExerciseView())),
                              Navigator.pop(context),
                            }),
                    MaterialButton(
                        color: AppThemeSettings.cancelButtonColor,
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<WorkLog> addWorkLog(Exercise exercise) async {
    //  get all workLogs from that day
    List<WorkLog> workLogList = await db.getDateAllWorkLogs();

    //  check if workLogs have same exercise name
    for (var w in workLogList) {
      if (w.exercise.name == exercise.name) {
        //  if there is workLog with that exercise name on this day,
        //  but with different bodypart
        //  update db with this new body part
        w.exercise.bodyParts.addAll(exercise.bodyParts);
        await db.updateExercise(w.exercise);
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

  Set<BodyPart> updateBP(BodyPart bodyPart, bool value, Set<BodyPart> bodyParts) {
    if (value)
      bodyParts.add(bodyPart);
    else
      bodyParts.remove(bodyPart);

    return bodyParts;
  }

  updateState() {
    setState(() {
      updateWorkLogFromDB();
    });
  }

  void updateWorkLogFromDB() async {
    List<WorkLog> workLogList;
    workLogList = await db.getDateAllWorkLogs();
    setState(() {
      if (workLogList != null && workLogList.isNotEmpty) {
        List<Widget> dbList = List();

        for (WorkLog workLog in workLogList) {
          dbList.add(createWorkLogRowWidget(workLog));
        }
        wList = dbList;
      }
      // this is needed to refresh state even if there is no entries
      // if not artifacts from different bodyPart will appear
      else {
        wList = List();
      }
      wList.add(Card(
        child: Container(),
      ));
    });
  }

  deleteWorkLog(WorkLog workLog) {
    db.deleteWorkLog(workLog);
    updateState();
  }

  restoreKey() {
    MyApp.globalKey = scaffoldKey;
  }
}
