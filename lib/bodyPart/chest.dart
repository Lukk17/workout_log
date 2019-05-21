import 'package:flutter/material.dart';
import 'package:workout_log/bodyPart/bodyPartInterface.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

class Chest extends StatefulWidget {
  final DateTime date;
  final BodyPart bodyPart;

  Chest({Key key, @required this.date, @required this.bodyPart})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChestState();
  }
}

class _ChestState extends State<Chest> implements BodyPartInterface {

  BodyPart _bodyPart;
  DateTime _date;
  static List<Widget> wList = List();

  //  get DB from singleton global provider
  DBProvider db = DBProvider.db;

  @override
  void initState() {
    super.initState();

    // get date and bodyPart from forwarded variable
    this._bodyPart = widget.bodyPart;
    this._date = widget.date;

    updateWorkLogFromDB();
  }

  @override
  Widget build(BuildContext context) {
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
              //  container at bottom which make it possible to scroll down
              //  and see last workLog fully
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          // text which will be shown after long press on button
          tooltip: 'Add exercise',

          // open pop-up on button press to add new exercise
          onPressed: () => Util.showAddWorkLogDialog(
                this,
                'Exercise',
                'eg. pushup',
                context,
                _bodyPart,
              ),
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }

  @override
  void updateWorkLogFromDB() async {
    List<WorkLog> workLogList = await db.getWorkLogs(Util.formatter.format(_date), _bodyPart);
    if (workLogList != null && workLogList.isNotEmpty) {
      print(workLogList[0].created);
      List<Widget> dbList = List();
      for (WorkLog workLog in workLogList) {
        print("updating entries");
//        workLog.exercise;
        dbList.add(
            Util.createWorkLogRowWidget(workLog, this, context, _bodyPart));
        dbList.add(Util.addHorizontalLine());
      }
      setState(() {
        wList = dbList;
      });
    }
  }

  @override
  updateWorkLogToDB(WorkLog workLog) {
    print("UPDATE STATE OF CHEST");
    db.updateWorkLog(workLog);
    updateWorkLogFromDB();
  }

  @override
  updateState() {
    setState(() {
      updateWorkLogFromDB();
    });
  }

}
