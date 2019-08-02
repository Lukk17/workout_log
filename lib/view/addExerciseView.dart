import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

import 'helloWorldView.dart';

class AddExerciseView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddExerciseView();
}

class _AddExerciseView extends State<AddExerciseView> {
  //  get DB from singleton global provider
  final DBProvider _db = DBProvider.db;

  final Logger _log = new Logger("AddExerciseView");

  Set<BodyPart> _bodyParts = Set();

  bool _chest = false;
  bool _back = false;
  bool _arm = false;
  bool _leg = false;
  bool _abdominal = false;
  bool _cardio = false;

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

  @override
  void initState() {
    super.initState();

    _key = GlobalKey();

    ///  set initial textField text
    _myController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    Util.hideKeyboard(context);
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
          preferredSize: Size.fromHeight(_isPortraitOrientation ? _appBarHeightPortrait : _appBarHeightLandscape),
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
            mainAxisAlignment: _isPortraitOrientation ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
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
              if (!_isPortraitOrientation) Util.spacerSelectable(top: _screenHeight * 0.1),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text(
                            "CHEST",
                            style: TextStyle(color: AppThemeSettings.textColor),
                          ),
                          Checkbox(
                              value: _chest,
                              onChanged: (value) {
                                setState(() {
                                  _chest = value;
                                  _updateBP(BodyPart.CHEST, value);
                                });
                              }),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text(
                            "BACK",
                            style: TextStyle(color: AppThemeSettings.textColor),
                          ),
                          Checkbox(
                              value: _back,
                              onChanged: (value) {
                                setState(() {
                                  _back = value;
                                  _updateBP(BodyPart.BACK, value);
                                });
                              }),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text(
                            "ARM",
                            style: TextStyle(color: AppThemeSettings.textColor),
                          ),
                          Checkbox(
                              value: _arm,
                              onChanged: (value) {
                                setState(() {
                                  _arm = value;
                                  _updateBP(BodyPart.ARM, value);
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text(
                            "LEG",
                            style: TextStyle(color: AppThemeSettings.textColor),
                          ),
                          Checkbox(
                              value: _leg,
                              onChanged: (value) {
                                setState(() {
                                  _leg = value;
                                  _updateBP(BodyPart.LEG, value);
                                });
                              }),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text(
                            "ABDOMINAL",
                            style: TextStyle(color: AppThemeSettings.textColor),
                          ),
                          Checkbox(
                              value: _abdominal,
                              onChanged: (value) {
                                setState(() {
                                  _abdominal = value;
                                  _updateBP(BodyPart.ABDOMINAL, value);
                                });
                              }),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text(
                            "CARDIO",
                            style: TextStyle(color: AppThemeSettings.textColor),
                          ),
                          Checkbox(
                              value: _cardio,
                              onChanged: (value) {
                                setState(() {
                                  _cardio = value;
                                  _updateBP(BodyPart.CARDIO, value);
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (!_isPortraitOrientation) Util.spacerSelectable(top: _screenHeight * 0.08),
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
        height: _isPortraitOrientation ? _buttonHeightPortrait : _buttonHeightLandscape,
        minWidth: _isPortraitOrientation ? _buttonWidthPortrait : _buttonWidthLandscape,
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
        height: _isPortraitOrientation ? _buttonHeightPortrait : _buttonHeightLandscape,
        minWidth: _isPortraitOrientation ? _buttonWidthPortrait : _buttonWidthLandscape,
        color: AppThemeSettings.cancelButtonColor,
        splashColor: AppThemeSettings.buttonSplashColor,
        textColor: AppThemeSettings.buttonTextColor,
        child: Text("Cancel"),
      ),
    );

    return result;
  }

  void _saveExercise() async {
    if (_myController.text == null || _myController.text.isEmpty) {
      _key.currentState.showSnackBar(SnackBar(content: Text("You forgot about exercise name :)")));
      return;
    }

    if (_bodyParts == null || _bodyParts.isEmpty) {
      _key.currentState.showSnackBar(SnackBar(content: Text("You forgot about exercise body part :)")));
      return;
    }

    await addWorkLog(Exercise(_myController.text, _bodyParts));

    //  hide keyboard before navigate to previous view
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
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

  void _updateBP(BodyPart bodyPart, bool value) {
    if (value)
      _bodyParts.add(bodyPart);
    else
      _bodyParts.remove(bodyPart);
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }

  _getScreenWidth() {
    _screenWidth = Util.getScreenWidth(context);
  }
}