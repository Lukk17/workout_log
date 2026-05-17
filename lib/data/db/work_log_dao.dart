import 'package:sqflite/sqflite.dart';
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/util/responsive.dart';
import 'package:workout_log/util/log.dart';

/// CRUD operations on the `workLog` table. Joins to `exercise` via
/// [ExerciseDao] when hydrating rows.
class WorkLogDao {
  WorkLogDao(this._factory, this._exerciseDao);

  final AppDatabase _factory;
  final ExerciseDao _exerciseDao;
  static const _tag = 'WorkLogDao';

  Future<Database> get _db => _factory.database;

  /// Insert a new workLog. Dedups against existing exercises by name —
  /// if the exercise is already known, merges any new body parts onto
  /// the existing row and stores the workLog under that existing exercise id.
  Future<int> insert(WorkLog workLog) async {
    final db = await _db;
    final existing = await _exerciseDao.findByName(workLog.exercise.name);

    if (existing != null) {
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
        logFine('[insert] UPDATED EXERCISE: $resolvedExercise', name: _tag);
      }
      toInsert = workLog.copyWith(exercise: resolvedExercise);
      try {
        final id = await db.insert(workLogTable, toInsert.toMap());
        logFine('[insert] INSERTED WORKLOG: $toInsert', name: _tag);
        return id;
      } on DatabaseException {
        logWarn('[insert] duplicate workLog id; skipping insert', name: _tag);
        return 0;
      }
    }

    logFine('[insert] NEW EXERCISE + WORKLOG: $workLog', name: _tag);
    await _exerciseDao.insert(workLog.exercise);
    return db.insert(workLogTable, workLog.toMap());
  }

  Future<int> update(WorkLog workLog) async {
    final db = await _db;
    logFine('[update] $workLog', name: _tag);
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

  Future<WorkLog?> getById(String id) async {
    final db = await _db;
    final rows = await db
        .query(workLogTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    final exercise =
        await _exerciseDao.getById(rows.first['exercise_id'].toString());
    return WorkLog.fromMap(rows.first, exercise);
  }

  Future<List<WorkLog>> getAll() async {
    final db = await _db;
    final rows = await db.query(workLogTable);
    return _hydrate(rows);
  }

  /// All workouts created on the given date.
  Future<List<WorkLog>> getForDate(DateTime date) async {
    final formattedDate = Util.formatter.format(date);
    final db = await _db;
    final rows = await db.query(
      workLogTable,
      where: 'created = ?',
      whereArgs: [formattedDate],
    );
    return _hydrate(rows);
  }

  /// Workouts on [date] whose exercise targets [part] as a primary body part.
  Future<List<WorkLog>> getForDateAndBodyPart(
      DateTime date, BodyPart part) async {
    final all = await getForDate(date);
    final filtered = all
        .where((wl) => wl.exercise.bodyParts.contains(part))
        .toList(growable: false);
    logFine('[getForDateAndBodyPart] $part -> ${filtered.length}', name: _tag);
    return filtered;
  }

  Future<void> delete(WorkLog workLog) async {
    final db = await _db;
    await db.delete(workLogTable, where: 'id = ?', whereArgs: [workLog.id]);
    logFine('[delete] $workLog', name: _tag);
  }

  Future<List<WorkLog>> _hydrate(List<Map<String, Object?>> rows) async {
    final result = <WorkLog>[];
    for (final row in rows) {
      final exercise = await _exerciseDao.getById(row['exercise_id'].toString());
      result.add(WorkLog.fromMap(row, exercise));
    }
    return result;
  }
}
