import 'package:flutter/material.dart';
import 'package:workout_log/bodyPart/bodyPartInterface.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appTheme.dart';
import 'package:workout_log/util/util.dart';

class WorkLogView extends StatefulWidget {
  final WorkLog workLog;
  final BodyPartInterface bp;

  WorkLogView({Key key, @required this.workLog, @required this.bp})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WorkLogView(workLog: workLog, bp: bp);
  }
}

class _WorkLogView extends State<WorkLogView> {
  final WorkLog workLog;
  final BodyPartInterface bp;

  _WorkLogView({Key key, @required this.workLog, @required this.bp});

  @override
  Widget build(BuildContext context) {
    List<Widget> wList = createRowsForSeries(context);
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Text(
                  workLog.exercise.bodyPart.toString(),
                  textAlign: TextAlign.start,
                ),
              ),
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
          Container(
            //  weird height because of AppBar
            height: MediaQuery.of(context).size.height * 0.596,
            child: ListView.builder(
              itemCount: wList.length,
              itemBuilder: (BuildContext context, int index) {
                return wList[index];
              },
              //  nested listview need to shrink to size of its children
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
                //  series number start from 1 as iteration
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
                //  get repeats number from series map
                //  as for every series number there is associated repeat number
                  child: Text(workLog.series[i].toString()),
                  onPressed: () {
                    Util.editRepeatsDialog(bp, context, workLog, i);
                  }),
            ),
          ],
        ),
      );
    }
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
      Util.addSeries(bp, workLog);
    });
  }
}
