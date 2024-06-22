import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/exerciseView.dart';
import 'package:workout_log/view/helloWorldView.dart';

import 'exerciseManipulationView.dart';

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
  List<Widget> _wList = <Widget>[];
  List<MaterialButton> _exerciseList = <MaterialButton>[];
  bool _isPortraitOrientation = false;
  double _screenHeight = 0;
  double _screenWidth = 0;

  final Logger _log = new Logger("WorkLogPageView");

  double _datePortraitHeight = 0;
  double _dateLandscapeHeight = 0;
  double _dateTextScale = 0;
  double _cardMargin = 0;
  double _cardOutsideMargin = 0;
  EdgeInsets _seriesMargin = EdgeInsets.zero;
  EdgeInsets _repsMargin = EdgeInsets.zero;
  double _exerciseDialogHeight = 0;
  double _exerciseDialogWidth = 0;
  double _bottomEmptyContainerHeight = 0;

  //  get DB from singleton global provider
  final DBProvider _db = DBProvider.db;

  @override
  void initState() {
    super.initState();
    _updateWorkLogFromDB();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setupDimensions() {
    _getScreenHeight();
    _getScreenWidth();

    _datePortraitHeight = _screenHeight * 0.1;
    _dateLandscapeHeight = _screenHeight * 0.2;
    _dateTextScale = 3;
    _cardMargin = _screenHeight * 0.01;
    _cardOutsideMargin = _screenHeight * 0.01;
    _seriesMargin = EdgeInsets.only(
        right: _screenWidth * 0.02, bottom: _screenHeight * 0.01);
    _repsMargin = EdgeInsets.only(
        left: _screenWidth * 0.02, bottom: _screenHeight * 0.01);
    _exerciseDialogHeight = _screenHeight * 0.5;
    _exerciseDialogWidth = _screenWidth * 0.7;
    _bottomEmptyContainerHeight = _screenHeight * 0.15;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      /// check if new orientation is portrait
      /// rebuild from here where orientation will change
      _isPortraitOrientation = orientation == Orientation.portrait;

      setupDimensions();

      /// need to be called to fetch workLogs for selected date in calendar
      if (Util.rebuild) {
        _updateWorkLogFromDB();
        Util.rebuild = false;
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: _isPortraitOrientation
                ? _datePortraitHeight
                : _dateLandscapeHeight,
            alignment: Alignment(0, 0),
            child: Text(
              Util.formatter.format(HelloWorldView.date) ==
                      Util.formatter.format(DateTime.now())
                  ? "Today"
                  : Util.formatter.format(HelloWorldView.date),
              textScaleFactor: _dateTextScale,
              style: TextStyle(
                  color: AppThemeSettings.textColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Column(
                      children: _wList,
                    ),
                    //  container at bottom which make it possible to scroll down
                    //  and see last workLog fully
                    Container(
                      height: _bottomEmptyContainerHeight,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Util.spacerSelectable(
                        bottom: _screenHeight * 0.3, top: 0, left: 0, right: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FloatingActionButton(
                          // text which will be shown after long press on button
                          tooltip: 'Add exercise',
                          // open pop-up on button press to add new exercise
                          onPressed: () async => {
                            await _showAddExerciseDialog(),
                            await _updateState(),
                            Util.unlockOrientation(),
                          },
                          child: Icon(Icons.add,
                              color: AppThemeSettings.buttonTextColor),
                          backgroundColor: AppThemeSettings.buttonColor,
                          foregroundColor: AppThemeSettings.secondaryColor,
                        ),
                        Util.spacerSelectable(
                            right: _screenWidth * 0.1,
                            bottom: 0,
                            left: 0,
                            top: 0),
                      ],
                    ),
                    Util.spacerSelectable(
                        bottom: _screenHeight * 0.01, top: 0, left: 0, right: 0)
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
  Widget _createWorkLogRowWidget(WorkLog workLog) {
    return Container(
      margin: EdgeInsets.only(bottom: _cardOutsideMargin),
      child: Slidable(
        key: ValueKey(workLog.id), // Ensure each slidable has a unique key
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            Container(
              margin: EdgeInsets.only(
                  bottom: _screenHeight * 0.01, top: _screenHeight * 0.01),
              child: SlidableAction(
                onPressed: (context) => _deleteWorkLog(workLog),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            Container(
              margin: EdgeInsets.only(
                  bottom: _screenHeight * 0.01, top: _screenHeight * 0.01),
              child: SlidableAction(
                onPressed: (context) => _deleteWorkLog(workLog),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ),
          ],
        ),
        child: Card(
          color: AppThemeSettings.primaryColor,
          elevation: 8,
          child: ListTile(
            title: Container(
              margin: EdgeInsets.all(_cardMargin),
              child: Text(
                workLog.exercise.name,
                style: TextStyle(
                    fontSize: AppThemeSettings.fontSize,
                    color: AppThemeSettings.cardTextColor),
                textAlign: TextAlign.center,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ///  sum of workLog series
                Container(
                  margin: _seriesMargin,
                  child: Text(
                    "Series: ${workLog.series.length.toString()}",
                    style: TextStyle(
                        fontSize: AppThemeSettings.fontSize,
                        color: AppThemeSettings.cardTextColor),
                  ),
                ),

                ///  sum of workLog reps in set
                Container(
                  margin: _repsMargin,
                  child: Text(
                    "Reps: ${workLog.getRepsSum()}",
                    style: TextStyle(
                        fontSize: AppThemeSettings.fontSize,
                        color: AppThemeSettings.cardTextColor),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            leading: Column(
              children: _getMainBodyParts(workLog),
            ),
            trailing: Container(
              child: Icon(
                Icons.arrow_forward,
                color: AppThemeSettings.secondaryColor,
              ),
              margin: EdgeInsets.only(top: _screenHeight * 0.02),
            ),

            ///  push workLog and bodyPartInterface to new screen to display it's details
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(

                  ///  using Navigator.then to update parent state as well
                    builder: (context) => ExerciseView(workLog: workLog)))
                .then((v) => _updateState()),
          ),
        ),
      ),
    );
  }

  _getExercises() async {
    List<MaterialButton> result = <MaterialButton>[];
    List<Exercise> exercises = await _db.getAllExercise();

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
            WorkLog workLog = await _addWorkLog(exercise);
            setState(() {
              _wList.add(_createWorkLogRowWidget(workLog));
            });
            Navigator.pop(context);
          },
          child: Text(
            e.name,
            style: TextStyle(color: AppThemeSettings.specialTextColor),
          ),
        ),
      );
    }
    setState(() {
      _exerciseList = result;
    });
  }

  _showAddExerciseDialog() async {
    await _getExercises();
    _updateState();

    Util.blockOrientation(_isPortraitOrientation);

    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(
          "Select exercise",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppThemeSettings.textColor),
        ),
        children: <Widget>[
          Util.addHorizontalLine(screenWidth: null),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: _exerciseDialogHeight,
                    width: _exerciseDialogWidth,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _exerciseList.length,
                      itemBuilder: (context, index) => _exerciseList[index],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Icon(Icons.arrow_upward),
                      Util.spacerSelectable(
                          top: _screenHeight * 0.3,
                          bottom: 0,
                          left: 0,
                          right: 0),
                      Icon(Icons.arrow_downward),
                    ],
                  )
                ],
              ),
              Util.addHorizontalLine(screenWidth: null),
              Container(
                height: _screenHeight * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                        color: AppThemeSettings.greenButtonColor,
                        child: Text(
                          "New",
                          style: TextStyle(
                              color: AppThemeSettings.buttonTextColor),
                        ),
                        onPressed: () async => {
                              Util.unlockOrientation(),
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ExerciseManipulationView(exercise: null,))),
                              Navigator.pop(context),
                            }),
                    MaterialButton(
                        color: AppThemeSettings.cancelButtonColor,
                        child: Text('CANCEL',
                            style: TextStyle(
                                color: AppThemeSettings.buttonTextColor)),
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

  Future<WorkLog> _addWorkLog(Exercise exercise) async {
    //  get all workLogs from that day
    List<WorkLog> workLogList = await _db.getDateAllWorkLogs();

    ///  check if workLogs have same exercise name
    for (var w in workLogList) {
      if (w.exercise.name == exercise.name) {
        ///  if there is workLog with that exercise name on this day, but with different bodyPart
        ///  update db with this new body part
        w.exercise.bodyParts.addAll(exercise.bodyParts);
        await _db.updateExercise(w.exercise);

        _log.fine("Updated exercise bodyParts: ${w.exercise.toString()}");

        return w;
      }
    }
    WorkLog workLog = WorkLog(exercise);
    workLog.exercise.bodyParts = exercise.bodyParts; // bodyPart as Set()
    workLog.created = HelloWorldView.date;

    //    String json = jsonEncode(workLog);
    //    /// save to json
    //    Storage.writeToFile(json);

    ///  save workLog to DB
    await _db.newWorkLog(workLog);

    _log.fine("Added new workLog: ${workLog.toString()}");

    return workLog;
  }

  List<Widget> _getMainBodyParts(WorkLog workLog) {
    List<Text> result = <Text>[];

    /// add only first 3 when more than 3 body parts in exercise
    if (workLog.exercise.bodyParts.length > 3) {
      int counter = 0;
      workLog.exercise.bodyParts.forEach((bp) {
        if (counter < 3) {
          counter++;
          result.add(Text(Util.getBpName(bp),
              style: TextStyle(color: Util.getBpColor(bp))));
        }
        ;
      });

      /// add all body parts when less than 3 in exercise
    } else if (workLog.exercise.bodyParts.length == 3) {
      workLog.exercise.bodyParts.forEach((bp) {
        result.add(Text(Util.getBpName(bp),
            style: TextStyle(color: Util.getBpColor(bp))));
      });
    } else {
      int counter = 0;
      workLog.exercise.bodyParts.forEach((bp) {
        counter++;
        result.add(Text(Util.getBpName(bp),
            style: TextStyle(color: Util.getBpColor(bp))));
      });

      workLog.exercise.secondaryBodyParts.forEach((bp) {
        if (counter < 3) {
          counter++;
          result.add(Text(Util.getBpName(bp),
              style: TextStyle(color: Util.getBpColor(bp))));
        }
        ;
      });
    }

    return result;
  }

  _updateState() {
    setState(() {
      _updateWorkLogFromDB();
    });
  }

  void _updateWorkLogFromDB() async {
    List<WorkLog> workLogList;
    workLogList = await _db.getDateAllWorkLogs();
    setState(() {
      if (workLogList != null && workLogList.isNotEmpty) {
        List<Widget> dbList = <Widget>[];

        for (WorkLog workLog in workLogList) {
          _log.fine("Loaded from DB: ${workLog.exercise.toString()}");

          dbList.add(_createWorkLogRowWidget(workLog));
        }
        _wList = dbList;
      }
      // this is needed to refresh state even if there is no entries
      // if not artifacts from different bodyPart will appear
      else {
        _wList = [];
      }
      _wList.add(Card(
        child: Container(),
      ));
    });
  }

  _deleteWorkLog(WorkLog workLog) {
    _log.fine("Deleted workLog: : ${workLog.toString()}");

    _db.deleteWorkLog(workLog);
    _updateState();
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }

  _getScreenWidth() {
    _screenWidth = Util.getScreenWidth(context);
  }
}
