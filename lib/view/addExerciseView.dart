import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/storage.dart';
import 'package:workout_log/util/util.dart';

import 'helloWorldView.dart';

class AddExerciseView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddExerciseView();
}

class _AddExerciseView extends State<AddExerciseView> {
  //  get DB from singleton global provider
  DBProvider _db = DBProvider.db;

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

      _getScreenHeight();
      _getScreenWidth();

      return Scaffold(
        /// when keyboard is shown the layout is not rebuild
        /// thank to this there is no pixel overflow
        resizeToAvoidBottomInset: false,

        key: _key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(_isPortraitOrientation ? _screenHeight * 0.08 : _screenHeight * 0.1),
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
                    width: _screenWidth * 0.7,
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
              if(!_isPortraitOrientation) Util.spacerSelectable(top: _screenHeight * 0.1),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Text("CHEST"),
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
                          Text("BACK"),
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
                          Text("ARM"),
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
                          Text("LEG"),
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
                          Text("ABDOMINAL"),
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
                          Text("CARDIO"),
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
              if(!_isPortraitOrientation) Util.spacerSelectable(top: _screenHeight * 0.08),
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
        height: _isPortraitOrientation ? _screenHeight * 0.06 : _screenHeight * 0.1,
        minWidth: _isPortraitOrientation ? _screenWidth * 0.5 : _screenWidth * 0.27,
        color: AppThemeSettings.greenButtonColor,
        splashColor: AppThemeSettings.buttonSplashColor,
        textColor: AppThemeSettings.buttonTextColor,
        child: Text("SAVE"),
      ),
    );

    if (_isPortraitOrientation) {
      result.add(Util.spacerSelectable(top: 30));
    } else {
      result.add(Util.spacerSelectable(right: 30));
    }
    result.add(
      MaterialButton(
        onPressed: () => {
          //  hide keyboard before navigate to previous view
          Util.hideKeyboard(context),
          Navigator.pop(context),
        },
        height: _isPortraitOrientation ? _screenHeight * 0.06 : _screenHeight * 0.1,
        minWidth: _isPortraitOrientation ? _screenWidth * 0.5 : _screenWidth * 0.27,
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
        _db.updateExercise(w.exercise);
        print("\n [addworklog] UPDATE EXERCISE BP  : ============>  ${w.exercise.toString()}\n ");
        return w;
      }
    }
    WorkLog workLog = WorkLog(exercise);
    workLog.exercise.bodyParts = exercise.bodyParts; // bodyPart as Set()
    workLog.created = HelloWorldView.date;
    String json = jsonEncode(workLog);

    print("\n [addworklog] ADDING NEW WORKLOG  : ============>  ${workLog.toString()}\n ");

    /// save to json
    Storage.writeToFile(json);

    ///  save workLog to DB
    await _db.newWorkLog(workLog);

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
