import 'package:sqflite/sqflite.dart';
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/util/log.dart';

class ExerciseDao {
  ExerciseDao(this._appDatabase);

  final AppDatabase _appDatabase;
  static const _tag = 'ExerciseDao';

  Future<Database> get _db => _appDatabase.database;

  Future<List<Exercise>> getAll() async {
    final db = await _db;
    final rows = await db.query(exerciseTable);
    return rows.map(Exercise.fromMap).toList();
  }

  Future<Exercise> getById(String id) async {
    final db = await _db;
    final rows = await db
        .query(exerciseTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) {
      throw Exception('exercise with id: $id was NOT found');
    }
    return Exercise.fromMap(rows.first);
  }

  Future<Exercise?> findByName(String name) async {
    final db = await _db;
    final rows = await db.query(
      exerciseTable,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Exercise.fromMap(rows.first);
  }

  Future<int> mergeBodyParts(Exercise exercise) =>
      _save(exercise, replaceBodyParts: false);

  Future<int> replace(Exercise exercise) =>
      _save(exercise, replaceBodyParts: true);

  Future<int> insert(Exercise exercise) async {
    final db = await _db;
    return db.insert(exerciseTable, exercise.toMap());
  }

  Future<int> _save(Exercise exercise, {required bool replaceBodyParts}) async {
    final db = await _db;
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

    logFine('[save] $updated', name: _tag);
    return db.update(
      exerciseTable,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }
}
