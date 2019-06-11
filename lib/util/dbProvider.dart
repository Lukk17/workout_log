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

    ///  DB when insert give back ID of created entry
    ///  (which should be same as generated in class)
    int idFromDB = await db.insert(workLogTable, workLog.toMap());

    ///  need to save exercise to DB as well
    await db.insert(exerciseTable, workLog.exercise.toMap());

    return idFromDB;
  }

  Future<int> updateWorkLog(WorkLog workLog) async {
    final db = await database;
    print("UPDATE EXERCISE ID:      " + workLog.exercise.bodyPart.toString());

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
    var res = await db.query("worklog", where: "created = ?", whereArgs: [date]);
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

    print("GET EXERCISE BY ID:    " + res.first.toString());

    //  if there is entry with this ID in DB it will be pulled
    if (res.isNotEmpty) {
      exercise = Exercise.fromMap(res.first);
    } else {
      throw new Exception("exersice with id: $id was NOT found");
    }

    return exercise;
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
      if (dbLog.exercise.bodyPart == part) {

        workLogList.add(dbLog);
      }
    }
    
    print('getWorklogs : $part  and ${workLogList.toString()}');

    return workLogList;
  }

  Future close() async => _database.close();
}
