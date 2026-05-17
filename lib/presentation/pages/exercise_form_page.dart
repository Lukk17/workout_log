import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/util/log.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class ExerciseFormPage extends ConsumerStatefulWidget {
  final Exercise? exercise;

  const ExerciseFormPage({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends ConsumerState<ExerciseFormPage> {
  static const _tag = 'ExerciseFormPage';

  final Set<BodyPart> _primaryBodyParts = <BodyPart>{};
  final Set<BodyPart> _secondaryBodyParts = <BodyPart>{};
  Map<String, bool> _valuesMap = <String, bool>{};
  bool _edit = false;

  late TextEditingController _myController;
  late GlobalKey<ScaffoldState> _key;

  WorkLogDao get _workLogDao => ref.read(workLogDaoProvider);
  ExerciseDao get _exerciseDao => ref.read(exerciseDaoProvider);

  Map<String, bool> setupValues() => {
        Util.getBpName(BodyPart.chest): false,
        Util.getBpName(BodyPart.leg): false,
        Util.getBpName(BodyPart.abdominal): false,
        Util.getBpName(BodyPart.arm): false,
        Util.getBpName(BodyPart.back): false,
        Util.getBpName(BodyPart.cardio): false,
      };

  void checkIfEdit() {
    if (widget.exercise != null) {
      _edit = true;
      for (BodyPart bp in widget.exercise!.bodyParts) {
        _updateBP(bp, true);
        _valuesMap[Util.getBpName(bp)] = true;
      }
      for (BodyPart bp in widget.exercise!.secondaryBodyParts) {
        _updateSecondaryBP(bp, true);
        _valuesMap[Util.getBpName(bp)] = true;
      }
      _myController = TextEditingController(text: widget.exercise?.name);
    } else {
      _myController = TextEditingController();
    }
  }

  @override
  void initState() {
    super.initState();
    _key = GlobalObjectKey<ScaffoldState>(17);
    _valuesMap = setupValues();
    checkIfEdit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return ResponsiveScaffold(
      scaffoldKey: _key,
      resizeToAvoidBottomInset: false,
      appBarBuilder: (context, dims) => PreferredSize(
        preferredSize: Size.fromHeight(dims.appBarHeight),
        child: AppBar(
          centerTitle: true,
          title: Text(
            'Add Exercises',
            style: TextStyle(
              color: colors.titleColor,
              fontSize: WorkoutTypography.fontSize,
            ),
          ),
          backgroundColor: colors.appBarColor,
        ),
      ),
      body: Builder(builder: (context) {
        final dims = ResponsiveDimensions.of(context);
        return Column(
          mainAxisAlignment: dims.isPortrait
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
          children: <Widget>[
            Column(children: <Widget>[
              SizedBox(
                width: dims.width * 0.7,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: _myController,
                  style:
                      const TextStyle(fontSize: WorkoutTypography.headerSize),
                ),
              ),
            ]),
            if (!dims.isPortrait) SizedBox(height: dims.height * 0.1),
            dims.isPortrait
                ? Column(children: _bodyPartSections())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _bodyPartSections(),
                  ),
            if (!dims.isPortrait) SizedBox(height: dims.height * 0.08),
            dims.isPortrait
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _getControlButtons(colors, dims),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _getControlButtons(colors, dims),
                  )
          ],
        );
      }),
    );
  }

  List<Widget> _bodyPartSections() => [
        Column(
          children: <Widget>[
            const Text('Main Body Parts:'),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildBodyPartCheckboxes(secondary: false),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            const Text('Secondary Body Parts:'),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildBodyPartCheckboxes(secondary: true),
            ),
          ],
        ),
      ];

  List<Widget> _getControlButtons(
      WorkoutColors colors, ResponsiveDimensions dims) {
    final List<Widget> result = <Widget>[];

    final buttonHeight = dims.height * (dims.isPortrait ? 0.06 : 0.1);
    final buttonWidth = dims.width * (dims.isPortrait ? 0.5 : 0.27);

    result.add(
      MaterialButton(
        onPressed: _saveExercise,
        height: buttonHeight,
        minWidth: buttonWidth,
        color: colors.greenButtonColor,
        splashColor: colors.buttonSplashColor,
        textColor: colors.buttonTextColor,
        child: const Text('SAVE'),
      ),
    );

    if (dims.isPortrait) {
      result.add(SizedBox(height: dims.height * 0.05));
    } else {
      result.add(SizedBox(width: dims.width * 0.1));
    }
    result.add(
      MaterialButton(
        onPressed: () {
          Util.hideKeyboard(context);
          Navigator.pop(context);
        },
        height: buttonHeight,
        minWidth: buttonWidth,
        color: colors.cancelButtonColor,
        splashColor: colors.buttonSplashColor,
        textColor: colors.buttonTextColor,
        child: const Text('Cancel'),
      ),
    );

    return result;
  }

  void _updateBP(BodyPart bodyPart, bool value) {
    if (value) {
      _primaryBodyParts.add(bodyPart);
      _secondaryBodyParts.remove(bodyPart);
    } else {
      _primaryBodyParts.remove(bodyPart);
    }
  }

  void _updateSecondaryBP(BodyPart bodyPart, bool value) {
    if (value) {
      _secondaryBodyParts.add(bodyPart);
      _primaryBodyParts.remove(bodyPart);
    } else {
      _secondaryBodyParts.remove(bodyPart);
    }
  }

  Widget _getWidgetForBP(BodyPart bp, {bool secondary = false}) {
    final String name = Util.getBpName(bp);
    final colors = WorkoutColors.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: <Widget>[
        Text(name, style: TextStyle(color: colors.textColor)),
        Checkbox(
          value: _valuesMap[name],
          onChanged: (value) {
            setState(() {
              _valuesMap[name] = value!;
              if (secondary) {
                _updateSecondaryBP(bp, value);
              } else {
                _updateBP(bp, value);
              }
            });
          },
        ),
      ],
    );
  }

  /// Build the list of checkbox rows for one side of the form
  /// (primary or secondary). The opposite side's selections are excluded
  /// so each body part appears in exactly one list at a time.
  List<Widget> _buildBodyPartCheckboxes({required bool secondary}) {
    final excludeSet = secondary ? _primaryBodyParts : _secondaryBodyParts;
    final tempList = <Widget>[];
    for (final bp in BodyPart.values) {
      if (bp == BodyPart.undefined) continue;
      if (!excludeSet.contains(bp)) {
        tempList.add(_getWidgetForBP(bp, secondary: secondary));
      }
    }

    // Wrap handles arbitrary counts and wraps to a second row automatically,
    // replacing the previous hand-rolled split-at-3 logic. Avoids horizontal
    // overflow on narrow screens.
    return [
      Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 8,
        runSpacing: 4,
        children: tempList,
      ),
    ];
  }

  Future<void> _saveExercise() async {
    if (_myController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You forgot about exercise name :)')),
      );
      return;
    }

    if (_primaryBodyParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You forgot about exercise body part :)')),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final selectedDate = ref.read(selectedDateProvider);

    if (_edit) {
      final updated = widget.exercise!.copyWith(
        name: _myController.text,
        bodyParts: _primaryBodyParts,
        secondaryBodyParts: _secondaryBodyParts,
      );
      await _exerciseDao.replace(updated);
      logFine("Updating exercise: $updated", name: _tag);

      if (!mounted) return;
      Util.hideKeyboard(context);
      ref.invalidate(exercisesProvider);
      ref.invalidate(workLogsByDateProvider(selectedDate));
      navigator.popUntil(ModalRoute.withName(Navigator.defaultRouteName));
    } else {
      await _addWorkLog(
        Exercise.create(
          name: _myController.text,
          bodyParts: _primaryBodyParts,
          secondaryBodyParts: _secondaryBodyParts,
        ),
        selectedDate,
      );
      if (!mounted) return;
      FocusScope.of(context).requestFocus(FocusNode());
      ref.invalidate(exercisesProvider);
      ref.invalidate(workLogsByDateProvider(selectedDate));
      navigator.pop();
    }
  }

  Future<WorkLog> _addWorkLog(Exercise exercise, DateTime selectedDate) async {
    final workLogList = await _workLogDao.getForDate(selectedDate);
    for (final w in workLogList) {
      if (w.exercise.name == exercise.name) {
        final merged = w.exercise.copyWith(
          bodyParts: {...w.exercise.bodyParts, ...exercise.bodyParts},
        );
        await _exerciseDao.mergeBodyParts(merged);
        logFine("Worklog updated $merged", name: _tag);
        return w.copyWith(exercise: merged);
      }
    }
    final workLog =
        WorkLog.create(exercise: exercise, on: selectedDate);
    await _workLogDao.insert(workLog);
    logFine("New workLog saved to DB: $workLog", name: _tag);
    return workLog;
  }
}
