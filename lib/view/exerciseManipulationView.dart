import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

import 'helloWorldView.dart';

class ExerciseManipulationView extends StatefulWidget {
  final Exercise exercise;

  ExerciseManipulationView({Key key, this.exercise});

  @override
  State<StatefulWidget> createState() => _ExerciseManipulationView();
}

class _ExerciseManipulationView extends State<ExerciseManipulationView> {
  //  get DB from singleton global provider
  final DBProvider _db = DBProvider.db;

  final Logger _log = new Logger("ExerciseManipulationView");

  Set<BodyPart> _primaryBodyParts = Set();
  List<Widget> _primaryBodyPartsList = List();
  Set<BodyPart> _secondaryBodyParts = Set();
  List<Widget> _secondaryBodyPartsList = List();
  Map<String, bool> _valuesMap = Map();
  bool _edit = false;

  TextEditingController _myController;
  GlobalKey<ScaffoldState> _key;

  double _screenHeight;
  double _screenWidth;
  bool _isPortraitOrientation;

  double _appBarHeightPortrait;
  double _appBarHeightLandscape;
  double _textFieldWidth;
  double _buttonHeightPortrait;
  double _buttonHeightLandscape;
  double _buttonWidthPortrait;
  double _buttonWidthLandscape;

  void setupDimensions() {
    _getScreenHeight();
    _getScreenWidth();

    _appBarHeightPortrait = _screenHeight * 0.08;
    _appBarHeightLandscape = _screenHeight * 0.1;
    _textFieldWidth = _screenWidth * 0.7;
    _buttonHeightPortrait = _screenHeight * 0.06;
    _buttonHeightLandscape = _screenHeight * 0.1;
    _buttonWidthPortrait = _screenWidth * 0.5;
    _buttonWidthLandscape = _screenWidth * 0.27;
  }

  Map<String, bool> setupValues() => {
        Util.getBpName(BodyPart.CHEST): false,
        Util.getBpName(BodyPart.LEG): false,
        Util.getBpName(BodyPart.ABDOMINAL): false,
        Util.getBpName(BodyPart.ARM): false,
        Util.getBpName(BodyPart.BACK): false,
        Util.getBpName(BodyPart.CARDIO): false,
      };

  checkIfEdit() {
    if (widget.exercise != null) {
      _edit = true;
      for (BodyPart bp in widget.exercise.bodyParts) {
        _updateBP(bp, true);
        _valuesMap[Util.getBpName(bp)] = true;
      }
      for (BodyPart bp in widget.exercise.secondaryBodyParts) {
        _updateSecondaryBP(bp, true);
        _valuesMap[Util.getBpName(bp)] = true;
      }

      ///  set initial textField text
      _myController = TextEditingController(text: widget.exercise.name);
    } else {
      ///  set initial textField text
      _myController = TextEditingController();
    }
  }

  @override
  void initState() {
    super.initState();
    _key = GlobalObjectKey<ScaffoldState>(17);
    _valuesMap = setupValues();
    checkIfEdit();

    _getPrimaryBPlist();
    _getSecondaryBPlist();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      /// check if new orientation is portrait
      /// rebuild from here where orientation will change
      _isPortraitOrientation = orientation == Orientation.portrait;

      setupDimensions();

      return Scaffold(
        /// when keyboard is shown the layout is not rebuild
        /// thank to this there is no pixel overflow
        resizeToAvoidBottomInset: false,

        key: _key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(_isPortraitOrientation
              ? _appBarHeightPortrait
              : _appBarHeightLandscape),
          child: AppBar(
              centerTitle: true,
              title: Text(
                "Add Exercises",
                style: TextStyle(
                  color: AppThemeSettings.titleColor,
                  fontSize: AppThemeSettings.fontSize,
                ),
              ),
              backgroundColor: AppThemeSettings.appBarColor),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: _isPortraitOrientation
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    width: _textFieldWidth,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: _myController,
                      style: TextStyle(
                        fontSize: AppThemeSettings.headerSize,
                      ),
                    ),
                  ),
                ],
              ),
              if (!_isPortraitOrientation)
                Util.spacerSelectable(top: _screenHeight * 0.1),
              _isPortraitOrientation
                  ? Column(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text("Main Body Parts:"),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _primaryBodyPartsList,
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text("Secodary Body Parts:"),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _secondaryBodyPartsList,
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text("Main Body Parts:"),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _primaryBodyPartsList,
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text("Secodary Body Parts:"),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _secondaryBodyPartsList,
                            ),
                          ],
                        ),
                      ],
                    ),
              if (!_isPortraitOrientation)
                Util.spacerSelectable(top: _screenHeight * 0.08),
              _isPortraitOrientation
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _getControlButtons(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _getControlButtons(),
                    )
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _getControlButtons() {
    List<Widget> result = List();

    result.add(
      MaterialButton(
        onPressed: () => _saveExercise(),
        height: _isPortraitOrientation
            ? _buttonHeightPortrait
            : _buttonHeightLandscape,
        minWidth: _isPortraitOrientation
            ? _buttonWidthPortrait
            : _buttonWidthLandscape,
        color: AppThemeSettings.greenButtonColor,
        splashColor: AppThemeSettings.buttonSplashColor,
        textColor: AppThemeSettings.buttonTextColor,
        child: Text("SAVE"),
      ),
    );

    if (_isPortraitOrientation) {
      result.add(Util.spacerSelectable(top: _screenHeight * 0.05));
    } else {
      result.add(Util.spacerSelectable(right: _screenWidth * 0.1));
    }
    result.add(
      MaterialButton(
        onPressed: () => {
          //  hide keyboard before navigate to previous view
          Util.hideKeyboard(context),
          Navigator.pop(context),
        },
        height: _isPortraitOrientation
            ? _buttonHeightPortrait
            : _buttonHeightLandscape,
        minWidth: _isPortraitOrientation
            ? _buttonWidthPortrait
            : _buttonWidthLandscape,
        color: AppThemeSettings.cancelButtonColor,
        splashColor: AppThemeSettings.buttonSplashColor,
        textColor: AppThemeSettings.buttonTextColor,
        child: Text("Cancel"),
      ),
    );

    return result;
  }

  void _updateBP(BodyPart bodyPart, bool value) {
    if (value) {
      _primaryBodyParts.add(bodyPart);
      //  if simultaneously click on both primary and secondary checkboxes
      //  will remove this body part from first clicked list
      _secondaryBodyParts.remove(bodyPart);
    } else
      _primaryBodyParts.remove(bodyPart);
  }

  void _updateSecondaryBP(BodyPart bodyPart, bool value) {
    if (value) {
      _secondaryBodyParts.add(bodyPart);
      //  if simultaneously click on both primary and secondary checkboxes
      //  will remove this body part from first clicked list
      _primaryBodyParts.remove(bodyPart);
    } else
      _secondaryBodyParts.remove(bodyPart);
  }

  /// factory to get checkbox for given Body Part
  Widget _getWidgetForBP(BodyPart bp, [bool secondary = false]) {
    String name = Util.getBpName(bp);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: <Widget>[
        Text(
          name,
          style: TextStyle(color: AppThemeSettings.textColor),
        ),
        Checkbox(
            value: _valuesMap[name],
            onChanged: (value) {
              setState(() {
                _valuesMap[name] = value;
                if (secondary) {
                  _updateSecondaryBP(bp, value);
                } else {
                  _updateBP(bp, value);
                }
                _getPrimaryBPlist();
                _getSecondaryBPlist();
              });
            }),
      ],
    );
  }

  /// get checkboxes for primary body parts
  /// unchecked ones means that this body part is not primary or secondary
  /// if it is primary it checkbox will be checked here
  /// and not displayed in secondary body parts list
  _getPrimaryBPlist() {
    List<Widget> tempList = List();
    _primaryBodyPartsList = List();
    for (BodyPart bp in BodyPart.values) {
      if (bp == BodyPart.UNDEFINED) {
        // skip undefined
        continue;
      }
      if (!_secondaryBodyParts.contains(bp)) {
        // if this body part is not marked as secondary,
        // empty checkbox can be displayed here
        tempList.add(_getWidgetForBP(bp));
      }
    }

    // cut widgets to 2 rows (for visual)
    if (tempList.length > 3) {
      int counter = 0;
      List<Widget> firstHalf = List();
      List<Widget> secondHalf = List();
      for (Widget w in tempList) {
        if (counter < 3) {
          firstHalf.add(w);
          counter++;
        } else {
          secondHalf.add(w);
        }
      }

      _primaryBodyPartsList.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: firstHalf,
      ));
      _primaryBodyPartsList.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: secondHalf));
    } else {
      _primaryBodyPartsList.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tempList));
    }
  }

  /// get checkboxes for secondary body parts
  /// unchecked ones means that this body part is not primary or secondary
  /// if it is secondary it checkbox will be checked here
  /// and not displayed in primary body parts list
  _getSecondaryBPlist() {
    List<Widget> tempList = List();
    _secondaryBodyPartsList = List();
    for (BodyPart bp in BodyPart.values) {
      if (bp == BodyPart.UNDEFINED) {
        //skip undefined
        continue;
      }
      if (!_primaryBodyParts.contains(bp)) {
        // if this body part is not marked as primary,
        // empty checkbox can be displayed here
        tempList.add(_getWidgetForBP(bp, true));
      }
    }

    // cut widgets to 2 rows (for visual)
    if (tempList.length > 3) {
      int counter = 0;
      List<Widget> firstHalf = List();
      List<Widget> secondHalf = List();
      for (Widget w in tempList) {
        if (counter < 3) {
          firstHalf.add(w);
          counter++;
        } else {
          secondHalf.add(w);
        }
      }
      _secondaryBodyPartsList.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: firstHalf,
      ));
      _secondaryBodyPartsList.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: secondHalf));
    } else {
      _secondaryBodyPartsList.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tempList));
    }
  }

  void _saveExercise() async {
    if (_myController.text == null || _myController.text.isEmpty) {
      _key.currentState.showSnackBar(
          SnackBar(content: Text("You forgot about exercise name :)")));
      return;
    }

    if (_primaryBodyParts == null || _primaryBodyParts.isEmpty) {
      _key.currentState.showSnackBar(
          SnackBar(content: Text("You forgot about exercise body part :)")));
      return;
    }

    if (_edit) {
      widget.exercise.name = _myController.text;
      widget.exercise.bodyParts = _primaryBodyParts;
      widget.exercise.secondaryBodyParts = _secondaryBodyParts;
      _db.editExercise(widget.exercise);
      _log.fine("Updating exercise: ${widget.exercise.toString()}");

      await Util.hideKeyboard(context);
      Navigator.popUntil(
          context, ModalRoute.withName(Navigator.defaultRouteName));
    } else {
      await addWorkLog(
          Exercise(_myController.text, _primaryBodyParts, _secondaryBodyParts));
      //  hide keyboard before navigate to previous view
      FocusScope.of(context).requestFocus(new FocusNode());
      Navigator.pop(context);
    }
  }

  Future<WorkLog> addWorkLog(Exercise exercise) async {
    //  get all workLogs from that day
    List<WorkLog> workLogList = await _db.getDateAllWorkLogs();

    ///  check if workLogs have same exercise name
    for (var w in workLogList) {
      if (w.exercise.name == exercise.name) {
        /// if there is workLog with that exercise name on this day,
        ///  but with different bodyPart
        /// update db with this new body part
        w.exercise.bodyParts.addAll(exercise.bodyParts);
        await _db.updateExercise(w.exercise);

        _log.fine("Worklog updated ${w.exercise.toString()}");

        return w;
      }
    }
    WorkLog workLog = WorkLog(exercise);
    workLog.exercise.bodyParts = exercise.bodyParts; // bodyPart as Set()
    workLog.created = HelloWorldView.date;

    //    String json = jsonEncode(workLog);
    //        /// save to json
    //        Storage.writeToFile(json);

    ///  save workLog to DB
    await _db.newWorkLog(workLog);

    _log.fine("New workLog saved to DB: ${workLog.toString()}");

    return workLog;
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }

  _getScreenWidth() {
    _screenWidth = Util.getScreenWidth(context);
  }
}
