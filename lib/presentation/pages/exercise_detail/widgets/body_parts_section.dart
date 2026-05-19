import 'package:flutter/material.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/body_part_blocks.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class BodyPartsSection extends StatelessWidget {
  const BodyPartsSection({
    super.key,
    required this.workLog,
    required this.layout,
  });

  final WorkLog workLog;
  final DetailTableLayout layout;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return Column(
      children: <Widget>[
        Text(
          'Primary',
          style: TextStyle(
            color: colors.titleColor,
            fontSize: layout.isPortrait
                ? layout.titleFontSizePortrait
                : layout.titleFontSizeLandscape,
          ),
        ),
        SizedBox(height: layout.screenHeight * 0.01),
        BodyPartBlocks(parts: workLog.exercise.bodyParts, layout: layout),
        SizedBox(height: layout.screenHeight * 0.02),
        const Text('Secondary'),
        SizedBox(height: layout.screenHeight * 0.01),
        BodyPartBlocks(
            parts: workLog.exercise.secondaryBodyParts, layout: layout),
      ],
    );
  }
}
