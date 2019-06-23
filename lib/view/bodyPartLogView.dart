import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appTheme.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/storage.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/helloWorldView.dart';
import 'package:workout_log/view/workLogView.dart';

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

  //  get DB from singleton global provider
  DBProvider db = DBProvider.db;

  @override
  void initState() {
    super.initState();

    // get date and bodyPart from forwarded variable
    this._bodyPart = widget.bodyPart;
    updateWorkLogFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            image: AssetImage(AppThemeSettings.background),
            fit: BoxFit.cover,
          ),
        ),

        /// ListView of every workLog entry in given bodyParty
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
      floatingActionButton:

          /// if null or undefined do not show FAB
          (_bodyPart == BodyPart.UNDEFINED || _bodyPart == null)
              ? null
              : FloatingActionButton(
                  // text which will be shown after long press on button
                  tooltip: 'Add exercise',

                  // open pop-up on button press to add new exercise
                  onPressed: () =>
                      showAddWorkLogDialog('Exercise', 'eg. pushup', context),
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
      workLogList = await db.getWorkLogs(_bodyPart);
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
    return Card(
      color: AppThemeSettings.primaryColor,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02, top: MediaQuery.of(context).size.height * 0.02),
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
              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.height * 0.01),
              child: Text(
                "Series: ${workLog.series.length.toString()}",
                style: TextStyle(
                    fontSize: AppThemeSettings.fontSize,
                    color: AppThemeSettings.textColor),
              ),
            ),

            ///  sum of workLog reps in set
            Container(
              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.height * 0.01),
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
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
        ),

        ///  push workLog and bodyPartInterface to new screen to display it's details
        onTap: () => Navigator.push(
                context,
                MaterialPageRoute(

                    ///  using Navigator.then to update parent state as well
                    builder: (context) => WorkLogView(workLog: workLog)))
            .then((v) => updateState()),
      ),
    );
  }

  Future showAddWorkLogDialog(
    String title,
    String hint,
    BuildContext context,
  ) {
    TextEditingController textEditingController = Util.textController();
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text(title)),
            contentPadding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
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
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // text is forwarded by controller from SimpleDialog text field
                          Exercise exercise =
                              Exercise(textEditingController.text, _bodyPart);
                          addWorkLog(exercise, _bodyPart);
                          //  after saving new record bp state need to be updated:
                          updateWorkLogFromDB();
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

  addWorkLog(Exercise exercise, BodyPart bodyPart) {
    WorkLog workLog = WorkLog(exercise);
    workLog.exercise.bodyPart = bodyPart;
    workLog.created = HelloWorldView.date;
    String json = jsonEncode(workLog);
    print("add worklog: " + json);

    /// save to json
    Storage.writeToFile(json);

    ///  save workLog to DB
    db.newWorkLog(workLog);
  }

  updateState() {
    setState(() {
      updateWorkLogFromDB();
    });
  }
}
