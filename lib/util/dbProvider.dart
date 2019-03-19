import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_log/entity/exercise.dart';
import 'package:workout_log/entity/workLog.dart';

class DBProvider {
  final String WORKLOG_TABLE = "workLog";
  final String EXERCISE_TABLE = "exercise";

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
      await db.execute("CREATE TABLE IF NOT EXISTS $EXERCISE_TABLE ("
          "id VARCHAR(32) PRIMARY KEY,"
          "name TEXT,"
          "bodypart TEXT"
          ")");

      //  foreign key here because worklog can have only one exercise
      //  exercise can be in many worklogs
      //  ONE TO MANY relation
      await db.execute("CREATE TABLE IF NOT EXISTS $WORKLOG_TABLE ("
          "id VARCHAR(32) PRIMARY KEY,"
          "series INTEGER,"
          "repeat INTEGER,"
          "exercise_id VARCHAR(32),"
          "FOREIGN KEY(exercise_id) REFERENCES exercise(id)"
          ")");
    });
  }

  Future<int> newWorkLog(WorkLog workLog) async {
    final db = await database;
    print("NEW EXERCISE ID:      " + workLog.exercise.id);
    //  DB when insert give back ID of created entry
    //  TODO check if id saved in db is same as generated in class
    int idFromDB = await db.insert(WORKLOG_TABLE, workLog.toMap());
    //  need to save exercise to DB as well
    await db.insert(EXERCISE_TABLE, workLog.exercise.toMap());

    return idFromDB;
  }

  Future<int> updateWorkLog(WorkLog workLog) async {
    final db = await database;
    print("UPDATE EXERCISE ID:      " + workLog.exercise.id);
    await db.update(EXERCISE_TABLE, workLog.exercise.toMap(), where: "id = ?", whereArgs: [workLog.exercise.id]);
    return await db.update(WORKLOG_TABLE, workLog.toMap(),
        where: "id = ?", whereArgs: [workLog.id]);
  }

  Future<WorkLog> getWorkLogByID(int id) async {
    WorkLog log;
    final db = await database;
    var res = await db.query("worklog", where: "id = ?", whereArgs: [id]);
    // TODO need refactor to include pulling exercise from DB like getAllWorkLogs method
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
      //  exercise need to be pulled from DB
      // and pushed to WorkLog.fromMap method
      Exercise exercise = await getExerciseByID(l["exercise_id"]);
      WorkLog dbLog = WorkLog.fromMap(l, exercise);
      workLogList.add(dbLog);
    }
    return workLogList;
  }

  Future<Exercise> getExerciseByID(String id) async {
    Exercise exercise;
    final db = await database;
    print("GET EXERCISE BY ID:    "+ id);
    var res = await db.query("exercise", where: "id = ?", whereArgs: [id]);
    //  if there is entry with this ID in DB it will be pulled
    if (res.isNotEmpty) {
      exercise = Exercise.fromMap(res.first);
    } else {
      throw new Exception("exersice with id: $id was NOT found");
    }
    return exercise;
  }

  Future close() async => _database.close();
}
