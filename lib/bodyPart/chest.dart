import 'package:flutter/material.dart';
import 'package:workout_log/bodyPart/bodyPartInterface.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

class Chest extends StatefulWidget {
  Chest({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChestState();
  }
}

class _ChestState extends State<Chest> implements BodyPartInterface {
  static const BodyPart _BODYPART = BodyPart.CHEST;
  static List<Widget> wList = List();

  @override
  void initState() {
    updateWorklogFromDB();
  }

  @override
  Widget build(BuildContext context) {
    print("build");

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chest'),
          backgroundColor: Colors.red,
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Column(
                children: wList,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
            ],
          ),
        ),
        floatingActionButton: Hero(
          tag: "button",
          child: FloatingActionButton(
            // text which will be shown after long press on button
            tooltip: 'Add exercise',

            // open pop-up on button press to add new exercise
            onPressed: () => Util.showAddWorkLogDialog(
                  this,
                  'Exercise',
                  'eg. pushup',
                  context,
                  _BODYPART,
                ),
            child: Icon(Icons.add),
            backgroundColor: Colors.red,
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }

  void updateWorklogFromDB() async {
    //  get DB from singleton global provider
    DBProvider db = DBProvider.db;

    List<WorkLog> workLogList = await db.getAllWorkLogs();
    if (workLogList != null && workLogList.isNotEmpty) {
      print(workLogList);
      List<Widget> dbList = List();
      for (WorkLog workLog in workLogList) {
        print("updating entries");
//        workLog.exercise;
        dbList.add(
            Util.createWorkLogRowWidget(workLog, this, context, _BODYPART));
        dbList.add(Util.addHorizontalLine());
      }
      setState(() {
        wList = dbList;
      });
    }
  }

  saveWorkLogToDB(WorkLog workLog) {
    DBProvider db = DBProvider.db;
    print(
        "SAVING TO DB          " + workLog.exercise.name + workLog.exercise.id);
    db.newWorkLog(workLog);
    updateWorklogFromDB();
  }
}
