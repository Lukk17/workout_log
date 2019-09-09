import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
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

  final Logger _log = new Logger("DBProvider");

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

    return await openDatabase(path, version: 1, onOpen: (db) {}, onCreate: (Database db, int version) async {
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
          "load BLOB,"
          "bodyWeight REAL,"
          "series BLOB,"
          "created TEXT,"
          "exercise_id VARCHAR(32),"
          "FOREIGN KEY(exercise_id) REFERENCES exercise(id)"
          ")");

      //  adding some basic exercises to db
      List<Exercise> exercises = List();

      exercises.add(Exercise("Push Up", {BodyPart.CHEST, BodyPart.ARM}));
      exercises.add(Exercise("Pull Up", {BodyPart.BACK, BodyPart.ARM}));
      exercises.add(Exercise("Dead Lift", {BodyPart.BACK, BodyPart.LEG, BodyPart.ARM}));
      exercises.add(Exercise("Running", {BodyPart.CARDIO}));

      exercises.forEach(
        (exercise) => db.insert(exerciseTable, exercise.toMap()),
      );
    });
  }

  Future<int> newWorkLog(WorkLog workLog) async {
    final db = await database;
    int idFromDB = 0;

    bool unique = true;

    List<Exercise> allExercises = await getAllExercise();

    for (var dbExercise in allExercises) {
      ///  add to DB only if there is no identical workLog entry
      ///  (with same exercise and bodyPart)
      if (dbExercise.name == workLog.exercise.name) {
        ///  if user is adding exercise which name already exist
        ///  but user added this exercise to another bodyPart
        ///  add this new bodyPart to exercise's bp list and update db
        if (!dbExercise.bodyParts.contains(workLog.exercise.bodyParts.first)) {
          dbExercise.bodyParts.addAll(workLog.exercise.bodyParts);
          db.update(exerciseTable, dbExercise.toMap(), where: "id = ?", whereArgs: [dbExercise.id]);

          _log.fine("[newWorkLog] UPDATING EXERCISE : ${dbExercise.toString()}");
        }

        //  db exercise as workLog exercise (to save one with correct ID)
        workLog.exercise = dbExercise;
        idFromDB = await db.insert(workLogTable, workLog.toMap());

        _log.fine("ADDING NEW WORKLOG: ${workLog.toString()}");

        //  when name and body part is identical change flag to false
        //  and do not save workLog again
        unique = false;
      }
    }

    /// if it is new exercise save it to DB as well
    if (unique) {
      _log.fine("ADDING NEW WORKLOG AND NEW EXERCISE: ${workLog.toString()}");

      await db.insert(exerciseTable, workLog.exercise.toMap());
      idFromDB = await db.insert(workLogTable, workLog.toMap());
    }

    return idFromDB;
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await database;
    int id = -1;

    List<Exercise> allExercises = await getAllExercise();
    // check if in db on that day is workLog with same exercise name but different bodypart
    //  if so save this exercise new body part

    for (var dbExercise in allExercises) {
      if (dbExercise.id == exercise.id) {
        dbExercise.bodyParts.addAll(exercise.bodyParts);
        id = await db.update(exerciseTable, dbExercise.toMap(), where: "id = ?", whereArgs: [dbExercise.id]);

        _log.fine("UPDATE EXERCISE: ${dbExercise.toString()}");
      }
    }
    return id;
  }

  Future<int> editExercise(Exercise exercise) async {
    final db = await database;
    int id = -1;

    List<Exercise> allExercises = await getAllExercise();
    // check if in db on that day is workLog with same exercise name but different bodypart
    //  if so save this exercise new body part

    for (var dbExercise in allExercises) {
      if (dbExercise.id == exercise.id) {
        dbExercise.bodyParts = exercise.bodyParts;
        dbExercise.name = exercise.name;
        id = await db.update(exerciseTable, dbExercise.toMap(), where: "id = ?", whereArgs: [dbExercise.id]);

        _log.fine("UPDATE EXERCISE: ${dbExercise.toString()}");
      }
    }
    return id;
  }

  Future<int> updateWorkLog(WorkLog workLog) async {
    final db = await database;

    _log.fine("UPDATE WORKLOG: ${workLog.toString()}");

    await db.update(exerciseTable, workLog.exercise.toMap(), where: "id = ?", whereArgs: [workLog.exercise.id]);
    int id = await db.update(workLogTable, workLog.toMap(), where: "id = ?", whereArgs: [workLog.id]);

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

    var res = await db.query(workLogTable);

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

    //  if there is entry with this ID in DB it will be pulled
    if (res.isNotEmpty) {
      _log.fine("GET EXERCISE BY ID: res.first.toString()");

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

  Future<List<WorkLog>> getDateBodyPartWorkLogs(BodyPart part) async {
    List<WorkLog> workLogList = List();
    final db = await database;
    String date = Util.formatter.format(HelloWorldView.date);

    // pull every workLog from given date
    var res = await db.query("worklog", where: "created = ?", whereArgs: [date]);

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

    _log.fine("getWorklogs : $part  and ${workLogList.toString()}");

    return workLogList;
  }

  void deleteWorkLog(WorkLog workLog) async {
    final db = await database;

    db.delete(workLogTable, where: "id = ?", whereArgs: [workLog.id]);

    _log.fine("Deleted workLog: ${workLog.toString()}");
  }

  Future close() async => _database.close();

  void backup() async {
    final Directory externalDirectory = await getExternalStorageDirectory();

    String backupJsonPath = join(externalDirectory.path, "backup.json");

    //  backup DB
    //    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //    String dbPath = join(documentsDirectory.path, "worklog.db");
    //    String backupPath = join(externalDirectory.path, "dbBackup");
    //    ByteData data = await rootBundle.load(dbPath);
    //    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    //
    //    await File(backupPath).writeAsBytes(bytes, flush: true);

    //        backup as json
    List<WorkLog> list = await getAllWorkLogs();
    Map<String, dynamic> jsons = Map();

    for (WorkLog w in list) {
      jsons.addAll(w.toMap());
    }

    String backupJ = jsonEncode(list);
    File(backupJsonPath).writeAsString(backupJ);
  }

  void restore(String backup) {
    List<dynamic> jsonToRestore = jsonDecode(backup);

    for (var v in jsonToRestore) {
      db.newWorkLog(WorkLog.fromJson(v));
    }
  }
}
