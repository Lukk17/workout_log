import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/helloWorldView.dart';

import '../main.dart';
import 'bodyPartLogView.dart';

/// This is main WorkLog view.
///
/// It show actual date, and buttons with body parts.
/// Each buttons leads to BodyPartLogView page of selected body part.
class WorkLogPageView extends StatefulWidget {
  final Function(Widget) callback;
  final DateTime date;

  WorkLogPageView(this.callback, this.date);

  @override
  State<StatefulWidget> createState() => _WorkLogPageViewState(date);
}

class _WorkLogPageViewState extends State<WorkLogPageView> {
  final DateTime date;
  Orientation screenOrientation;

  //  to save helloWorld scaffold key
  final GlobalKey<ScaffoldState> scaffoldKey = MyApp.globalKey;

  _WorkLogPageViewState(this.date);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      screenOrientation = orientation;
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            alignment: Alignment(-0.7, 0),
            child: Text(
              Util.formatter.format(HelloWorldView.date) ==
                      Util.formatter.format(DateTime.now())
                  ? "Today"
                  : Util.formatter.format(HelloWorldView.date),
              textScaleFactor: 3,
              style: TextStyle(
                  color: AppThemeSettings.textColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          (orientation == Orientation.portrait)

              //  for portrait orientation
              ? Table(
                  columnWidths: {
                    0: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.35),
                    1: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.175),
                    2: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.35)
                  },
                  defaultColumnWidth:
                      FixedColumnWidth(MediaQuery.of(context).size.width * 0.3),
                  children: [
                    TableRow(
                      children: <Widget>[
                        _createCategoryButton('chest', BodyPart.CHEST),
                        Util.spacer(5),
                        _createCategoryButton('back', BodyPart.BACK),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Util.spacer(MediaQuery.of(context).size.height * 0.01),
                        Util.spacer(MediaQuery.of(context).size.height * 0.005),
                        Util.spacer(MediaQuery.of(context).size.height * 0.01)
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        _createCategoryButton('arm', BodyPart.ARM),
                        Util.spacer(5),
                        _createCategoryButton('leg', BodyPart.LEG),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Util.spacer(MediaQuery.of(context).size.height * 0.01),
                        Util.spacer(MediaQuery.of(context).size.height * 0.01),
                        Util.spacer(MediaQuery.of(context).size.height * 0.01)
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        _createCategoryButton('abdominal', BodyPart.ABDOMINAL),
                        Util.spacer(MediaQuery.of(context).size.height * 0.005),
                        _createCategoryButton('cardio', BodyPart.CARDIO),
                      ],
                    )
                  ],
                )

              //  for landscape orientation
              : Table(
                  columnWidths: {
                    0: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.2),
                    1: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.1),
                    2: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.2),
                    3: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.1),
                    4: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.2),
                  },
                  defaultColumnWidth:
                      FixedColumnWidth(MediaQuery.of(context).size.width * 0.3),
                  children: [
                    TableRow(
                      children: <Widget>[
                        _createCategoryButton('chest', BodyPart.CHEST),
                        Util.spacer(5),
                        _createCategoryButton('back', BodyPart.BACK),
                        Util.spacer(5),
                        _createCategoryButton('arm', BodyPart.ARM),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Util.spacer(MediaQuery.of(context).size.height * 0.01),
                        Util.spacer(MediaQuery.of(context).size.height * 0.005),
                        Util.spacer(MediaQuery.of(context).size.height * 0.01),
                        Util.spacer(MediaQuery.of(context).size.height * 0.005),
                        Util.spacer(MediaQuery.of(context).size.height * 0.01),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        _createCategoryButton('leg', BodyPart.LEG),
                        Util.spacer(5),
                        _createCategoryButton('abdominal', BodyPart.ABDOMINAL),
                        Util.spacer(MediaQuery.of(context).size.height * 0.005),
                        _createCategoryButton('cardio', BodyPart.CARDIO),
                      ],
                    ),
                  ],
                ),
          _createCategoryButton('all'),
        ],
      );
    });
  }

  /// Creates button routing to BodyPartLogView
  ///
  /// BodyPart is optional due to option for showing all exercises
  /// on any body part
  Widget _createCategoryButton(String text, [BodyPart bodyPart]) {
    /// if method is called without [bodyPart],
    /// then it is set to [BodyPart.UNDEFINED],
    /// which lead to show workLogs from all body parts
    if (bodyPart == null) bodyPart = BodyPart.UNDEFINED;

    MaterialButton cb = MaterialButton(
      // after pushing button, navigate to a new screen
      onPressed: () {
        bodyPart == BodyPart.UNDEFINED
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BodyPartLogView(date: date, bodyPart: BodyPart.UNDEFINED),
                ),
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BodyPartLogView(date: date, bodyPart: bodyPart),
                ),
              ).then(restoreKey());
      },
      height: (screenOrientation == Orientation.portrait)
          ? MediaQuery.of(context).size.height * 0.06
          : MediaQuery.of(context).size.height * 0.1,
      minWidth: (screenOrientation == Orientation.portrait)
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width * 0.3,
      color: AppThemeSettings.buttonColor,
      splashColor: AppThemeSettings.buttonSplashColor,
      textColor: AppThemeSettings.buttonTextColor,
      child: Text(text),
    );
    return cb;
  }

  restoreKey(){
    MyApp.globalKey = scaffoldKey;
  }

}
