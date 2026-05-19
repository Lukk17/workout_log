import 'package:sqflite/sqflite.dart';
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/util/date_format.dart';
import 'package:workout_log/util/log.dart';

class WorkLogDao {
  WorkLogDao(this._appDatabase, this._exerciseDao);

  final AppDatabase _appDatabase;
  final ExerciseDao _exerciseDao;
  static const _tag = 'WorkLogDao';

  Future<Database> get _db => _appDatabase.database;

  Future<int> insert(WorkLog workLog) async {
    final db = await _db;
    final existing = await _exerciseDao.findByName(workLog.exercise.name);

    if (existing != null) {
      // Same exercise name -> reuse the row, merging any new body parts
      // so the catalogue stays deduplicated by name.
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

      final toInsert = workLog.copyWith(exercise: resolvedExercise);

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

    if (rows.isEmpty) {
      return null;
    }

    final exercise =
        await _exerciseDao.getById(rows.first['exercise_id'].toString());

    return WorkLog.fromMap(rows.first, exercise);
  }

  Future<List<WorkLog>> getAll() async {
    final db = await _db;
    return _hydrate(await db.query(workLogTable));
  }

  Future<List<WorkLog>> getForDate(DateTime date) async {
    final db = await _db;
    return _hydrate(await db.query(
      workLogTable,
      where: 'created = ?',
      whereArgs: [dateFormatter.format(date)],
    ));
  }

  Future<List<WorkLog>> getForDateAndBodyPart(DateTime date,
      BodyPart part) async {
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
    if (rows.isEmpty) {
      return const [];
    }

    final exerciseIds =
        rows.map((r) => r['exercise_id'].toString()).toSet().toList();
    // Batch-resolve every referenced exercise in one query instead of
    // issuing N round-trips (was visibly slow with day pages that have
    // many entries against many distinct exercises).
    final exercises = await _exerciseDao.findByIds(exerciseIds);
    return rows
        .map((row) =>
        WorkLog.fromMap(row, exercises[row['exercise_id'].toString()]!))
        .toList();
  }
}
