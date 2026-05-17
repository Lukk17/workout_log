import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/backup/backup_service.dart';
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';

/// Opens the sqflite database and runs schema migrations. Tests override
/// this provider with a [AppDatabase] pointed at a temp path.
final databaseFactoryProvider =
    Provider<AppDatabase>((ref) => AppDatabase());

final exerciseDaoProvider = Provider<ExerciseDao>(
  (ref) => ExerciseDao(ref.watch(databaseFactoryProvider)),
);

final workLogDaoProvider = Provider<WorkLogDao>(
  (ref) => WorkLogDao(
    ref.watch(databaseFactoryProvider),
    ref.watch(exerciseDaoProvider),
  ),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(workLogDaoProvider)),
);

/// All workouts logged on the currently selected date.
final workLogsByDateProvider =
    FutureProvider.family<List<WorkLog>, DateTime>((ref, date) {
  return ref.watch(workLogDaoProvider).getForDate(date);
});

/// Workouts for whatever date the user has selected. Watches both the date
/// and the underlying DAO.
final workLogsForSelectedDateProvider = FutureProvider<List<WorkLog>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(workLogsByDateProvider(date).future);
});

/// Full exercise catalog.
final exercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseDaoProvider).getAll();
});
