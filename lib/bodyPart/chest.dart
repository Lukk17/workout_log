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
  List<Widget> wList = List();
  static const BodyPart _BODYPART = BodyPart.CHEST;

  void restoreWorklogFromDB() async {
    //  get DB from singleton global provider
    DBProvider db = DBProvider.db;

    List<WorkLog> workLogList = await db.getAllWorkLogs();
    for (WorkLog workLog in workLogList) {
      wList.add(Util.addWorkLogRow(workLog, this, context, _BODYPART));
    }
  }

  @override
  Widget build(BuildContext context) {
    restoreWorklogFromDB();

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
            onPressed: () => Util.addRowDialog(
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

  void addWidgetToList(Widget widget) {
    setState(() {
      wList.add(widget);
      wList.add(Util.addHorizontalLine());
    });
  }

  saveWorkLogToDB(WorkLog workLog) {
    DBProvider db = DBProvider.db;
    db.newWorkLog(workLog);
  }

  void refreshList(WorkLog workLog, Widget widget) {
    setState(() {
      DBProvider db = DBProvider.db;
      print(workLog.id);
      print(wList.length);
      // and updated worklog need to be inserted in exactly same position in List - same as it's ID
      //TODO databese edit needed
//      wList.insert(worklog.id, widget);
      // to refresh view old worklog need to be removed - its ID is same as its position in List
//      wList.removeAt(worklog.id + 1);
    });
  }
}
