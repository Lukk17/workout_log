import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';

const String workLogTable = 'workLog';
const String exerciseTable = 'exercise';

const int _schemaVersion = 2;

/// CONVENTION — schema migrations
///
/// Bump `_schemaVersion` and add a branch in [_onUpgrade] for every schema
/// change. Each branch handles exactly one version step (e.g. `if (oldV < 3)`).
/// Never edit prior branches — they may already have run on user devices.
class AppDatabase {
  AppDatabase({this.pathOverride});

  /// When non-null, opens the database at this absolute path instead of
  /// deriving from `getApplicationDocumentsDirectory()`. Used by tests.
  final String? pathOverride;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  /// Test-only: drop the cached handle so the next `database` access reopens
  /// against the current [pathOverride]. Closes any open handle first.
  Future<void> resetForTesting() async {
    await _database?.close();
    _database = null;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _open() async {
    final String path;
    if (pathOverride != null) {
      path = pathOverride!;
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
    for (final exercise in _defaultExerciseSeed) {
      await db.insert(exerciseTable, exercise.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 1 -> 2: no schema delta; introduces the upgrade hook itself.
    if (oldVersion < 2) {
      // intentionally no-op
    }
  }
}

/// Seed list installed on first launch. Pre-built freezed Exercise instances
/// so each test/fresh install gets the same starter catalog.
final List<Exercise> _defaultExerciseSeed = [
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
