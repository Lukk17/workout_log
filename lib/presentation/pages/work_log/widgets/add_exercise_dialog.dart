import 'package:flutter/material.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/presentation/pages/exercise_form/exercise_form_page.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class AddExerciseDialog extends StatelessWidget {
  const AddExerciseDialog({
    super.key,
    required this.outerDims,
    required this.exercises,
    required this.onPickExercise,
  });

  final ResponsiveDimensions outerDims;
  final List<Exercise> exercises;
  final Future<void> Function(Exercise) onPickExercise;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return SimpleDialog(
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
                          await onPickExercise(e);
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
                ),
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
                          builder: (_) =>
                              const ExerciseFormPage(exercise: null),
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
    );
  }
}
