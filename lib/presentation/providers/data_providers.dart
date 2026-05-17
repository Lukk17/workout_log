import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/db/db_provider.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';

/// Singleton DAO. Wrapped in a provider so widget tests can override with a
/// fake/in-memory DB factory.
final dbProvider = Provider<DBProvider>((ref) => DBProvider.instance);

/// All workouts logged on the currently selected date.
final workLogsByDateProvider =
    FutureProvider.family<List<WorkLog>, DateTime>((ref, date) {
  return ref.watch(dbProvider).getWorkLogsForDate(date);
});

/// Workouts for whatever date the user has selected. Watches both the date
/// and the underlying DAO.
final workLogsForSelectedDateProvider = FutureProvider<List<WorkLog>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(workLogsByDateProvider(date).future);
});

/// Full exercise catalog.
final exercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(dbProvider).getAllExercise();
});
