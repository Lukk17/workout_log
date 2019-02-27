import 'package:flutter/material.dart';
import 'package:workout_log/bodyPart/bodyPartInterface.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/setting/appTheme.dart';

class Util {
  static Future addRowDialog(
    BodyPartInterface bp,
    String title,
    String hint,
    BuildContext context,
    TextEditingController textController,
    BodyPart bodyPart,
  ) {
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
                maxLength: 50,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          // add widget to column widget's list
                          // text is forwarded by controller from SimpleDialog text field
                          Exercise exercise =
                              Exercise(textController.text, bodyPart);
                          WorkLog workLog = WorkLog(exercise);
                          bp.addWidgetToList(
                            addWorkLogRow(workLog, bp, "title", "hint", context, textController, bodyPart),
                          );
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

  static Widget addWorkLogRow(
    WorkLog workLog,
    BodyPartInterface bp,
    String title,
    String hint,
    BuildContext context,
    TextEditingController textController,
    BodyPart bodyPart,
  ) {
    context.findRenderObject();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: AppTheme.borderColor),
            ),
          ),
          child: FlatButton(
            child: Text(
              workLog.exercise.name,
              style: TextStyle(fontSize: AppTheme.fontSize),
            ),
            onPressed: () => addRowDialog(bp, title, hint, context, textController, bodyPart),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.25,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: AppTheme.borderColor),
            ),
          ),
          child: FlatButton(
            child: Text(
              workLog.series.toString(),
              style: TextStyle(fontSize: AppTheme.fontSize),
            ),
            onPressed: () => addRowDialog(bp, title, hint, context, textController, bodyPart),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.25,
          child: FlatButton(
            child: Text(
              workLog.repeat.toString(),
              style: TextStyle(fontSize: AppTheme.fontSize),
            ),
            onPressed: () => addRowDialog(bp, title, hint, context, textController, bodyPart),
          ),
        ),
      ],
    );
  }

  static Future editSeriesDialog(
      String title,
      BuildContext context,
      TextEditingController textController,
      BodyPart bodyPart,
      WorkLog worklog,
      BodyPartInterface bp,
      ) {
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Center(child: Text("Edit series number")),
        contentPadding: EdgeInsets.all(20),
        children: <Widget>[
          TextField(
            // use text controller to save given by user String
            controller: textController,
            autofocus: true,
            autocorrect: true,
            decoration: InputDecoration(hintText: worklog.series.toString()),
            maxLength: 4,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                    child: const Text('SAVE'),
                    onPressed: () {
                      worklog.series=textController.text as int;
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

  static Widget addHorizontalLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }

  static Widget addVerticalLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }

}
