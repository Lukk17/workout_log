import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

class EditExerciseView extends StatefulWidget {
  final Exercise exercise;

  EditExerciseView({Key key, @required this.exercise}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditExerciseView();
}

class _EditExerciseView extends State<EditExerciseView> {
  //  get DB from singleton global provider
  DBProvider _db = DBProvider.db;

  bool _chest = false;
  bool _back = false;
  bool _arm = false;
  bool _leg = false;
  bool _abdominal = false;
  bool _cardio = false;

  TextEditingController _myController;
  double _screenHeight;
  double _screenWidth;
  bool _isPortraitOrientation;

  @override
  void initState() {
    super.initState();

    ///  set initial textField text
    _myController = TextEditingController(text: widget.exercise.name);

    /// checkbox should be checked only if exercise have that body part
    _updateCheckboxesState();

    print('EditExerciseView >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.exercise.name} '
        '\t ${widget.exercise.bodyParts.toString()} \t ID: ${widget.exercise.id}');
  }

  @override
  void dispose() {
    Util.hideKeyboard(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      /// check if new orientation is portrait
      /// rebuild from here where orientation will change
      _isPortraitOrientation = orientation == Orientation.portrait;

      _getScreenHeight();
      _getScreenWidth();

      return Hero(
        tag: "exerciseEdit",
        child: Scaffold(
          /// when keyboard is shown the layout is not rebuild
          /// thank to this there is no pixel overflow
          resizeToAvoidBottomInset: false,

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(_isPortraitOrientation ? _screenHeight * 0.08 : _screenHeight * 0.1),
            child: AppBar(
                centerTitle: true,
                title: Text(
                  "Exercises Edit",
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
                _isPortraitOrientation ? null : Util.spacerSelectable(top: _screenHeight * 0.1),
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
                _isPortraitOrientation ? null : Util.spacerSelectable(top: _screenHeight * 0.08),
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
      result.add(Util.spacerSelectable(top: _screenHeight * 0.05));
    } else {
      result.add(Util.spacerSelectable(right: _screenWidth * 0.1));
    }

    result.add(
      MaterialButton(
        onPressed: () => {
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

  void _updateCheckboxesState() {
    for (var bp in widget.exercise.bodyParts) {
      switch (bp) {
        case BodyPart.CHEST:
          _chest = true;
          break;

        case BodyPart.BACK:
          _back = true;
          break;

        case BodyPart.ARM:
          _arm = true;
          break;

        case BodyPart.LEG:
          _leg = true;
          break;

        case BodyPart.ABDOMINAL:
          _abdominal = true;
          break;

        case BodyPart.CARDIO:
          _cardio = true;
          break;

        default:
          break;
      }
    }
  }

  void _saveExercise() async {
    widget.exercise.name = _myController.text;
    await _db.editExercise(widget.exercise);
    Navigator.pop(context);
  }

  void _updateBP(BodyPart bodyPart, bool value) {
    if (value)
      widget.exercise.bodyParts.add(bodyPart);
    else
      widget.exercise.bodyParts.remove(bodyPart);
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }

  _getScreenWidth() {
    _screenWidth = Util.getScreenWidth(context);
  }
}
