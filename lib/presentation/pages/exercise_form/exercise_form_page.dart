import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/db/exercise_dao.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_form/widgets/body_part_sections.dart';
import 'package:workout_log/presentation/pages/exercise_form/widgets/form_action_buttons.dart';
import 'package:workout_log/presentation/pages/exercise_form/widgets/name_field.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/system_chrome.dart';
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
            NameField(controller: _nameController, width: dims.width * 0.7),
            if (!dims.isPortrait) SizedBox(height: dims.height * 0.1),
            BodyPartSections(
              primary: _primaryBodyParts,
              secondary: _secondaryBodyParts,
              isPortrait: dims.isPortrait,
              onToggle: _toggleBodyPart,
            ),
            if (!dims.isPortrait) SizedBox(height: dims.height * 0.08),
            FormActionButtons(
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
    hideKeyboard(context);
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
      hideKeyboard(context);
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
