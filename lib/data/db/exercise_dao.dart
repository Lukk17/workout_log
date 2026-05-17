import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/domain/models/exercise.dart';

/// CRUD operations on the `exercise` table.
class ExerciseDao {
  ExerciseDao(this._factory);

  final AppDatabase _factory;
  final Logger _log = Logger('ExerciseDao');

  Future<Database> get _db => _factory.database;

  /// All exercises, in insertion order.
  Future<List<Exercise>> getAll() async {
    final db = await _db;
    final rows = await db.query(exerciseTable);
    return rows.map(Exercise.fromMap).toList();
  }

  /// Returns the exercise with [id], or throws if not found.
  Future<Exercise> getById(String id) async {
    final db = await _db;
    final rows = await db.query(exerciseTable,
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) {
      throw Exception('exercise with id: $id was NOT found');
    }
    return Exercise.fromMap(rows.first);
  }

  /// Look up an existing exercise by exact name via an indexed query.
  /// Returns null if no match exists.
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

  /// Merge additional body parts into an exercise (additive). Used when a
  /// workout is added that names this exercise with a previously-unseen
  /// body part.
  Future<int> mergeBodyParts(Exercise exercise) =>
      _save(exercise, replaceBodyParts: false);

  /// Fully replace an exercise's name and body parts.
  Future<int> replace(Exercise exercise) =>
      _save(exercise, replaceBodyParts: true);

  /// Insert a brand-new exercise row.
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

    _log.fine('[save] $updated');
    return db.update(
      exerciseTable,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }
}
