import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:workout_log/data/db/default_exercise_seed.dart';
import 'package:workout_log/domain/models/exercise.dart';

const String workLogTable = 'workLog';
const String exerciseTable = 'exercise';

const int _schemaVersion = 2;

// CONVENTION — schema migrations
//
// Bump _schemaVersion and add a branch in _onUpgrade for every schema
// change. Each branch handles exactly one version step (e.g. `if (oldV < 3)`).
// Never edit prior branches — they may already have run on user devices.
class AppDatabase {
  AppDatabase(
    this._path, {
    List<Exercise>? seed,
  }) : _seed = seed ?? defaultExerciseSeed;

  final Future<String> _path;
  final List<Exercise> _seed;

  Database? _database;

  Future<Database> get database async => _database ??= await _open();

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _open() async {
    return openDatabase(
      await _path,
      version: _schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $exerciseTable ('
      'id VARCHAR(32) PRIMARY KEY,'
      'name TEXT,'
      'bodyPart TEXT,'
      'secondaryBodyPart'
      ')',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS $workLogTable ('
      'id VARCHAR(32) PRIMARY KEY,'
      'load BLOB,'
      'bodyWeight REAL,'
      'series BLOB,'
      'created TEXT,'
      'exercise_id VARCHAR(32),'
      'FOREIGN KEY(exercise_id) REFERENCES $exerciseTable(id)'
      ')',
    );

    for (final exercise in _seed) {
      await db.insert(exerciseTable, exercise.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 1 -> 2: no schema delta; introduces the upgrade hook itself.
    }
  }
}
