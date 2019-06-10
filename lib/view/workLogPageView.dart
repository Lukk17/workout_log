import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';

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
        Column(
          children: <Widget>[
            _createCategoryButton('chest', BodyPart.CHEST),
            _spacer(15),
            _createCategoryButton('back', BodyPart.BACK),
            _spacer(15),
            _createCategoryButton('arm', BodyPart.ARM),
            _spacer(15),
            _createCategoryButton('leg', BodyPart.LEG),
            _spacer(15),
            _createCategoryButton('abdominal', BodyPart.ABDOMINAL),
            _spacer(15),
            _createCategoryButton('all'),
          ],
        )
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
