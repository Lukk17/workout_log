import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:workout_log/util/log.dart';

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
  late TextEditingController _nameController;

  bool get _isEdit => widget.exercise != null;
  WorkLogDao get _workLogDao => ref.read(workLogDaoProvider);
  ExerciseDao get _exerciseDao => ref.read(exerciseDaoProvider);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    if (widget.exercise != null) {
      _primaryBodyParts.addAll(widget.exercise!.bodyParts);
      _secondaryBodyParts.addAll(widget.exercise!.secondaryBodyParts);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleBodyPart(BodyPart bp, {required bool secondary, required bool value}) {
    setState(() {
      if (secondary) {
        if (value) {
          _secondaryBodyParts.add(bp);
          _primaryBodyParts.remove(bp);
        } else {
          _secondaryBodyParts.remove(bp);
        }
      } else {
        if (value) {
          _primaryBodyParts.add(bp);
          _secondaryBodyParts.remove(bp);
        } else {
          _primaryBodyParts.remove(bp);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return ResponsiveScaffold(
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
            _NameField(controller: _nameController, width: dims.width * 0.7),
            if (!dims.isPortrait) SizedBox(height: dims.height * 0.1),
            _BodyPartSections(
              primary: _primaryBodyParts,
              secondary: _secondaryBodyParts,
              isPortrait: dims.isPortrait,
              onToggle: _toggleBodyPart,
            ),
            if (!dims.isPortrait) SizedBox(height: dims.height * 0.08),
            _FormActionButtons(
              dims: dims,
              onSave: _saveExercise,
              onCancel: _cancel,
            ),
          ],
        );
      }),
    );
  }

  void _cancel() {
    Util.hideKeyboard(context);
    Navigator.pop(context);
  }

  Future<void> _saveExercise() async {
    if (_nameController.text.isEmpty) {
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

    if (_isEdit) {
      final updated = widget.exercise!.copyWith(
        name: _nameController.text,
        bodyParts: _primaryBodyParts,
        secondaryBodyParts: _secondaryBodyParts,
      );
      await _exerciseDao.replace(updated);
      logFine('Updating exercise: $updated', name: _tag);
      if (!mounted) return;
      Util.hideKeyboard(context);
      ref.invalidate(exercisesProvider);
      ref.invalidate(workLogsByDateProvider(selectedDate));
      navigator.popUntil(ModalRoute.withName(Navigator.defaultRouteName));
    } else {
      await _addWorkLog(
        Exercise.create(
          name: _nameController.text,
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
        logFine('Worklog updated $merged', name: _tag);
        return w.copyWith(exercise: merged);
      }
    }
    final workLog = WorkLog.create(exercise: exercise, on: selectedDate);
    await _workLogDao.insert(workLog);
    logFine('New workLog saved to DB: $workLog', name: _tag);
    return workLog;
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.width});

  final TextEditingController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        textAlign: TextAlign.center,
        controller: controller,
        style: const TextStyle(fontSize: WorkoutTypography.headerSize),
      ),
    );
  }
}

class _BodyPartSections extends StatelessWidget {
  const _BodyPartSections({
    required this.primary,
    required this.secondary,
    required this.isPortrait,
    required this.onToggle,
  });

  final Set<BodyPart> primary;
  final Set<BodyPart> secondary;
  final bool isPortrait;
  final void Function(BodyPart, {required bool secondary, required bool value})
      onToggle;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _BodyPartColumn(
        title: 'Main Body Parts:',
        selected: primary,
        excluded: secondary,
        onToggle: (bp, value) => onToggle(bp, secondary: false, value: value),
      ),
      _BodyPartColumn(
        title: 'Secondary Body Parts:',
        selected: secondary,
        excluded: primary,
        onToggle: (bp, value) => onToggle(bp, secondary: true, value: value),
      ),
    ];
    return isPortrait
        ? Column(children: sections)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: sections,
          );
  }
}

class _BodyPartColumn extends StatelessWidget {
  const _BodyPartColumn({
    required this.title,
    required this.selected,
    required this.excluded,
    required this.onToggle,
  });

  final String title;
  final Set<BodyPart> selected;
  final Set<BodyPart> excluded;
  final void Function(BodyPart bp, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final checkboxes = <Widget>[];
    for (final bp in BodyPart.values) {
      if (bp == BodyPart.undefined) continue;
      if (excluded.contains(bp)) continue;
      final name = Util.getBpName(bp);
      checkboxes.add(Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: <Widget>[
          Text(name, style: TextStyle(color: colors.textColor)),
          Checkbox(
            value: selected.contains(bp),
            onChanged: (value) => onToggle(bp, value ?? false),
          ),
        ],
      ));
    }
    return Column(
      children: <Widget>[
        Text(title),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 8,
          runSpacing: 4,
          children: checkboxes,
        ),
      ],
    );
  }
}

class _FormActionButtons extends StatelessWidget {
  const _FormActionButtons({
    required this.dims,
    required this.onSave,
    required this.onCancel,
  });

  final ResponsiveDimensions dims;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final buttonHeight = dims.height * (dims.isPortrait ? 0.06 : 0.1);
    final buttonWidth = dims.width * (dims.isPortrait ? 0.5 : 0.27);
    final saveButton = MaterialButton(
      onPressed: onSave,
      height: buttonHeight,
      minWidth: buttonWidth,
      color: colors.greenButtonColor,
      splashColor: colors.buttonSplashColor,
      textColor: colors.buttonTextColor,
      child: const Text('SAVE'),
    );
    final cancelButton = MaterialButton(
      onPressed: onCancel,
      height: buttonHeight,
      minWidth: buttonWidth,
      color: colors.cancelButtonColor,
      splashColor: colors.buttonSplashColor,
      textColor: colors.buttonTextColor,
      child: const Text('Cancel'),
    );
    final spacer = dims.isPortrait
        ? SizedBox(height: dims.height * 0.05)
        : SizedBox(width: dims.width * 0.1);
    final children = <Widget>[saveButton, spacer, cancelButton];

    return dims.isPortrait
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center, children: children)
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }
}
