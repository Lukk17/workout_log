import 'package:flutter/material.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

/// This is most detailed view for each WorkLog.
///
/// In Tab bar there is body part name and date.
/// Main view have name of exercise,
/// below it series and repeats in each series shown as table.
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
                  style: TextStyle(color: AppThemeSettings.titleColor),
                ),
              ),

              /// created time of this log
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  workLog.created.toIso8601String().substring(0, 10),
                  textAlign: TextAlign.end,
                  style: TextStyle(color: AppThemeSettings.titleColor),
                ),
              ),
            ],
          ),
          backgroundColor: AppThemeSettings.appBarColor),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppThemeSettings.workLogBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            /// exercise name
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: AppThemeSettings.borderColor,
                      width: AppThemeSettings.tableHeaderBorderWidth),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.20,
              width: MediaQuery.of(context).size.width,
              alignment: FractionalOffset(0.5, 0.5),
              child: Text(
                workLog.exercise.name,
                style: TextStyle(color: AppThemeSettings.specialTextColor),
              ),
            ),

            /// table header
            Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: AppThemeSettings.borderColor,
                          width: AppThemeSettings.tableHeaderBorderWidth),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.10,
                  width: MediaQuery.of(context).size.width * 0.5,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "series",
                    style: TextStyle(color: AppThemeSettings.specialTextColor),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: AppThemeSettings.borderColor,
                          width: AppThemeSettings.tableHeaderBorderWidth),
                      left: BorderSide(
                          color: AppThemeSettings.borderColor,
                          width: AppThemeSettings.tableHeaderBorderWidth),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.10,
                  width: MediaQuery.of(context).size.width * 0.5,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "repeats",
                    style: TextStyle(color: AppThemeSettings.specialTextColor),
                  ),
                ),
              ],
            ),

            /// list view builder create series
            Expanded(
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
      ),
      floatingActionButton: FloatingActionButton(
        // text which will be shown after long press on button
        tooltip: 'Add series',

        // open pop-up on button press to add new exercise
        onPressed: () => addSeriesToWorkLog(),
        child: Icon(Icons.add),
        backgroundColor: AppThemeSettings.primaryColor,
        foregroundColor: AppThemeSettings.secondaryColor,
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
                  bottom: BorderSide(
                      color: AppThemeSettings.borderColor,
                      width: AppThemeSettings.tableCellBorderWidth),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width * 0.5,
              alignment: FractionalOffset(0.5, 0.5),
              //TODO delete button
              child: FlatButton(

                  ///  series number start from 1 as iteration
                  child: Text(
                    i.toString(),
                    style: TextStyle(color: AppThemeSettings.specialTextColor),
                  ),
                  onPressed: () {
//                    Util.editSeriesDialog(bp, context, workLog);
                  }),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: AppThemeSettings.borderColor,
                      width: AppThemeSettings.tableCellBorderWidth),
                  left: BorderSide(
                      color: AppThemeSettings.borderColor,
                      width: AppThemeSettings.tableCellBorderWidth),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width * 0.5,
              alignment: FractionalOffset(0.5, 0.5),
              child: FlatButton(

                  ///  get repeats number
                  child: Text(
                    workLog.getReps(i.toString()),
                    style: TextStyle(color: AppThemeSettings.specialTextColor),
                  ),
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
            contentPadding:
                EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
                  Widget>[
                FlatButton(
                    color: AppThemeSettings.greenButtonColor,
                    child: Text(
                      'SAVE',
                      style: TextStyle(color: AppThemeSettings.buttonTextColor),
                    ),
                    onPressed: () {
                      ///  set repeat number of this set
                      // exception here if input is not int,
                      // preventing from saving that value
                      workLog.series[set] =
                          int.parse(textEditingController.text).toString();
                      db.updateWorkLog(workLog);
                      Navigator.pop(context);
                    }),
                FlatButton(
                    color: AppThemeSettings.cancelButtonColor,
                    child: Text(
                      'CANCEL',
                      style: TextStyle(color: AppThemeSettings.buttonTextColor),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ]),
            ],
          ),
    );
  }
}
