import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/editExerciseView.dart';

/// This is most detailed view for each WorkLog.
///
/// In Tab bar there is body part name and date.
/// Main view have name of exercise,
/// below it series and repeats in each series shown as table.
class ExerciseView extends StatefulWidget {
  final WorkLog workLog;

  ExerciseView({Key key, @required this.workLog}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExerciseView();

}

class _ExerciseView extends State<ExerciseView> {
  DBProvider _db = DBProvider.db;
  double _screenHeight;
  double _screenWidth;
  bool _isPortraitOrientation;

  double _columnWidth;
  double _seriesColumnWidth;
  double _headerLandscapeColumnHeight;
  double _portraitColumnHeight;
  double _landscapeColumnHeight;

  void setupDimensions(){
    _getScreenHeight();
    _getScreenWidth();

    _columnWidth = _screenWidth * 0.4;
    _seriesColumnWidth = _screenWidth * 0.2;
    _portraitColumnHeight = _screenHeight * 0.10;
    _headerLandscapeColumnHeight = _screenHeight * 0.15;
    _landscapeColumnHeight = _screenHeight * 0.17;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {

      /// check if new orientation is portrait
      /// rebuild from here where orientation will change
      _isPortraitOrientation = orientation == Orientation.portrait;

      setupDimensions();
      List<Widget> wList = _createRowsForSeries();

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              _isPortraitOrientation
                  ? _screenHeight * 0.08
                  : _screenHeight * 0.1

          ),
          child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  /// created time of this log
                  Container(
                    width: _screenWidth * 0.3,
                    child: Text(
                      widget.workLog.created.toIso8601String().substring(0, 10),
                      textAlign: TextAlign.end,
                      style: TextStyle(color: AppThemeSettings.titleColor),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppThemeSettings.appBarColor),),
        body: Column(
          children: <Widget>[

            /// exercise name
            GestureDetector(
              onLongPress: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditExerciseView(
                              exercise: widget.workLog.exercise,
                            )));
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableHeaderBorderWidth),
                  ),
                ),
                height: _screenHeight * 0.20,
                width: _screenWidth,
                alignment: FractionalOffset(0.5, 0.5),
                child: Text(
                  widget.workLog.exercise.name,
                  style: TextStyle(
                    color: AppThemeSettings.specialTextColor,
                    fontSize: AppThemeSettings.headerSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

                      left: BorderSide(
                          color: AppThemeSettings.borderColor,
                          width: AppThemeSettings.tableHeaderBorderWidth),

                      right: BorderSide(
                          color: AppThemeSettings.borderColor,
                          width: AppThemeSettings.tableHeaderBorderWidth),
                    ),
                  ),
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _headerLandscapeColumnHeight,

                  width: _seriesColumnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "series",
                    style: TextStyle(
                      color: AppThemeSettings.specialTextColor,
                      fontSize: AppThemeSettings.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
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

                      right: BorderSide(
                          color: AppThemeSettings.borderColor,
                          width: AppThemeSettings.tableHeaderBorderWidth),
                    ),
                  ),
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _headerLandscapeColumnHeight,

                  width: _columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "load",
                    style: TextStyle(
                      color: AppThemeSettings.specialTextColor,
                      fontSize: AppThemeSettings.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
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
                      right: BorderSide(
                          color: AppThemeSettings.borderColor,
                          width: AppThemeSettings.tableHeaderBorderWidth),
                    ),
                  ),
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _headerLandscapeColumnHeight,

                  width: _columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "repeats",
                    style: TextStyle(
                      color: AppThemeSettings.specialTextColor,
                      fontSize: AppThemeSettings.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
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
                //  if not shrieked it will be infinite in size and can't be render
                shrinkWrap: true,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          // text which will be shown after long press on button
          tooltip: 'Add series',

          // open pop-up on button press to add new exercise
          onPressed: () => _addSeriesToWorkLog(),
          child: Icon(Icons.add),
          backgroundColor: AppThemeSettings.primaryColor,
          foregroundColor: AppThemeSettings.secondaryColor,
        ),
      );
    });
  }

  List<Widget> _createRowsForSeries() {
    List<Widget> wList = List();
    for (int i = 1; i <= widget.workLog.series.length; i++) {
      wList.add(
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          secondaryActions: <Widget>[
            Container(
              margin: EdgeInsets.only(

                  bottom: _screenHeight * 0.01,
                  top: _screenHeight * 0.01,
                  left: _screenWidth * 0.01,
                  right: _screenWidth * 0.01),

              child: IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _deleteSeries(i),
              ),
            )
          ],
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(

                  bottom: _screenHeight * 0.01,
                  top: _screenHeight * 0.01,
                  left: _screenWidth * 0.01,
                  right: _screenWidth * 0.01),

              child: IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _deleteSeries(i),
              ),
            ),
          ],
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableCellBorderWidth),
                    left: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableCellBorderWidth),
                    top: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableCellBorderWidth),
                    right: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableCellBorderWidth),
                  ),
                ),
                height: _isPortraitOrientation
                    ? _portraitColumnHeight
                    : _landscapeColumnHeight,

                width: _seriesColumnWidth,
                alignment: FractionalOffset(0.5, 0.5),
                child: Center(

                  ///  series number start from 1 as iteration
                  child: Text(
                    i.toString(),
                    style: TextStyle(
                      color: AppThemeSettings.specialTextColor,
                      fontSize: AppThemeSettings.fontSize,
                    ),
                  ),
                ),
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
                    right: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableCellBorderWidth),
                    top: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableCellBorderWidth),
                  ),
                ),
                height: _isPortraitOrientation
                    ? _portraitColumnHeight
                    : _landscapeColumnHeight,

                width: _columnWidth,
                alignment: FractionalOffset(0.5, 0.5),
                child: MaterialButton(

                  ///  get load value
                    child: Text(
                      widget.workLog.getLoad(i.toString()),
                      style: TextStyle(
                        color: AppThemeSettings.specialTextColor,
                        fontSize: AppThemeSettings.fontSize,
                      ),
                    ),
                    onPressed: () {
                      _editLoadDialog(widget.workLog, i.toString()).then((v) =>
                      {
                        /// restore orientation ability to change
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeRight,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ])
                      });
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
                    right: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableCellBorderWidth),
                    top: BorderSide(
                        color: AppThemeSettings.borderColor,
                        width: AppThemeSettings.tableCellBorderWidth),
                  ),
                ),
                height: _isPortraitOrientation
                    ? _portraitColumnHeight
                    : _landscapeColumnHeight,

                width: _columnWidth,
                alignment: FractionalOffset(0.5, 0.5),
                child: MaterialButton(

                  ///  get repeats number
                    child: Text(
                      widget.workLog.getReps(i.toString()),
                      style: TextStyle(
                        color: AppThemeSettings.specialTextColor,
                        fontSize: AppThemeSettings.fontSize,
                      ),
                    ),
                    onPressed: () {
                      _editRepeatsDialog(widget.workLog, i.toString()).then((v) =>
                      {
                        /// restore orientation ability to change
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeRight,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ])
                      });
                    }),
              ),
            ],
          ),
        ),);
    }

    /// add additional container at bottom for better visibility
    wList.add(
      Container(
        height: _screenHeight * 0.10,
        width: _screenWidth * 0.5,
      ),
    );
    return wList;
  }

  _addSeriesToWorkLog() {
    setState(() {
      ///  add new series (with incremented number) to workLog with 0 repeats
      widget.workLog.series
          .putIfAbsent((widget.workLog.series.length + 1).toString(), () => "0");
      widget.workLog.load.putIfAbsent((widget.workLog.load.length + 1).toString(), () => "0");
      _db.updateWorkLog(widget.workLog);
    });
  }

  /// shows dialog for editing repeats number
  Future _editRepeatsDialog(WorkLog workLog, String set) {
    TextEditingController textEditingController = Util.textController();

    _blockOrientation();

    /// create required widgets due to different dialogs depending on screen orientation
    List<Widget> dialogWidgets = List();

    dialogWidgets.add(

      /// use text controller to save given by user String
      TextField(
        controller: textEditingController,
        autofocus: true,
        autocorrect: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: workLog.getReps(set)),
        maxLength: 4,
      ),
    );

    dialogWidgets.add(
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            MaterialButton(
                color: AppThemeSettings.greenButtonColor,
                child: Text(
                  'SAVE',
                  style: TextStyle(
                      color: AppThemeSettings.buttonTextColor),
                ),
                onPressed: () {
                  ///  set repeat number of this set
                  // exception here if input is not int,
                  // preventing from saving that value
                  workLog.series[set] =
                      int.parse(textEditingController.text).toString();
                  _db.updateWorkLog(workLog);
                  Navigator.pop(context);
                }),
            MaterialButton(
                color: AppThemeSettings.cancelButtonColor,
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                      color: AppThemeSettings.buttonTextColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]),
    );

    return _showDialog("Edit repeats number", dialogWidgets);
  }

  /// shows dialog for editing load value
  Future _editLoadDialog(WorkLog workLog, String set) {
    TextEditingController textEditingController = Util.textController();

    _blockOrientation();

    /// create required widgets due to different dialogs depending on screen orientation
    List<Widget> dialogWidgets = List();

    dialogWidgets.add(

      /// use text controller to save given by user String
      TextField(
        controller: textEditingController,
        autofocus: true,
        autocorrect: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: workLog.getLoad(set)),
        maxLength: 4,
      ),
    );

    dialogWidgets.add(
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            MaterialButton(
                color: AppThemeSettings.greenButtonColor,
                child: Text(
                  'SAVE',
                  style: TextStyle(
                      color: AppThemeSettings.buttonTextColor),
                ),
                onPressed: () {
                  ///  set load value of this set
                  // exception here if input is not int,
                  // preventing from saving that value
                  workLog.load[set] =
                      int.parse(textEditingController.text).toString();
                  _db.updateWorkLog(workLog);
                  Navigator.pop(context);
                }),
            MaterialButton(
                color: AppThemeSettings.cancelButtonColor,
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                      color: AppThemeSettings.buttonTextColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]),
    );

    return _showDialog("Edit load value", dialogWidgets);
  }

  _blockOrientation() {

    ///  block orientation change
    if (_isPortraitOrientation) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([

        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }

  _showDialog(String title, List<Widget> dialogWidgets) {
    return showDialog(
        context: context,
        builder: (_) =>
        _isPortraitOrientation
            ? SimpleDialog(
            title: Center(heightFactor: 0.3, child: Text(title)),
            contentPadding: EdgeInsets.all(_screenHeight * 0.02),
            children: dialogWidgets
        )
            : SimpleDialog(
            contentPadding: EdgeInsets.all(_screenHeight * 0.01),

            children: <Widget>[
              Center(heightFactor: 0.3, child: Text("Edit repeats number")),
              dialogWidgets.first,
              dialogWidgets.last,
            ]
        )
    );
  }


  _deleteSeries(int i) async {
    Map<dynamic, dynamic> updatedSeries = Map();
    Map<dynamic, dynamic> updatedLoad = Map();

    widget.workLog.series.forEach((key, value) =>
    {
      if(int.parse(key) == i){
        //  do not save it to new map - this way it will be deleted
      }

      /// decrement series number higher than deleted one
      else
        if (int.parse(key) > i)
          {
            key = (int.parse(key) - 1).toString(),
            updatedSeries.putIfAbsent(key, () => value.toString())
          }

        /// series number
        else
          {
            updatedSeries.putIfAbsent(key, () => value.toString())
          }
    });

    widget.workLog.load.forEach((key, value) =>
    {
      if(int.parse(key) == i){
        //  do not save it to new map - this way it will be deleted
      }

      /// decrement series number higher than deleted one
      else
        if (int.parse(key) > i)
          {
            key = (int.parse(key) - 1).toString(),
            updatedLoad.putIfAbsent(key, () => value.toString())
          }

        /// series number
        else
          {
            updatedLoad.putIfAbsent(key, () => value.toString())
          }
    });

    widget.workLog.series = updatedSeries;
    widget.workLog.load = updatedLoad;
    await _db.updateWorkLog(widget.workLog);
    setState(() {});
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }

  _getScreenWidth() {
    _screenWidth = Util.getScreenWidth(context);
  }
}
