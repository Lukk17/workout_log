import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

import 'exerciseManipulationView.dart';

/// This is most detailed view for each WorkLog.
///
/// In Tab bar there is body part name and date.
/// Main view have name of exercise,
/// below it series and repeats in each series shown as table.
class ExerciseView extends StatefulWidget {
  final WorkLog workLog;

  ExerciseView({required this.workLog});

  @override
  State<StatefulWidget> createState() => _ExerciseView();

}

class _ExerciseView extends State<ExerciseView> {
  final DBProvider _db = DBProvider.db;
  final Logger _log = new Logger("ExerciseView");

  late double _screenHeight;
  late double _screenWidth;
  late bool _isPortraitOrientation;

  late double _appBarHeightPortrait;
  late double _appBarHeightLandscape;
  late double _exerciseHeightPortrait;
  late double _exerciseHeightLandscape;
  late double _exerciseWidth;
  late double _columnWidth;
  late double _seriesColumnWidth;
  late double _headerLandscapeColumnHeight;
  late double _portraitColumnHeight;
  late double _landscapeColumnHeight;
  late double _titleFontSizePortrait;
  late double _titleFontSizeLandscape;

  void setupDimensions() {
    _getScreenHeight();
    _getScreenWidth();

    _appBarHeightPortrait = _screenHeight * 0.08;
    _appBarHeightLandscape = _screenHeight * 0.1;
    _exerciseHeightPortrait = _screenHeight * 0.1;
    _exerciseHeightLandscape = _screenHeight * 0.15;
    _exerciseWidth = _screenWidth;
    _columnWidth = _screenWidth * 0.375;
    _seriesColumnWidth = _screenWidth * 0.25;
    _portraitColumnHeight = _screenHeight * 0.1;
    _headerLandscapeColumnHeight = _screenHeight * 0.15;
    _landscapeColumnHeight = _screenHeight * 0.17;
    _titleFontSizePortrait = _screenWidth * 0.055;
    _titleFontSizeLandscape = _screenWidth * 0.03;
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
                  ? _appBarHeightPortrait
                  : _appBarHeightLandscape

          ),
          child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  /// created date of this log
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
                            ExerciseManipulationView(
                              exercise: widget.workLog.exercise,
                            )));
              },
              child: Container(
                height: _isPortraitOrientation
                    ? _exerciseHeightPortrait
                    : _exerciseHeightLandscape,
                width: _exerciseWidth,
                alignment: FractionalOffset(0.5, 0.5),
                child: Text(
                  widget.workLog.exercise.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeSettings.textColor,
                    fontSize: AppThemeSettings.headerSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _getAllBodyParts(widget.workLog),
            ),

            /// table header
            Row(
              children: <Widget>[
                Container(
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _headerLandscapeColumnHeight,

                  width: _seriesColumnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "series",
                    style: TextStyle(
                      color: AppThemeSettings.textColor,
                      fontSize: AppThemeSettings.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _headerLandscapeColumnHeight,

                  width: _columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "load",
                    style: TextStyle(
                      color: AppThemeSettings.textColor,
                      fontSize: AppThemeSettings.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _headerLandscapeColumnHeight,

                  width: _columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "repeats",
                    style: TextStyle(
                      color: AppThemeSettings.textColor,
                      fontSize: AppThemeSettings.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Util.addHorizontalLine(screenWidth: _screenWidth),

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
          child: Icon(Icons.add, color: AppThemeSettings.buttonTextColor),
          backgroundColor: AppThemeSettings.buttonColor,
          foregroundColor: AppThemeSettings.secondaryColor,
        ),
      );
    });
  }

  /// Creates row for every recorder set, with divider at the bottom
  /// Slidable widget show action when user slide every row
  List<Widget> _createRowsForSeries() {
    List<Widget> wList = <Widget>[];
    List keys = widget.workLog.series.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      wList.add(
          Slidable(
            key: ValueKey(keys[i]), // Ensure unique key
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: _screenHeight * 0.01,
                      top: _screenHeight * 0.01,
                      left: _screenWidth * 0.01,
                      right: _screenWidth * 0.01),
                  child: SlidableAction(
                    onPressed: (context) => _deleteSeries(i),
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
                      bottom: _screenHeight * 0.01,
                      top: _screenHeight * 0.01,
                      left: _screenWidth * 0.01,
                      right: _screenWidth * 0.01),
                  child: SlidableAction(
                    onPressed: (context) => _editLoadDialog(widget.workLog, keys[i]).then((v) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                    }),
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    icon: Icons.edit,
                    label: 'Edit load',
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: _screenHeight * 0.01,
                      top: _screenHeight * 0.01,
                      left: _screenWidth * 0.01,
                      right: _screenWidth * 0.01),
                  child: SlidableAction(
                    onPressed: (context) => _editRepeatsDialog(widget.workLog, i.toString()).then((v) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                    }),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit repeats',
                  ),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _landscapeColumnHeight,
                  width: _seriesColumnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Center(
                    child: Text(
                      i.toString(),
                      style: TextStyle(
                        color: AppThemeSettings.textColor,
                        fontSize: AppThemeSettings.fontSize,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _landscapeColumnHeight,
                  width: _columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: MaterialButton(
                    child: Text(
                      widget.workLog.getLoad(keys[i]),
                      style: TextStyle(
                        color: AppThemeSettings.textColor,
                        fontSize: AppThemeSettings.fontSize,
                      ),
                    ),
                    onPressed: () {
                      _editLoadDialog(widget.workLog, keys[i]).then((v) {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeRight,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                      });
                    },
                  ),
                ),
                Container(
                  height: _isPortraitOrientation
                      ? _portraitColumnHeight
                      : _landscapeColumnHeight,
                  width: _columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: MaterialButton(
                    child: Text(
                      widget.workLog.getReps(keys[i]),
                      style: TextStyle(
                        color: AppThemeSettings.textColor,
                        fontSize: AppThemeSettings.fontSize,
                      ),
                    ),
                    onPressed: () {
                      _editRepeatsDialog(widget.workLog, keys[i]).then((v) {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeRight,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),);
      wList.add(
        Util.addHorizontalLine(screenWidth: _screenWidth),
      );
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

  _addSeriesToWorkLog() async {
    ///  add new series (with incremented number) to workLog with 0 repeats
    widget.workLog.series
        .putIfAbsent((widget.workLog.series.length + 1).toString(), () => "0");
    widget.workLog.load.putIfAbsent(
        (widget.workLog.load.length + 1).toString(), () => "0");
    await _db.updateWorkLog(widget.workLog);

    setState(() {});

    _log.fine("Series added to: ${widget.workLog.toString()}");
  }

  /// shows dialog for editing repeats number
  Future _editRepeatsDialog(WorkLog workLog, String set) {
    TextEditingController textEditingController = Util.textController();

    Util.blockOrientation(_isPortraitOrientation);

    /// create required widgets due to different dialogs depending on screen orientation
    List<Widget> dialogWidgets = <Widget>[];

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
                onPressed: () async {
                  ///  set repeat number of this set
                  // exception here if input is not int,
                  // preventing from saving that value
                  workLog.series[set] =
                      int.parse(textEditingController.text).toString();
                  await _db.updateWorkLog(workLog);

                  _log.fine(
                      "Repeats change to ${workLog.series[set]} for ${workLog
                          .toString()}");

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

    Util.blockOrientation(_isPortraitOrientation);

    /// create required widgets due to different dialogs depending on screen orientation
    List<Widget> dialogWidgets = <Widget>[];

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
                onPressed: () async {
                  ///  set load value of this set
                  // exception here if input is not int,
                  // preventing from saving that value
                  workLog.load[set] =
                      int.parse(textEditingController.text).toString();
                  await _db.updateWorkLog(workLog);

                  _log.fine("Load change to ${workLog.load} for ${workLog
                      .toString()}");
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
              Center(heightFactor: 0.3, child: Text(title)),
              dialogWidgets.first,
              dialogWidgets.last,
            ]
        )
    );
  }


  void _deleteSeries(int i) async {
    Map<dynamic, dynamic> updatedSeries = Map();
    Map<dynamic, dynamic> updatedLoad = Map();

    widget.workLog.series.forEach((key, value) {
      if(int.parse(key) == i){
        //  do not save it to new map - this way it will be deleted
      }

      /// decrement series number higher than deleted one
      else
        if (int.parse(key) > i)
          {
            key = (int.parse(key) - 1).toString();
            updatedSeries.putIfAbsent(key, () => value.toString());
          }

        /// series number
        else
          {
            updatedSeries.putIfAbsent(key, () => value.toString());
          };
    });

    widget.workLog.load.forEach((key, value) {
      if(int.parse(key) == i){
        //  do not save it to new map - this way it will be deleted
      }

      /// decrement series number higher than deleted one
      else
        if (int.parse(key) > i)
          {
            key = (int.parse(key) - 1).toString();
            updatedLoad.putIfAbsent(key, () => value.toString());
          }

        /// series number
        else
          {
            updatedLoad.putIfAbsent(key, () => value.toString());
          };
    });

    widget.workLog.series = updatedSeries;
    widget.workLog.load = updatedLoad;
    await _db.updateWorkLog(widget.workLog);
    setState(() {});

    _log.fine("Series number $i deleted from ${widget.workLog.toString()}");
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }

  _getScreenWidth() {
    _screenWidth = Util.getScreenWidth(context);
  }


  List<Widget> _getAllBodyParts(WorkLog workLog) {
    List<Widget> result = <Widget>[];
    result.add(Text("Primary", style: TextStyle(
        color: AppThemeSettings.titleColor,
        fontSize: _isPortraitOrientation
            ? _titleFontSizePortrait
            : _titleFontSizeLandscape),));
    result.add(Util.spacerSelectable(bottom: _screenHeight * 0.01, top: 0, left: 0, right: 0));
    result.add(
        Column(children: _getBodyPartsBlocks(workLog.exercise.bodyParts)));
    result.add(Util.spacerSelectable(top: _screenHeight * 0.02, bottom: 0, left: 0, right: 0));
    result.add(Text("Secondary"));
    result.add(Util.spacerSelectable(bottom: _screenHeight * 0.01, top: 0, left: 0, right: 0));
    result.add(Column(
        children: _getBodyPartsBlocks(workLog.exercise.secondaryBodyParts)));
    return result;
  }

  List<Widget> _getBodyPartsBlocks(Set<BodyPart> bodyParts) {
    List<Row> result = <Row>[];
    List<SizedBox> boxes = <SizedBox>[];

    bodyParts.forEach((bp) {
      boxes.add(SizedBox(
        height: _screenHeight * 0.05,
        width: _screenWidth * 0.3,
        child: Container(
          color: Util.getBpColor(bp),
          child: Center(child: Text(
            Util.getBpName(bp), style: TextStyle(color: Colors.amber),)),
        ),
      ));
    });


    /// when more that 3 body parts is in one exercise
    /// make 2 rows
    if (boxes.length <= 3) {
      result.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: boxes,
      ));
    }
    else {
      List<SizedBox> firstRowBoxes = <SizedBox>[];
      List<SizedBox> secondRowBoxes = <SizedBox>[];

      int counter = 0;
      boxes.forEach((box) {
        counter++;

        if(counter < 4){
          firstRowBoxes.add(box);
        }
        else
          {
            secondRowBoxes.add(box);
          };
      });

      result.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: firstRowBoxes,
      ));
      result.add(Row(children: <Widget>[
        Util.spacerSelectable(top: _screenHeight * 0.01, bottom: 0, left: 0, right: 0)
      ],));
      result.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: secondRowBoxes,
      ));
    }
    return result;
  }
}
