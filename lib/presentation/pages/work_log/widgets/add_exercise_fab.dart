import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class AddExerciseFab extends StatelessWidget {
  const AddExerciseFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(height: dims.height * 0.3),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              tooltip: 'Add exercise',
              onPressed: onPressed,
              backgroundColor: colors.buttonColor,
              foregroundColor: colors.secondaryColor,
              child: Icon(Icons.add, color: colors.buttonTextColor),
            ),
            SizedBox(width: dims.width * 0.1),
          ],
        ),
        SizedBox(height: dims.height * 0.01),
      ],
    );
  }
}
