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
  DBProvider db = DBProvider.db;

  bool _chest = false;
  bool _back = false;
  bool _arm = false;
  bool _leg = false;
  bool _abdominal = false;
  bool _cardio = false;

  Orientation screenOrientation;
  String editedName;
  TextEditingController myController;

  @override
  void initState() {
    super.initState();

    ///  set initial textField text
    myController = TextEditingController(text: widget.exercise.name);

    /// checkbox should be checked only if exercise have that body part
    updateCheckboxesState();

    print(
        'EditExerciseView >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.exercise.name} \t ${widget.exercise.bodyParts.toString()} \t ID: ${widget.exercise.id}');
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      screenOrientation = orientation;
      return Hero(
        tag: "exerciseEdit",
        child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Exercises Edit",
                style: TextStyle(
                  color: AppThemeSettings.titleColor,
                  fontSize: AppThemeSettings.fontSize,
                ),
              ),
              backgroundColor: AppThemeSettings.appBarColor),
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: myController,
                        style: TextStyle(
                          fontSize: AppThemeSettings.headerSize,
                        ),
                      ),
                    ),
                  ],
                ),
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
                                    updateBP(BodyPart.CHEST, value);
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
                                    updateBP(BodyPart.BACK, value);
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
                                    updateBP(BodyPart.ARM, value);
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
                                    updateBP(BodyPart.LEG, value);
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
                                    updateBP(BodyPart.ABDOMINAL, value);
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
                                    updateBP(BodyPart.CARDIO, value);
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () => saveExercise(),
                      height: (screenOrientation == Orientation.portrait)
                          ? MediaQuery.of(context).size.height * 0.06
                          : MediaQuery.of(context).size.height * 0.1,
                      minWidth: (screenOrientation == Orientation.portrait)
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width * 0.27,
                      color: AppThemeSettings.greenButtonColor,
                      splashColor: AppThemeSettings.buttonSplashColor,
                      textColor: AppThemeSettings.buttonTextColor,
                      child: Text("SAVE"),
                    ),
                    Util.spacerSelectable(top: 30),
                    MaterialButton(
                      onPressed: () => {
                        Navigator.pop(context),
                      },
                      height: (screenOrientation == Orientation.portrait)
                          ? MediaQuery.of(context).size.height * 0.06
                          : MediaQuery.of(context).size.height * 0.1,
                      minWidth: (screenOrientation == Orientation.portrait)
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width * 0.27,
                      color: AppThemeSettings.cancelButtonColor,
                      splashColor: AppThemeSettings.buttonSplashColor,
                      textColor: AppThemeSettings.buttonTextColor,
                      child: Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void updateCheckboxesState() {
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

  void saveExercise() async {
    widget.exercise.name = myController.text;
    await db.editExercise(widget.exercise);
    Navigator.pop(context);
  }

  void updateBP(BodyPart bodyPart, bool value) {
    if (value)
      widget.exercise.bodyParts.add(bodyPart);
    else
      widget.exercise.bodyParts.remove(bodyPart);
  }
}
