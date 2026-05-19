import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workout_log/data/backup/backup_service.dart';
import 'package:workout_log/data/db/app_database.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';

Future<String> _productionDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return join(dir.path, 'worklog.db');
}

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase(_productionDatabasePath()),
);

final exerciseDaoProvider = Provider<ExerciseDao>(
  (ref) => ExerciseDao(ref.watch(appDatabaseProvider)),
);

final workLogDaoProvider = Provider<WorkLogDao>(
  (ref) => WorkLogDao(
    ref.watch(appDatabaseProvider),
    ref.watch(exerciseDaoProvider),
  ),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(workLogDaoProvider)),
);

final workLogsByDateProvider = FutureProvider.family<List<WorkLog>, DateTime>((
  ref,
  date,
) {
  return ref.watch(workLogDaoProvider).getForDate(date);
});

final workLogsForSelectedDateProvider = FutureProvider<List<WorkLog>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(workLogsByDateProvider(date).future);
});

final exercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseDaoProvider).getAll();
});
