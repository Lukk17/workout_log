import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
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
  final DBProvider _db = DBProvider.db;

  final Logger _log = new Logger("EditExerciseView");

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

    ///  set initial textField text
    _myController = TextEditingController(text: widget.exercise.name);

    /// checkbox should be checked only if exercise have that body part
    _updateCheckboxesState();
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

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(_isPortraitOrientation ? _appBarHeightPortrait : _appBarHeightLandscape),
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
        onPressed: () async =>  {
        await Util.hideKeyboard(context),
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

    _log.fine("Updating exercise: ${widget.exercise.toString()}");

    await Util.hideKeyboard(context);

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
