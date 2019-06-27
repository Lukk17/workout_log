import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_log/entity/bodyPart.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/helloWorldView.dart';

class DBProvider {
  final String workLogTable = "workLog";
  final String exerciseTable = "exercise";

  // singleton is needed to have only one global DB provider
  DBProvider._();

  static final DBProvider db = DBProvider._();

  //  check if there is already database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null - instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    //  get path for storing DB (needs imported path_provider package)
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // join need 'dart:async' lib imported
    String path = join(documentsDirectory.path, "worklog.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS $exerciseTable ("
          "id VARCHAR(32) PRIMARY KEY,"
          "name TEXT,"
          "bodyPart TEXT"
          ")");

      //  foreign key here because workLog can have only one exercise
      //  exercise can be in many workLogs
      //  ONE TO MANY relation
      await db.execute("CREATE TABLE IF NOT EXISTS $workLogTable ("
          "id VARCHAR(32) PRIMARY KEY,"
          "series BLOB,"
          "created TEXT,"
          "exercise_id VARCHAR(32),"
          "FOREIGN KEY(exercise_id) REFERENCES exercise(id)"
          ")");
    });
  }

  Future<int> newWorkLog(WorkLog workLog) async {
    final db = await database;
    int idFromDB = 0;

    bool unique = true;

    List<Exercise> allExercises = await getAllExercise();
    for (var e in allExercises) {
      if (e.name == workLog.exercise.name) {
        //  add to DB only if there is no identical workLog entry
        //  (with same exercise and bodyPart)
        if (!e.bodyParts.contains(workLog.exercise.bodyParts.first)) {
          ///  if workLog is adding exercise which name already exist
          ///  but user added this exercise to another bodyPart
          ///  add this new bodyPart to exercise's bp list and update db
          e.bodyParts.addAll(workLog.exercise.bodyParts);
          db.update(exerciseTable, e.toMap(),
              where: "id = ?", whereArgs: [e.id]);

          //  db exercise as workLog exercise (to save one with correct ID)
          workLog.exercise = e;
        }
        //  when name and body part is identical change flag to false
        //  and do not save workLog
        unique = false;
      }
    }

    /// if it is new exercise save it to DB as well
    if (unique) {
      int eID = await db.insert(exerciseTable, workLog.exercise.toMap());

      idFromDB = await db.insert(workLogTable, workLog.toMap());
    }

    return idFromDB;
  }

  Future<int> updateWorkLog(WorkLog workLog) async {
    final db = await database;
    print("UPDATE EXERCISE ID:      " + workLog.exercise.bodyParts.toString());

    await db.update(exerciseTable, workLog.exercise.toMap(),
        where: "id = ?", whereArgs: [workLog.exercise.id]);

    int id = await db.update(workLogTable, workLog.toMap(),
        where: "id = ?", whereArgs: [workLog.id]);

    return id;
  }

  Future<WorkLog> getWorkLogByID(int id) async {
    WorkLog log;
    final db = await database;
    var res = await db.query("worklog", where: "id = ?", whereArgs: [id]);
    //  if there is entry with this ID in DB it will be pulled
    if (res.isNotEmpty) {
//      log = WorkLog.fromMap(res.first);
    }
    return log;
  }

  Future<List<WorkLog>> getAllWorkLogs() async {
    List<WorkLog> workLogList = new List();
    final db = await database;
    var res = await db.query("worklog");
    for (var l in res) {
      ///  exercise need to be pulled from DB
      /// and pushed to WorkLog.fromMap method
      Exercise exercise = await getExerciseByID(l["exercise_id"]);
      WorkLog dbLog = WorkLog.fromMap(l, exercise);
      workLogList.add(dbLog);
    }
    return workLogList;
  }

  Future<List<WorkLog>> getDateAllWorkLogs() async {
    String date = Util.formatter.format(HelloWorldView.date);
    List<WorkLog> workLogList = new List();
    final db = await database;
    var res =
        await db.query("worklog", where: "created = ?", whereArgs: [date]);
    for (var l in res) {
      ///  exercise need to be pulled from DB
      /// and pushed to WorkLog.fromMap method
      Exercise exercise = await getExerciseByID(l["exercise_id"]);
      WorkLog dbLog = WorkLog.fromMap(l, exercise);
      workLogList.add(dbLog);
    }
    return workLogList;
  }

  Future<Exercise> getExerciseByID(String id) async {
    Exercise exercise;
    final db = await database;
    var res = await db.query("exercise", where: "id = ?", whereArgs: [id]);

    //  if there is entry with this ID in DB it will be pulled
    if (res.isNotEmpty) {
      print("GET EXERCISE BY ID:    " + res.first.toString());
      exercise = Exercise.fromMap(res.first);
    } else {
      throw new Exception("exersice with id: $id was NOT found");
    }

    return exercise;
  }

  Future<List<Exercise>> getAllExercise() async {
    List<Exercise> result = List();
    final db = await database;
    var res = await db.query("exercise");
    if (res.isNotEmpty) {
      for (var e in res) {
        result.add(Exercise.fromMap(e));
      }
    }
    return result;
  }

  Future<List<WorkLog>> getWorkLogs(BodyPart part) async {
    List<WorkLog> workLogList = List();
    final db = await database;
    String date = Util.formatter.format(HelloWorldView.date);

    // pull every workLog from given date
    var res =
        await db.query("worklog", where: "created = ?", whereArgs: [date]);

    for (var l in res) {
      //  exercise need to be pulled from DB
      // and pushed to WorkLog.fromMap method
      Exercise exercise = await getExerciseByID(l["exercise_id"]);
      WorkLog dbLog = WorkLog.fromMap(l, exercise);

      // save only entries with given BodyPart
      if (dbLog.exercise.bodyParts.contains(part)) {
        workLogList.add(dbLog);
      }
    }

    print('getWorklogs : $part  and ${workLogList.toString()}');

    return workLogList;
  }

  Future close() async => _database.close();
}
