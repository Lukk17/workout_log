import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/util/util.dart';

/// Raised when external (shared) storage is not available on the device,
/// so backup/restore cannot read or write the backup file.
class ExternalStorageUnavailableException implements Exception {
  final String message;
  ExternalStorageUnavailableException([this.message = 'External storage not available']);
  @override
  String toString() => message;
}

/// CONVENTION — schema migrations
///
/// Bump `_schemaVersion` and add a branch in `_onUpgrade` for every schema
/// change. Each branch handles exactly one version step (e.g. `if (oldV < 3)`).
/// Never edit prior branches — they may already have run on user devices.
class DBProvider {
  static const String workLogTable = 'workLog';
  static const String exerciseTable = 'exercise';

  static const int _schemaVersion = 2;

  final Logger _log = Logger('DBProvider');

  DBProvider._();

  static final DBProvider db = DBProvider._();

  /// Override the sqflite database path (used by tests). When null, the path
  /// derives from `getApplicationDocumentsDirectory()`.
  static String? databasePathOverride;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  /// Test-only: drop the cached handle so the next `database` access reopens
  /// against the current `databasePathOverride`. Closes any open handle first.
  Future<void> resetForTesting() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _initDB() async {
    final String path;
    if (databasePathOverride != null) {
      path = databasePathOverride!;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      path = join(dir.path, 'worklog.db');
    }

    return openDatabase(
      path,
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

    // workLog has foreign key on exercise: one exercise -> many workLogs
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

    // Seed default exercises — awaited so the database getter never returns
    // before the seed completes (fixes the prior fire-and-forget forEach).
    final seedExercises = _defaultExerciseSeed();
    for (final exercise in seedExercises) {
      await db.insert(exerciseTable, exercise.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 1 -> 2: no schema delta; introduces the upgrade hook itself.
    if (oldVersion < 2) {
      // intentionally no-op
    }
  }

  List<Exercise> _defaultExerciseSeed() => [
        Exercise.create(name: 'Push Up', bodyParts: {BodyPart.chest}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Pull Up', bodyParts: {BodyPart.back}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Dead Lift', bodyParts: {BodyPart.back, BodyPart.leg}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Running', bodyParts: {BodyPart.cardio}),
        Exercise.create(name: 'Back Lat Pull-Downs', bodyParts: {BodyPart.back}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Dumbbell Flys', bodyParts: {BodyPart.chest}, secondaryBodyParts: {BodyPart.arm, BodyPart.abdominal}),
        Exercise.create(name: 'Bench Presses', bodyParts: {BodyPart.chest}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Barbell Curls', bodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Machine Presses', bodyParts: {BodyPart.chest}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Back Extensions', bodyParts: {BodyPart.back}, secondaryBodyParts: {BodyPart.leg, BodyPart.abdominal}),
        Exercise.create(name: 'Machine Low Row', bodyParts: {BodyPart.back}, secondaryBodyParts: {BodyPart.arm, BodyPart.abdominal}),
        Exercise.create(name: 'Machine Lat Pulldown', bodyParts: {BodyPart.back}, secondaryBodyParts: {BodyPart.arm, BodyPart.abdominal}),
        Exercise.create(name: 'Barbell Squats', bodyParts: {BodyPart.leg}, secondaryBodyParts: {BodyPart.back}),
        Exercise.create(name: 'Back Presses', bodyParts: {BodyPart.arm}, secondaryBodyParts: {BodyPart.back, BodyPart.abdominal}),
        Exercise.create(name: 'Plank', bodyParts: {BodyPart.abdominal}, secondaryBodyParts: {BodyPart.leg}),
        Exercise.create(name: 'Leg Raises', bodyParts: {BodyPart.abdominal}, secondaryBodyParts: {BodyPart.leg}),
        Exercise.create(name: 'Incline Presses', bodyParts: {BodyPart.chest, BodyPart.arm}),
        Exercise.create(name: 'Decline Presses', bodyParts: {BodyPart.chest}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Concentration Dumbell Curls', bodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Dumbell Front Arm Raises', bodyParts: {BodyPart.arm}, secondaryBodyParts: {BodyPart.abdominal, BodyPart.chest}),
        Exercise.create(name: 'Muscle-Up', bodyParts: {BodyPart.back, BodyPart.arm}, secondaryBodyParts: {BodyPart.chest, BodyPart.abdominal}),
        Exercise.create(name: 'Burpees', bodyParts: {BodyPart.cardio}, secondaryBodyParts: {BodyPart.chest, BodyPart.arm, BodyPart.abdominal}),
        Exercise.create(name: 'Cable Crossover Flys', bodyParts: {BodyPart.chest}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Barbell Rows', bodyParts: {BodyPart.back}, secondaryBodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Dumbbell Shrugs', bodyParts: {BodyPart.arm}, secondaryBodyParts: {BodyPart.back}),
        Exercise.create(name: 'Dumbbell Curls', bodyParts: {BodyPart.arm}),
        Exercise.create(name: 'Bent-Over Lateral Raises', bodyParts: {BodyPart.arm}, secondaryBodyParts: {BodyPart.back}),
      ];

  /// Look up an existing exercise by exact name via an indexed query.
  /// Returns null if no match exists.
  Future<Exercise?> _findExerciseByName(Database db, String name) async {
    final rows = await db.query(
      exerciseTable,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Exercise.fromMap(rows.first);
  }

  Future<int> newWorkLog(WorkLog workLog) async {
    final db = await database;

    final existing = await _findExerciseByName(db, workLog.exercise.name);
    if (existing != null) {
      // Exercise already known. If the caller is adding the workLog under a
      // body part that wasn't previously associated, merge it onto the
      // existing exercise.
      WorkLog toInsert = workLog;
      Exercise resolvedExercise = existing;
      final firstNewBp = workLog.exercise.bodyParts.isEmpty
          ? null
          : workLog.exercise.bodyParts.first;
      if (firstNewBp != null && !existing.bodyParts.contains(firstNewBp)) {
        resolvedExercise = existing.copyWith(
          bodyParts: {...existing.bodyParts, ...workLog.exercise.bodyParts},
        );
        await db.update(
          exerciseTable,
          resolvedExercise.toMap(),
          where: 'id = ?',
          whereArgs: [resolvedExercise.id],
        );
        _log.fine('[newWorkLog] UPDATED EXERCISE: $resolvedExercise');
      }
      toInsert = workLog.copyWith(exercise: resolvedExercise);
      try {
        final id = await db.insert(workLogTable, toInsert.toMap());
        _log.fine('[newWorkLog] INSERTED WORKLOG: $toInsert');
        return id;
      } on DatabaseException {
        _log.warning('[newWorkLog] duplicate workLog id; skipping insert');
        return 0;
      }
    }

    // Brand new exercise + new workLog
    _log.fine('[newWorkLog] NEW EXERCISE + WORKLOG: $workLog');
    await db.insert(exerciseTable, workLog.exercise.toMap());
    return db.insert(workLogTable, workLog.toMap());
  }

  /// Merge additional body parts into an exercise (additive). Used when a
  /// workout is added that names this exercise with a previously-unseen
  /// body part.
  Future<int> updateExercise(Exercise exercise) =>
      _saveExercise(exercise, replaceBodyParts: false);

  /// Fully replace an exercise's name and body parts.
  Future<int> editExercise(Exercise exercise) =>
      _saveExercise(exercise, replaceBodyParts: true);

  Future<int> _saveExercise(Exercise exercise, {required bool replaceBodyParts}) async {
    final db = await database;
    final rows = await db.query(
      exerciseTable,
      where: 'id = ?',
      whereArgs: [exercise.id],
      limit: 1,
    );
    if (rows.isEmpty) return -1;

    final existing = Exercise.fromMap(rows.first);
    final updated = replaceBodyParts
        ? existing.copyWith(
            name: exercise.name,
            bodyParts: exercise.bodyParts,
            secondaryBodyParts: exercise.secondaryBodyParts,
          )
        : existing.copyWith(
            bodyParts: {...existing.bodyParts, ...exercise.bodyParts},
          );

    _log.fine('[saveExercise] $updated');
    return db.update(
      exerciseTable,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  Future<int> updateWorkLog(WorkLog workLog) async {
    final db = await database;
    _log.fine('[updateWorkLog] $workLog');
    await db.update(
      exerciseTable,
      workLog.exercise.toMap(),
      where: 'id = ?',
      whereArgs: [workLog.exercise.id],
    );
    return db.update(
      workLogTable,
      workLog.toMap(),
      where: 'id = ?',
      whereArgs: [workLog.id],
    );
  }

  Future<WorkLog?> getWorkLogById(String id) async {
    final db = await database;
    final rows = await db.query(workLogTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    final exercise = await getExerciseById(rows.first['exercise_id'].toString());
    return WorkLog.fromMap(rows.first, exercise);
  }

  Future<List<WorkLog>> getAllWorkLogs() async {
    final db = await database;
    final rows = await db.query(workLogTable);
    final result = <WorkLog>[];
    for (final row in rows) {
      final exercise = await getExerciseById(row['exercise_id'].toString());
      result.add(WorkLog.fromMap(row, exercise));
    }
    return result;
  }

  /// All workouts created on the given date.
  Future<List<WorkLog>> getWorkLogsForDate(DateTime date) async {
    final formattedDate = Util.formatter.format(date);
    final db = await database;
    final rows = await db.query(workLogTable, where: 'created = ?', whereArgs: [formattedDate]);
    final result = <WorkLog>[];
    for (final row in rows) {
      final exercise = await getExerciseById(row['exercise_id'].toString());
      result.add(WorkLog.fromMap(row, exercise));
    }
    return result;
  }

  Future<Exercise> getExerciseById(String id) async {
    final db = await database;
    final rows = await db.query(exerciseTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) {
      throw Exception('exercise with id: $id was NOT found');
    }
    _log.fine('[getExerciseById] $id');
    return Exercise.fromMap(rows.first);
  }

  Future<List<Exercise>> getAllExercise() async {
    final db = await database;
    final rows = await db.query(exerciseTable);
    return rows.map(Exercise.fromMap).toList();
  }

  Future<List<WorkLog>> getDateBodyPartWorkLogs(DateTime date, BodyPart part) async {
    final formattedDate = Util.formatter.format(date);
    final db = await database;
    final rows = await db.query(workLogTable, where: 'created = ?', whereArgs: [formattedDate]);
    final result = <WorkLog>[];
    for (final row in rows) {
      final exercise = await getExerciseById(row['exercise_id'].toString());
      final wl = WorkLog.fromMap(row, exercise);
      if (wl.exercise.bodyParts.contains(part)) {
        result.add(wl);
      }
    }
    _log.fine('[getDateBodyPartWorkLogs] $part -> ${result.length}');
    return result;
  }

  Future<void> deleteWorkLog(WorkLog workLog) async {
    final db = await database;
    await db.delete(workLogTable, where: 'id = ?', whereArgs: [workLog.id]);
    _log.fine('[deleteWorkLog] $workLog');
  }

  Future<void> close() async => _database?.close();

  Future<void> backup() async {
    final dir = await _externalStorageDir();
    final backupPath = join(dir.path, 'backup.json');

    final list = await getAllWorkLogs();
    final encoded = jsonEncode(list);
    await File(backupPath).writeAsString(encoded);
    _log.fine('[backup] wrote ${list.length} workLogs to $backupPath');
  }

  Future<void> restore() async {
    final dir = await _externalStorageDir();
    final backupPath = join(dir.path, 'backup.json');
    final file = File(backupPath);
    if (!await file.exists()) {
      throw ExternalStorageUnavailableException('backup file not found at $backupPath');
    }
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as List<dynamic>;
    for (final entry in decoded) {
      await newWorkLog(WorkLog.fromJson(entry as Map<String, dynamic>));
    }
    _log.fine('[restore] imported ${decoded.length} workLogs from $backupPath');
  }

  Future<Directory> _externalStorageDir() async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw ExternalStorageUnavailableException();
      }
      return dir;
    } on ExternalStorageUnavailableException {
      rethrow;
    } catch (e) {
      throw ExternalStorageUnavailableException('failed to access external storage: $e');
    }
  }
}
