import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';

class Chest extends StatefulWidget {
  Chest({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChestState();
  }
}

class _ChestState extends State<Chest> {
  List<Widget> wList = List();

  static const BodyPart _BODYPART = BodyPart.CHEST;
  static const double _FONTSIZE = 30;
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chest'),
          backgroundColor: Colors.red,
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Column(
                children: wList,
              ),
            ],
          ),
        ),
        floatingActionButton: Hero(
          tag: "button",
          child: FloatingActionButton(
            // text which will be shown after long press on button
            tooltip: 'Add exercise',

            // open pop-up on button press to add new exercise
            onPressed: () => openDialog('Exercise', 'eg. pushup'),

            child: Icon(Icons.add),
            backgroundColor: Colors.red,
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Dart Doc comment
  Future openDialog(String title, String hint) {
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text(title)),
            contentPadding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(
                // use text controller to save given by user String
                controller: textController,
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(hintText: hint),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // add widget to column widget's list
                          // text is forwarded by controller from SimpleDialog text field
                          Exercise e = Exercise(textController.text, _BODYPART);
                          WorkLog w = WorkLog(e);
                          addWidget(wList, textController.text, _FONTSIZE, w, context);
                          Navigator.pop(context);
                        }),
                    FlatButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ]),
            ],
          ),
    );
  }

  void addWidget(
      List<Widget> wList, String text, double fontSize, WorkLog worklog, BuildContext context) {
    setState(() {
      wList.add(
        addRow(text, fontSize, worklog, context),
      );
    });
  }
}

Widget addRow(String text, double fontSize, WorkLog worklog, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      addBorderedContainer(
        Text(
          worklog.exercise.name,
          style: TextStyle(fontSize: fontSize),

        ),0.4,context
      ),
      addBorderedContainer(
        Text(
          worklog.series.toString(),
          style: TextStyle(fontSize: fontSize),

        ), 0.2,context
      ),
      addBorderedContainer(
        Text(
          worklog.repeat.toString(),
          style: TextStyle(fontSize: fontSize),
        ),  0.2,context
      ),
      Container(
        width: MediaQuery.of(context).size.width *0.2,
        padding: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        worklog.time.toString(),
        style: TextStyle(fontSize: fontSize),
      ),)
    ],
  );
}

Widget addBorderedContainer(Widget widget, double width, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * width,
    decoration:
        BoxDecoration(border: Border(right: BorderSide(color: Colors.red))),
    padding: EdgeInsets.symmetric(horizontal: 30),
    child: widget,
  );
}
