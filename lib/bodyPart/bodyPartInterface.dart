import 'package:flutter/material.dart';
import 'package:workout_log/entity/workLog.dart';

abstract class BodyPartInterface {
  static List<Widget> wList = List();

  saveWorkLogToDB(WorkLog workLog);

  updateWorkLogToDB(WorkLog workLog);

  updateState();
}
