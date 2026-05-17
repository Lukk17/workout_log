import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail_page.dart';
import 'package:workout_log/presentation/pages/exercise_form_page.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

/// Main WorkLog view — shows the selected date and its workouts.
class WorkLogPage extends ConsumerStatefulWidget {
  const WorkLogPage({super.key});

  @override
  ConsumerState<WorkLogPage> createState() => _WorkLogPageState();
}

class _WorkLogPageState extends ConsumerState<WorkLogPage> {
  final Logger _log = Logger('WorkLogPage');

  WorkLogDao get _workLogDao => ref.read(workLogDaoProvider);
  ExerciseDao get _exerciseDao => ref.read(exerciseDaoProvider);

  @override
  Widget build(BuildContext context) {
    // WorkLogPage is rendered inside HomePage's TabBarView body, so it has
    // a ResponsiveScaffold ancestor already and we can read dimensions
    // directly. No Scaffold wrap needed here.
    final selectedDate = ref.watch(selectedDateProvider);
    final workLogsAsync = ref.watch(workLogsForSelectedDateProvider);
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          height: dims.height * (dims.isPortrait ? 0.1 : 0.2),
          child: Center(
            child: Text(
              Util.formatter.format(selectedDate) ==
                      Util.formatter.format(DateTime.now())
                  ? 'Today'
                  : Util.formatter.format(selectedDate),
              textScaler: const TextScaler.linear(3),
              style: TextStyle(
                color: colors.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              workLogsAsync.when(
                data: (workLogs) => ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Column(
                      children: workLogs
                          .map((w) => _createWorkLogRowWidget(w, colors, dims))
                          .toList(),
                    ),
                    SizedBox(height: dims.height * 0.15),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load workouts: $e',
                    style: TextStyle(color: colors.textColor),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: dims.height * 0.3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FloatingActionButton(
                        tooltip: 'Add exercise',
                        onPressed: () => _showAddExerciseDialog(dims),
                        backgroundColor: colors.buttonColor,
                        foregroundColor: colors.secondaryColor,
                        child: Icon(Icons.add, color: colors.buttonTextColor),
                      ),
                      SizedBox(width: dims.width * 0.1),
                    ],
                  ),
                  SizedBox(height: dims.height * 0.01),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _createWorkLogRowWidget(
      WorkLog workLog, WorkoutColors colors, ResponsiveDimensions dims) {
    final cardMargin = dims.height * 0.01;
    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      child: Slidable(
        key: ValueKey(workLog.id),
        startActionPane: _slideActions(workLog, dims),
        endActionPane: _slideActions(workLog, dims),
        child: Card(
          color: colors.primaryColor,
          elevation: 8,
          child: ListTile(
            title: Container(
              margin: EdgeInsets.all(cardMargin),
              child: Text(
                workLog.exercise.name,
                style: TextStyle(
                  fontSize: WorkoutTypography.fontSize,
                  color: colors.cardTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      right: dims.width * 0.02, bottom: dims.height * 0.01),
                  child: Text(
                    'Series: ${workLog.series.length}',
                    style: TextStyle(
                      fontSize: WorkoutTypography.fontSize,
                      color: colors.cardTextColor,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: dims.width * 0.02, bottom: dims.height * 0.01),
                  child: Text(
                    'Reps: ${workLog.getRepsSum()}',
                    style: TextStyle(
                      fontSize: WorkoutTypography.fontSize,
                      color: colors.cardTextColor,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            leading: Column(children: _getMainBodyParts(workLog, colors)),
            trailing: Container(
              margin: EdgeInsets.only(top: dims.height * 0.02),
              child: Icon(Icons.arrow_forward, color: colors.secondaryColor),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(workLog: workLog)),
              );
              if (!mounted) return;
              _invalidateWorkLogs();
            },
          ),
        ),
      ),
    );
  }

  ActionPane _slideActions(WorkLog workLog, ResponsiveDimensions dims) =>
      ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          Container(
            margin: EdgeInsets.only(
                bottom: dims.height * 0.01, top: dims.height * 0.01),
            child: SlidableAction(
              onPressed: (context) => _deleteWorkLog(workLog),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ),
        ],
      );

  Future<void> _showAddExerciseDialog(ResponsiveDimensions outerDims) async {
    final exercises = await _exerciseDao.getAll();
    if (!mounted) return;

    Util.blockOrientation(outerDims.isPortrait);

    final colors = WorkoutColors.of(context);

    await showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(
          'Select exercise',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textColor),
        ),
        children: <Widget>[
          Divider(color: colors.borderColor),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    height: outerDims.height * 0.5,
                    width: outerDims.width * 0.7,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final e = exercises[index];
                        return MaterialButton(
                          onPressed: () async {
                            await _addWorkLogFor(e);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                          child: Text(
                            e.name,
                            style: TextStyle(color: colors.specialTextColor),
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      const Icon(Icons.arrow_upward),
                      SizedBox(height: outerDims.height * 0.3),
                      const Icon(Icons.arrow_downward),
                    ],
                  )
                ],
              ),
              Divider(color: colors.borderColor),
              SizedBox(
                height: outerDims.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                      color: colors.greenButtonColor,
                      onPressed: () async {
                        Util.unlockOrientation();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExerciseFormPage(
                              exercise: null,
                            ),
                          ),
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      child: Text(
                        'New',
                        style: TextStyle(color: colors.buttonTextColor),
                      ),
                    ),
                    MaterialButton(
                      color: colors.cancelButtonColor,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: colors.buttonTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
        _log.fine('Updated exercise bodyParts: $merged');
        _invalidateWorkLogs();
        return;
      }
    }

    final workLog = WorkLog.create(exercise: fresh, on: selectedDate);
    await _workLogDao.insert(workLog);
    _log.fine('Added new workLog: $workLog');
    _invalidateWorkLogs();
  }

  List<Widget> _getMainBodyParts(WorkLog workLog, WorkoutColors colors) {
    final parts = [
      ...workLog.exercise.bodyParts,
      ...workLog.exercise.secondaryBodyParts,
    ].take(3);
    return parts
        .map((bp) => Text(
              Util.getBpName(bp),
              style: TextStyle(color: Util.getBpColor(bp, colors)),
            ))
        .toList();
  }

  void _invalidateWorkLogs() {
    final date = ref.read(selectedDateProvider);
    ref.invalidate(workLogsByDateProvider(date));
  }

  Future<void> _deleteWorkLog(WorkLog workLog) async {
    _log.fine('Deleted workLog: $workLog');
    await _workLogDao.delete(workLog);
    if (!mounted) return;
    _invalidateWorkLogs();
  }
}
