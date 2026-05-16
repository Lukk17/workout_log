import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/data/db/db_provider.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/util/util.dart';

class ExerciseManipulationView extends ConsumerStatefulWidget {
  final Exercise? exercise;

  const ExerciseManipulationView({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseManipulationView> createState() => _ExerciseManipulationView();
}

class _ExerciseManipulationView extends ConsumerState<ExerciseManipulationView> {
  final Logger _log = Logger("ExerciseManipulationView");

  final Set<BodyPart> _primaryBodyParts = <BodyPart>{};
  List<Widget> _primaryBodyPartsList = <Widget>[];
  final Set<BodyPart> _secondaryBodyParts = <BodyPart>{};
  List<Widget> _secondaryBodyPartsList = <Widget>[];
  Map<String, bool> _valuesMap = <String, bool>{};
  bool _edit = false;

  late TextEditingController _myController;
  late GlobalKey<ScaffoldState> _key;

  DBProvider get _db => ref.read(dbProvider);

  late double _screenHeight;
  late double _screenWidth;
  late bool _isPortraitOrientation;

  late double _appBarHeightPortrait;
  late double _appBarHeightLandscape;
  late double _textFieldWidth;
  late double _buttonHeightPortrait;
  late double _buttonHeightLandscape;
  late double _buttonWidthPortrait;
  late double _buttonWidthLandscape;

  void setupDimensions() {
    _screenHeight = Util.getScreenHeight(context);
    _screenWidth = Util.getScreenWidth(context);

    _appBarHeightPortrait = _screenHeight * 0.08;
    _appBarHeightLandscape = _screenHeight * 0.1;
    _textFieldWidth = _screenWidth * 0.7;
    _buttonHeightPortrait = _screenHeight * 0.06;
    _buttonHeightLandscape = _screenHeight * 0.1;
    _buttonWidthPortrait = _screenWidth * 0.5;
    _buttonWidthLandscape = _screenWidth * 0.27;
  }

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
    _rebuildBodyPartLists();
  }

  void _rebuildBodyPartLists() {
    _primaryBodyPartsList = _buildBodyPartCheckboxes(secondary: false);
    _secondaryBodyPartsList = _buildBodyPartCheckboxes(secondary: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return OrientationBuilder(builder: (context, orientation) {
      _isPortraitOrientation = orientation == Orientation.portrait;
      setupDimensions();

      return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(_isPortraitOrientation ? _appBarHeightPortrait : _appBarHeightLandscape),
          child: AppBar(
              centerTitle: true,
              title: Text(
                'Add Exercises',
                style: TextStyle(
                  color: colors.titleColor,
                  fontSize: WorkoutTypography.fontSize,
                ),
              ),
              backgroundColor: colors.appBarColor),
        ),
        body: Column(
          mainAxisAlignment: _isPortraitOrientation ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
          children: <Widget>[
            Column(children: <Widget>[
              SizedBox(
                width: _textFieldWidth,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: _myController,
                  style: const TextStyle(fontSize: WorkoutTypography.headerSize),
                ),
              ),
            ]),
            if (!_isPortraitOrientation)
              SizedBox(height: _screenHeight * 0.1),
            _isPortraitOrientation
                ? Column(children: _bodyPartSections())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _bodyPartSections(),
                  ),
            if (!_isPortraitOrientation)
              SizedBox(height: _screenHeight * 0.08),
            _isPortraitOrientation
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _getControlButtons(colors),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _getControlButtons(colors),
                  )
          ],
        ),
      );
    });
  }

  List<Widget> _bodyPartSections() => [
        Column(
          children: <Widget>[
            const Text('Main Body Parts:'),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _primaryBodyPartsList,
            ),
          ],
        ),
        Column(
          children: <Widget>[
            const Text('Secodary Body Parts:'),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _secondaryBodyPartsList,
            ),
          ],
        ),
      ];

  List<Widget> _getControlButtons(WorkoutColors colors) {
    final List<Widget> result = <Widget>[];

    result.add(
      MaterialButton(
        onPressed: _saveExercise,
        height: _isPortraitOrientation ? _buttonHeightPortrait : _buttonHeightLandscape,
        minWidth: _isPortraitOrientation ? _buttonWidthPortrait : _buttonWidthLandscape,
        color: colors.greenButtonColor,
        splashColor: colors.buttonSplashColor,
        textColor: colors.buttonTextColor,
        child: const Text('SAVE'),
      ),
    );

    if (_isPortraitOrientation) {
      result.add(SizedBox(height: _screenHeight * 0.05));
    } else {
      result.add(SizedBox(width: _screenWidth * 0.1));
    }
    result.add(
      MaterialButton(
        onPressed: () {
          Util.hideKeyboard(context);
          Navigator.pop(context);
        },
        height: _isPortraitOrientation ? _buttonHeightPortrait : _buttonHeightLandscape,
        minWidth: _isPortraitOrientation ? _buttonWidthPortrait : _buttonWidthLandscape,
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
              _rebuildBodyPartLists();
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

    if (tempList.length > 3) {
      return [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tempList.take(3).toList()),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tempList.skip(3).toList()),
      ];
    }
    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: tempList),
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
      await _db.editExercise(updated);
      _log.fine("Updating exercise: $updated");

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
    final workLogList = await _db.getWorkLogsForDate(selectedDate);
    for (final w in workLogList) {
      if (w.exercise.name == exercise.name) {
        final merged = w.exercise.copyWith(
          bodyParts: {...w.exercise.bodyParts, ...exercise.bodyParts},
        );
        await _db.updateExercise(merged);
        _log.fine("Worklog updated $merged");
        return w.copyWith(exercise: merged);
      }
    }
    final workLog =
        WorkLog.create(exercise: exercise).copyWith(created: selectedDate);
    await _db.newWorkLog(workLog);
    _log.fine("New workLog saved to DB: $workLog");
    return workLog;
  }
}
