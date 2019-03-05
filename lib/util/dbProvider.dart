import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_log/entity/workLog.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null - instantiate it
    _database = await initDB();
    return _database;
  }


  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // join need 'dart:async' lib imported
    String path = join(documentsDirectory.path, "worklog.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {

      await db.execute("CREATE TABLE IF NOT EXISTS exercise ("
          "id VARCHAR(32) PRIMARY KEY,"
          "name TEXT,"
          "bodypart TEXT"
          ")");

      await db.execute("CREATE TABLE IF NOT EXISTS worklog ("
          "id VARCHAR(32) PRIMARY KEY,"
          "series INTEGER,"
          "repeat INTEGER"
          ")");

      // exercise can be in many worklogs, worklog can have many exercises
      // Many to Many relation need additional table
      // TODO wrong relation ! worklog have exactly one exercise(which can be in many worklogs)
      await db.execute("CREATE TABLE IF NOT EXISTS exercise_worklog ("
          "exercise_id VARCHAR(32),"
          "worklog_id VARCHAR(32),"
          "FOREIGN KEY(exercise_id) REFERENCES exercise(id),"
          "FOREIGN KEY(worklog_id) REFERENCES worklog(id)"
          ")");
    });
  }

  newWorkLog(WorkLog newClient) async {
    await _database.transaction((txn) async {
      // Ok
      await txn.execute('CREATE TABLE Test1 (id INTEGER PRIMARY KEY)');
    });
  }

  getWorkLog(int id) async {
    final db = await database;
    var res = await  db.query("worklog", where: "id = ?", whereArgs: [id]);
    if(res.isNotEmpty){
      // TODO worklog is created from exercise and then add rest
      WorkLog log = WorkLog.fromMap(res.first);

      //needs exercise ID to get exercise from DB and add to worklog
      // get exercise id from common table
      var findExercise = await  db.rawQuery("SELECT exercise_id FROM exercise_worklog WHERE worklog_id="+log.id.toString());
      String exerciseID = findExercise.removeLast().remove("exercise_id");

      // get exerciese from exercise table by id
      var exerciseRes = await  db.query("exercise", where: "id = ?", whereArgs: [exerciseID]);
      log.exercise = Exercise.fromMap(exerciseRes.first);

    }
  }

}