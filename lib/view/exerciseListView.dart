import 'package:flutter/material.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';

class ExerciseListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExerciseListViewState();
}

class _ExerciseListViewState extends State<ExerciseListView> {
  List<MaterialButton> exerciseList = List();

  //  get DB from singleton global provider
  DBProvider db = DBProvider.db;

  @override
  void initState() {
    super.initState();
    getExercises();
    print('$exerciseList');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Exercises Edit",
            style: TextStyle(
              color: AppThemeSettings.titleColor,
              fontSize: AppThemeSettings.fontSize,
            ),
          ),
          backgroundColor: AppThemeSettings.appBarColor),
      body: ListView(
        children: <Widget>[
          Column(
            children: exerciseList,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
        ],
      ),
    );
  }

  void getExercises() async {
    List<MaterialButton> result = List();
    List<Exercise> exercises = await db.getAllExercise();

    for (Exercise e in exercises) {
      result.add(MaterialButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(e.name),
      ));
    }
    setState(() {
      exerciseList = result;
    });
  }
}
