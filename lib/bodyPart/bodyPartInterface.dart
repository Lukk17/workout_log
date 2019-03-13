import 'package:flutter/material.dart';
import 'package:workout_log/entity/workLog.dart';

abstract class BodyPartInterface {
  List<Widget> wList = List();

  addWidgetToList(Widget widget);

  refreshList(WorkLog worklog, Widget widget);

  saveWorkLogToDB(WorkLog workLog);
}
