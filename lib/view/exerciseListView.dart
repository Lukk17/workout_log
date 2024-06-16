import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';

import 'exerciseManipulationView.dart';

class ExerciseListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExerciseListViewState();
}

class _ExerciseListViewState extends State<ExerciseListView> {
  List<MaterialButton> exerciseList = <MaterialButton>[];

  //  get DB from singleton global provider
  final DBProvider _db = DBProvider.db;

  final Logger _log = new Logger("ExerciseListView");

  @override
  void initState() {
    super.initState();

    _getExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ListView.builder(
        itemCount: exerciseList.length,
        itemBuilder: (context, index) => exerciseList[index],
      ),
    );
  }

  _getExercises() async {
    List<MaterialButton> result = <MaterialButton>[];
    List<Exercise> exercises = await _db.getAllExercise();

    _log.fine('List of DB exercise: ${exercises.toString()}');

    for (Exercise e in exercises) {
      result.add(MaterialButton(
        key: Key(e.name),
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseManipulationView(exercise: e)))
              .then((val) => _getExercises());
        },
        child: Text(
          e.name,
          style: TextStyle(color: AppThemeSettings.specialTextColor),
        ),
      ));
    }
    setState(() {
      exerciseList = result;
    });
  }
}
