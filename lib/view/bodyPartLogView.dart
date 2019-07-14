import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/storage.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/helloWorldView.dart';
import 'package:workout_log/view/workLogView.dart';

import '../main.dart';

/// This view show all exercises in selected body part.
///
/// Exercises are shown as cards.
/// Each card have exercise name,
/// series number and sum of repeats through all series
class BodyPartLogView extends StatefulWidget {
  final DateTime date;
  final BodyPart bodyPart;

  BodyPartLogView({Key key, @required this.date, @required this.bodyPart})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BodyPartLogViewState();
  }
}

class _BodyPartLogViewState extends State<BodyPartLogView> {
  BodyPart _bodyPart;
  static List<Widget> wList = List();
  List<MaterialButton> exerciseList = List();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> savedKey = MyApp.globalKey;

  //  get DB from singleton global provider
  DBProvider db = DBProvider.db;

  @override
  void initState() {
    super.initState();

    MyApp.globalKey = scaffoldKey;
    // get date and bodyPart from forwarded variable
    this._bodyPart = widget.bodyPart;
    updateWorkLogFromDB();
  }

  @override
  void dispose() {
    super.dispose();
    MyApp.globalKey = savedKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(

          /// title of selected body part
          /// if null or undefined showing all exercises
          title: (_bodyPart == BodyPart.UNDEFINED || _bodyPart == null)
              ? Text(
                  "all",
                  style: TextStyle(color: AppThemeSettings.titleColor),
                )
              : Text(
                  _bodyPart
                      .toString()
                      .substring(_bodyPart.toString().indexOf('.') + 1)
                      .toLowerCase(),
                  style: TextStyle(color: AppThemeSettings.titleColor),
                ),
          backgroundColor: AppThemeSettings.appBarColor),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppThemeSettings.bodyPartBackground),
            fit: BoxFit.fitHeight,
          ),
        ),

        /// ListView of every workLog entry in given bodyParty
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 3.0),
          child: ListView(
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
        ),
      ),
      floatingActionButton:

          /// if null or undefined do not show FAB
          (_bodyPart == BodyPart.UNDEFINED || _bodyPart == null)
              ? null
              : FloatingActionButton(
                  // text which will be shown after long press on button
                  tooltip: 'Add exercise',

                  // open pop-up on button press to add new exercise
                  onPressed: () => {
                    showAddExerciseDialog(),
                  },
                  child: Icon(Icons.add),
                  backgroundColor: AppThemeSettings.primaryColor,
                  foregroundColor: AppThemeSettings.secondaryColor,
                ),
    );
  }

  void updateWorkLogFromDB() async {
    List<WorkLog> workLogList;

    if (_bodyPart == BodyPart.UNDEFINED || _bodyPart == null) {
      workLogList = await db.getDateAllWorkLogs();
    } else {
      workLogList = await db.getDateBodypartWorkLogs(_bodyPart);
    }
    setState(() {
      if (workLogList != null && workLogList.isNotEmpty) {
        List<Widget> dbList = List();

        for (WorkLog workLog in workLogList) {
          dbList.add(createWorkLogRowWidget(workLog, context));
        }
        wList = dbList;
      }
      // this is needed to refresh state even if there is no entries
      // if not artifacts from different bodyPart will appear
      else {
        wList = List();
      }
    });
  }

  /// create workLog entry in given bodyPart page
  ///
  /// require:
  /// workLog which will be added to widget
  /// context of application (for screen dimension)
  Widget createWorkLogRowWidget(
    WorkLog workLog,
    BuildContext context,
  ) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) => {
        if (d.delta.dx < -10)
          {
            deleteWorkLog(workLog),
          }
      },
      child: Card(
        color: AppThemeSettings.primaryColor,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.02,
            top: MediaQuery.of(context).size.height * 0.02),
        elevation: 8,
        child: ListTile(
          title: Container(
            margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
            child: Text(
              workLog.exercise.name,
              style: TextStyle(
                  fontSize: AppThemeSettings.fontSize,
                  color: AppThemeSettings.buttonTextColor),
              textAlign: TextAlign.center,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ///  sum of workLog series
              Container(
                margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.02,
                    bottom: MediaQuery.of(context).size.height * 0.01),
                child: Text(
                  "Series: ${workLog.series.length.toString()}",
                  style: TextStyle(
                      fontSize: AppThemeSettings.fontSize,
                      color: AppThemeSettings.textColor),
                ),
              ),

              ///  sum of workLog reps in set
              Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02,
                    bottom: MediaQuery.of(context).size.height * 0.01),
                child: Text(
                  "Reps: ${workLog.getRepsSum()}",
                  style: TextStyle(
                      fontSize: AppThemeSettings.fontSize,
                      color: AppThemeSettings.textColor),
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
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
          ),

          ///  push workLog and bodyPartInterface to new screen to display it's details
          onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(

                      ///  using Navigator.then to update parent state as well
                      builder: (context) => WorkLogView(workLog: workLog)))
              .then((v) => updateState()),
        ),
      ),
    );
  }

  Future showAddExerciseDialog() {
    getExercises();
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
                      Util.spacerSelectable(
                          top: MediaQuery.of(context).size.height * 0.3,
                          bottom: 0,
                          left: 0,
                          right: 0),
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
                        onPressed: () => {
                              showNewExerciseDialog('Exercise', 'eg. pushup')
                                  .then((_) => {Navigator.pop(context)}),
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

  void getExercises() async {
    List<MaterialButton> result = List();
    List<Exercise> exercises = await db.getAllExercise();

    for (Exercise e in exercises) {
      result.add(
        MaterialButton(
          onPressed: () async {
            Exercise exercise = Exercise(
              e.name,
              // bodyPart as Set()
              {_bodyPart},
            );
            //  save workLog to db
            WorkLog workLog = await addWorkLog(exercise, _bodyPart);
            setState(() {
              wList.add(createWorkLogRowWidget(workLog, context));
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

  Future showNewExerciseDialog(
    String title,
    String hint,
  ) {
    TextEditingController textEditingController = Util.textController();
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Center(child: Text(title)),
        contentPadding:
            EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
        children: <Widget>[
          TextField(
            // use text controller to save given by user String
            controller: textEditingController,
            autofocus: true,
            autocorrect: true,
            decoration: InputDecoration(hintText: hint),
            maxLength: 50,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                    color: AppThemeSettings.greenButtonColor,
                    child: const Text('SAVE'),
                    onPressed: () async {
                      // text is forwarded by controller from SimpleDialog text field
                      Exercise exercise = Exercise(
                        textEditingController.text,
                        // bodyPart as Set()
                        {_bodyPart},
                      );
                      WorkLog workLog = await addWorkLog(exercise, _bodyPart);
                      //  after saving new record bp state need to be updated:
                      setState(() {
                        wList.add(createWorkLogRowWidget(workLog, context));
                      });
                      Navigator.pop(context);
                    }),
                MaterialButton(
                    color: AppThemeSettings.cancelButtonColor,
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ]),
        ],
      ),
    );
  }

  Future<WorkLog> addWorkLog(Exercise exercise, BodyPart bodyPart) async {
    //  get all workLogs from that day
    List<WorkLog> workLogList = await db.getDateAllWorkLogs();

    //  check if workLogs have same exercise name
    for (var w in workLogList) {
      if (w.exercise.name == exercise.name) {
        //  if there is workLog with that exercise name on this day,
        //  but with different bodypart
        //  update db with this new body part
        w.exercise.bodyParts.addAll(exercise.bodyParts);
        db.updateExercise(w.exercise);
        print(
            "\n [addworklog] UPDATE EXERCISE BP  : ============>  ${w.exercise.toString()}\n ");
        return w;
      }
    }
    WorkLog workLog = WorkLog(exercise);
    workLog.exercise.bodyParts = {bodyPart}; // bodyPart as Set()
    workLog.created = HelloWorldView.date;
    String json = jsonEncode(workLog);

    print(
        "\n [addworklog] ADDING NEW WORKLOG  : ============>  ${workLog.toString()}\n ");

    /// save to json
    Storage.writeToFile(json);

    ///  save workLog to DB
    db.newWorkLog(workLog);

    return workLog;
  }

  updateState() {
    setState(() {
      updateWorkLogFromDB();
    });
  }

  deleteWorkLog(WorkLog workLog) {
    db.deleteWorkLog(workLog);
    updateState();
  }
}
