import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/helloWorldView.dart';

import 'bodyPartLogView.dart';

class WorkLogPageView extends StatefulWidget {
  final Function(Widget) callback;
  final DateTime date;

  WorkLogPageView(this.callback, this.date);

  @override
  State<StatefulWidget> createState() => _WorkLogPageViewState(date);
}

class _WorkLogPageViewState extends State<WorkLogPageView> {
  final DateTime date;

  _WorkLogPageViewState(this.date);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(Util.formatter.format(HelloWorldView.date) ==
                Util.formatter.format(DateTime.now())
            ? "Today"
            : Util.formatter.format(HelloWorldView.date)),
        Table(
          columnWidths: {
            0: FixedColumnWidth(130),
            1: FixedColumnWidth(50),
            2: FixedColumnWidth(130)
          },
          defaultColumnWidth: FixedColumnWidth(130),
          children: [
            TableRow(
              children: <Widget>[
                _createCategoryButton('chest', BodyPart.CHEST),
                _spacer(5),
                _createCategoryButton('back', BodyPart.BACK),
              ],
            ),
            TableRow(
              children: <Widget>[_spacer(10), _spacer(5), _spacer(10)],
            ),
            TableRow(
              children: <Widget>[
                _createCategoryButton('arm', BodyPart.ARM),
                _spacer(5),
                _createCategoryButton('leg', BodyPart.LEG),
              ],
            ),
            TableRow(
              children: <Widget>[_spacer(10), _spacer(10), _spacer(10)],
            ),
            TableRow(
              children: <Widget>[
                _createCategoryButton('abdominal', BodyPart.ABDOMINAL),
                _spacer(5),
                _createCategoryButton('cardio', BodyPart.CARDIO),
              ],
            )
          ],
        ),
        _createCategoryButton('all'),
      ],
    );
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
              );
      },
      height: 60,
      minWidth: 350,
      color: Colors.red,
      child: Text(text),
    );
    return cb;
  }

  Widget _spacer(double size) {
    return Container(margin: EdgeInsets.all(size));
  }
}
