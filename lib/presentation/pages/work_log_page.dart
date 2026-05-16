import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/data/db/db_provider.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';
import 'package:workout_log/presentation/pages/exercise_form_page.dart';
import 'package:workout_log/presentation/pages/exercise_detail_page.dart';

/// Main WorkLog view — shows the selected date and its workouts.
class WorkLogPage extends ConsumerStatefulWidget {
  const WorkLogPage({super.key});

  @override
  ConsumerState<WorkLogPage> createState() => _WorkLogPageState();
}

class _WorkLogPageState extends ConsumerState<WorkLogPage> {
  final Logger _log = Logger('WorkLogPage');

  bool _isPortraitOrientation = false;
  double _screenHeight = 0;
  double _screenWidth = 0;

  double _datePortraitHeight = 0;
  double _dateLandscapeHeight = 0;
  double _dateTextScale = 0;
  double _cardMargin = 0;
  double _cardOutsideMargin = 0;
  EdgeInsets _seriesMargin = EdgeInsets.zero;
  EdgeInsets _repsMargin = EdgeInsets.zero;
  double _exerciseDialogHeight = 0;
  double _exerciseDialogWidth = 0;
  double _bottomEmptyContainerHeight = 0;

  DBProvider get _db => ref.read(dbProvider);

  void setupDimensions() {
    _screenHeight = Util.getScreenHeight(context);
    _screenWidth = Util.getScreenWidth(context);

    _datePortraitHeight = _screenHeight * 0.1;
    _dateLandscapeHeight = _screenHeight * 0.2;
    _dateTextScale = 3;
    _cardMargin = _screenHeight * 0.01;
    _cardOutsideMargin = _screenHeight * 0.01;
    _seriesMargin = EdgeInsets.only(
        right: _screenWidth * 0.02, bottom: _screenHeight * 0.01);
    _repsMargin = EdgeInsets.only(
        left: _screenWidth * 0.02, bottom: _screenHeight * 0.01);
    _exerciseDialogHeight = _screenHeight * 0.5;
    _exerciseDialogWidth = _screenWidth * 0.7;
    _bottomEmptyContainerHeight = _screenHeight * 0.15;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final workLogsAsync = ref.watch(workLogsForSelectedDateProvider);
    final colors = WorkoutColors.of(context);

    return OrientationBuilder(builder: (context, orientation) {
      _isPortraitOrientation = orientation == Orientation.portrait;
      setupDimensions();

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: _isPortraitOrientation
                ? _datePortraitHeight
                : _dateLandscapeHeight,
            alignment: const Alignment(0, 0),
            child: Text(
              Util.formatter.format(selectedDate) ==
                      Util.formatter.format(DateTime.now())
                  ? 'Today'
                  : Util.formatter.format(selectedDate),
              textScaler: TextScaler.linear(_dateTextScale),
              style: TextStyle(
                color: colors.textColor,
                fontWeight: FontWeight.bold,
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
                            .map((w) => _createWorkLogRowWidget(w, colors))
                            .toList(),
                      ),
                      SizedBox(height: _bottomEmptyContainerHeight),
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(height: _screenHeight * 0.3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FloatingActionButton(
                          tooltip: 'Add exercise',
                          onPressed: () => _showAddExerciseDialog(),
                          backgroundColor: colors.buttonColor,
                          foregroundColor: colors.secondaryColor,
                          child: Icon(Icons.add, color: colors.buttonTextColor),
                        ),
                        SizedBox(width: _screenWidth * 0.1),
                      ],
                    ),
                    SizedBox(height: _screenHeight * 0.01),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _createWorkLogRowWidget(WorkLog workLog, WorkoutColors colors) {
    return Container(
      margin: EdgeInsets.only(bottom: _cardOutsideMargin),
      child: Slidable(
        key: ValueKey(workLog.id),
        startActionPane: _slideActions(workLog),
        endActionPane: _slideActions(workLog),
        child: Card(
          color: colors.primaryColor,
          elevation: 8,
          child: ListTile(
            title: Container(
              margin: EdgeInsets.all(_cardMargin),
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
                  margin: _seriesMargin,
                  child: Text(
                    'Series: ${workLog.series.length}',
                    style: TextStyle(
                      fontSize: WorkoutTypography.fontSize,
                      color: colors.cardTextColor,
                    ),
                  ),
                ),
                Container(
                  margin: _repsMargin,
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
              margin: EdgeInsets.only(top: _screenHeight * 0.02),
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

  ActionPane _slideActions(WorkLog workLog) => ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          Container(
            margin: EdgeInsets.only(
                bottom: _screenHeight * 0.01, top: _screenHeight * 0.01),
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

  Future<void> _showAddExerciseDialog() async {
    final exercises = await _db.getAllExercise();
    if (!mounted) return;

    Util.blockOrientation(_isPortraitOrientation);

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
          Divider(color: WorkoutColors.of(context).borderColor),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    height: _exerciseDialogHeight,
                    width: _exerciseDialogWidth,
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
                      SizedBox(height: _screenHeight * 0.3),
                      const Icon(Icons.arrow_downward),
                    ],
                  )
                ],
              ),
              Divider(color: WorkoutColors.of(context).borderColor),
              SizedBox(
                height: _screenHeight * 0.1,
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
                                  )),
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
    final existing = await _db.getWorkLogsForDate(selectedDate);

    for (final w in existing) {
      if (w.exercise.name == fresh.name) {
        final merged = w.exercise.copyWith(
          bodyParts: {...w.exercise.bodyParts, ...fresh.bodyParts},
        );
        await _db.updateExercise(merged);
        _log.fine('Updated exercise bodyParts: $merged');
        _invalidateWorkLogs();
        return;
      }
    }

    final workLog = WorkLog.create(exercise: fresh).copyWith(
      created: selectedDate,
    );
    await _db.newWorkLog(workLog);
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
    await _db.deleteWorkLog(workLog);
    if (!mounted) return;
    _invalidateWorkLogs();
  }
}
