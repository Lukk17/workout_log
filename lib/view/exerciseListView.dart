import 'package:flutter/material.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';

import 'editExerciseView.dart';

class ExerciseListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExerciseListViewState();
}

class _ExerciseListViewState extends State<ExerciseListView> {
  List<MaterialButton> exerciseList = List();

  //  get DB from singleton global provider
  DBProvider _db = DBProvider.db;

  @override
  void initState() {
    super.initState();

    _getExercises();
    print('$exerciseList');
  }

  @override
  Widget build(BuildContext context) {
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
        body: ListView.builder(
          itemCount: exerciseList.length,
          itemBuilder: (context, index) => exerciseList[index],
        ),
      ),
    );
  }

  _getExercises() async {
    List<MaterialButton> result = List();
    List<Exercise> exercises = await _db.getAllExercise();

    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ${exercises.toString()}');

    for (Exercise e in exercises) {
      result.add(MaterialButton(
        key: Key(e.name),
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditExerciseView(exercise: e))).then((val) => _getExercises());
        },
        child: Text(e.name),
      ));
    }
    setState(() {
      exerciseList = result;
    });
  }
}
