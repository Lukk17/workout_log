import 'package:flutter/material.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appTheme.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

class WorkLogView extends StatefulWidget {
  final WorkLog workLog;

  WorkLogView({Key key, @required this.workLog}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WorkLogView(workLog: workLog);
  }
}

class _WorkLogView extends State<WorkLogView> {
  final WorkLog workLog;
  static DBProvider db = DBProvider.db;

  _WorkLogView({Key key, @required this.workLog});

  @override
  Widget build(BuildContext context) {
    List<Widget> wList = createRowsForSeries(context);
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: <Widget>[
              /// title of body part of exercise
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Text(
                  workLog.getBodyPart(),
                  textAlign: TextAlign.start,
                ),
              ),

              /// created time of this log
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  workLog.created.toIso8601String().substring(0, 10),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red),
      body: Column(
        children: <Widget>[
          /// exercise name
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width,
            alignment: FractionalOffset(0.5, 0.5),
            child: Text(workLog.exercise.name),
          ),

          /// table header
          Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: FractionalOffset(0.5, 0.5),
                child: Text("series"),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor),
                    left: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: FractionalOffset(0.5, 0.5),
                child: Text("repeats"),
              ),
            ],
          ),

          /// list view builder create series
          Container(
            //  weird height because of AppBar
            height: MediaQuery.of(context).size.height * 0.596,
            child: ListView.builder(
              itemCount: wList.length,
              itemBuilder: (BuildContext context, int index) {
                return wList[index];
              },
              //  nested listView need to shrink to size of its children
              //  if not shrinked it will be infinite in size and can't be render
              shrinkWrap: true,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // text which will be shown after long press on button
        tooltip: 'Add exercise',

        // open pop-up on button press to add new exercise
        onPressed: () => addSeriesToWorkLog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        foregroundColor: Colors.black,
      ),
    );
  }

  List<Widget> createRowsForSeries(BuildContext context) {
    List<Widget> wList = List();
    for (int i = 1; i <= workLog.series.length; i++) {
      wList.add(
        Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderColor),
                  left: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width * 0.5,
              alignment: FractionalOffset(0.5, 0.5),
              //TODO delete button
              child: FlatButton(

                  ///  series number start from 1 as iteration
                  child: Text(i.toString()),
                  onPressed: () {
//                    Util.editSeriesDialog(bp, context, workLog);
                  }),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderColor),
                  left: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width * 0.5,
              alignment: FractionalOffset(0.5, 0.5),
              child: FlatButton(

                  ///  get repeats number
                  child: Text(workLog.getReps(i.toString())),
                  onPressed: () {
                    editRepeatsDialog(context, workLog, i.toString());
                  }),
            ),
          ],
        ),
      );
    }

    /// add additional container at bottom for better visibility
    wList.add(
      Container(
        height: MediaQuery.of(context).size.height * 0.10,
        width: MediaQuery.of(context).size.width * 0.5,
      ),
    );
    return wList;
  }

  addSeriesToWorkLog() {
    setState(() {
      ///  add new series (with incremented number) to workLog with 0 repeats
      workLog.series
          .putIfAbsent((workLog.series.length + 1).toString(), () => "0");
      db.updateWorkLog(workLog);
    });
  }

  Future editRepeatsDialog(BuildContext context, WorkLog workLog, String set) {
    TextEditingController textEditingController = Util.textController();
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text("Edit repeats number")),
            contentPadding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(
                /// use text controller to save given by user String
                controller: textEditingController,
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: workLog.getReps(set)),
                maxLength: 4,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          ///  set repeat number of this set
                          // TODO exception here if input not int
                          workLog.series[set] =
                              textEditingController.text as int;
                          db.updateWorkLog(workLog);
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
}
