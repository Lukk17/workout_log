import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class CountdownDial extends StatelessWidget {
  const CountdownDial({
    super.key,
    required this.remaining,
    required this.total,
  });

  final Duration remaining;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final workoutColors = WorkoutColors.of(context);
    final progress = total.inMilliseconds == 0
        ? 0.0
        : remaining.inMilliseconds / total.inMilliseconds;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              color: workoutColors.arcColor,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          Text(
            _format(remaining),
            style: textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  static String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
