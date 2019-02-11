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
                          addWidget(wList, textController.text, _FONTSIZE, w);
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
      List<Widget> wList, String text, double fontSize, WorkLog worklog) {
    setState(() {
      wList.add(
        addRow(text, fontSize, worklog),
      );
    });
  }
}

Widget addRow(String text, double fontSize, WorkLog worklog) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      addBorderedContainer(
        Text(
          worklog.exercise.name,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
      addBorderedContainer(
        Text(
          worklog.series.toString(),
          style: TextStyle(fontSize: fontSize),
        ),
      ),
      addBorderedContainer(
        Text(
          worklog.repeat.toString(),
          style: TextStyle(fontSize: fontSize),
        ),
      ),
      Text(
        worklog.time.toString(),
        style: TextStyle(fontSize: fontSize),
      ),
    ],
  );
}

Widget addBorderedContainer(Widget widget) {
  return Container(
    decoration:
        BoxDecoration(border: Border(right: BorderSide(color: Colors.red))),
    padding: EdgeInsets.symmetric(horizontal: 30),
    child: widget,
  );
}
