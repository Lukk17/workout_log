import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail/exercise_detail_page.dart';
import 'package:workout_log/presentation/pages/work_log/widgets/add_exercise_dialog.dart';
import 'package:workout_log/presentation/pages/work_log/widgets/add_exercise_fab.dart';
import 'package:workout_log/presentation/pages/work_log/widgets/date_header.dart';
import 'package:workout_log/presentation/pages/work_log/widgets/work_log_card.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';
import 'package:workout_log/util/log.dart';

class WorkLogPage extends ConsumerStatefulWidget {
  const WorkLogPage({super.key});

  @override
  ConsumerState<WorkLogPage> createState() => _WorkLogPageState();
}

class _WorkLogPageState extends ConsumerState<WorkLogPage> {
  static const _tag = 'WorkLogPage';

  WorkLogDao get _workLogDao => ref.read(workLogDaoProvider);
  ExerciseDao get _exerciseDao => ref.read(exerciseDaoProvider);

  @override
  Widget build(BuildContext context) {
    // No Scaffold wrap: this page is rendered inside HomePage's
    // ResponsiveScaffold-backed body, so dims are already in context.
    final workLogsAsync = ref.watch(workLogsForSelectedDateProvider);
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        const DateHeader(),
        Expanded(
          child: Stack(
            children: <Widget>[
              workLogsAsync.when(
                data: (workLogs) => ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Column(
                      children: workLogs
                          .map((w) => WorkLogCard(
                                workLog: w,
                                onDelete: () => _deleteWorkLog(w),
                                onTap: () => _openDetail(w),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: dims.height * 0.15),
                  ],
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load workouts: $e',
                    style: TextStyle(color: colors.textColor),
                  ),
                ),
              ),
              AddExerciseFab(onPressed: _openAddExerciseDialog),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openDetail(WorkLog workLog) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ExerciseDetailPage(workLog: workLog)),
    );
    if (!mounted) return;
    _invalidateWorkLogs();
  }

  Future<void> _openAddExerciseDialog() async {
    final dims = ResponsiveDimensions.of(context);
    final exercises = await _exerciseDao.getAll();
    if (!mounted) return;

    Util.blockOrientation(dims.isPortrait);

    await showDialog<void>(
      context: context,
      builder: (_) => AddExerciseDialog(
        outerDims: dims,
        exercises: exercises,
        onPickExercise: _addWorkLogFor,
      ),
    );

    if (!mounted) return;
    Util.unlockOrientation();
    _invalidateWorkLogs();
  }

  Future<void> _addWorkLogFor(Exercise template) async {
    final selectedDate = ref.read(selectedDateProvider);
    final fresh = Exercise.create(
      name: template.name,
      bodyParts: template.bodyParts,
    );
    final existing = await _workLogDao.getForDate(selectedDate);

    for (final w in existing) {
      if (w.exercise.name == fresh.name) {
        final merged = w.exercise.copyWith(
          bodyParts: {...w.exercise.bodyParts, ...fresh.bodyParts},
        );
        await _exerciseDao.mergeBodyParts(merged);
        logFine('Updated exercise bodyParts: $merged', name: _tag);
        _invalidateWorkLogs();
        return;
      }
    }

    final workLog = WorkLog.create(exercise: fresh, on: selectedDate);
    await _workLogDao.insert(workLog);
    logFine('Added new workLog: $workLog', name: _tag);
    _invalidateWorkLogs();
  }

  void _invalidateWorkLogs() {
    final date = ref.read(selectedDateProvider);
    ref.invalidate(workLogsByDateProvider(date));
  }

  Future<void> _deleteWorkLog(WorkLog workLog) async {
    logFine('Deleted workLog: $workLog', name: _tag);
    await _workLogDao.delete(workLog);
    if (!mounted) return;
    _invalidateWorkLogs();
  }
}
