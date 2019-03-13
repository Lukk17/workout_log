import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_log/entity/workLog.dart';

class DBProvider {
  final String TABLEWORKLOG = "workLog";

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
      await db.execute("CREATE TABLE IF NOT EXISTS exercise ("
          "id VARCHAR(32) PRIMARY KEY,"
          "name TEXT,"
          "bodypart TEXT"
          ")");

      //  foreign key here because worklog can have only one exercise
      //  exercise can be in many worklogs
      //  ONE TO MANY relation
      await db.execute("CREATE TABLE IF NOT EXISTS $TABLEWORKLOG ("
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

    //  DB when insert give back ID of created entry
    //  TODO check if id saved in db is same as generated in class
    int idFromDB = await db.insert(TABLEWORKLOG, workLog.toMap());

    return idFromDB;
  }

  Future<int> updateWorkLog(WorkLog workLog) async {
    final db = await database;
    return await db.update(TABLEWORKLOG, workLog.toMap(),
        where: "id = ?", whereArgs: [workLog.id]);
  }

  Future<WorkLog> getWorkLogByID(int id) async {
    WorkLog log;
    final db = await database;
    var res = await db.query("worklog", where: "id = ?", whereArgs: [id]);

    //  if there is entry with this ID in DB it will be pulled
    if (res.isNotEmpty) {
      log = WorkLog.fromMap(res.first);
    }
    return log;
  }

  Future<List<WorkLog>> getAllWorkLogs() async {
    List<WorkLog> workLogList = new List();
    final db = await database;
    var res = await db.query("worklog");
    for (var l in res) {
      workLogList.add(WorkLog.fromMap(l));
    }
    return workLogList;
  }

  Future close() async => _database.close();
}
