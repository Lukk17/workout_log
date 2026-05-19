import 'package:flutter/material.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class ExerciseNameHeader extends StatelessWidget {
  const ExerciseNameHeader({
    super.key,
    required this.workLog,
    required this.layout,
    required this.onEdit,
  });

  final WorkLog workLog;
  final DetailTableLayout layout;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return GestureDetector(
      onLongPress: onEdit,
      child: Container(
        height: layout.isPortrait
            ? layout.exerciseHeightPortrait
            : layout.exerciseHeightLandscape,
        width: layout.exerciseWidth,
        alignment: const FractionalOffset(0.5, 0.5),
        child: Text(
          workLog.exercise.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textColor,
            fontSize: WorkoutTypography.headerSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
