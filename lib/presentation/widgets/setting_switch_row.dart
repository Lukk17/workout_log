import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class SettingSwitchRow extends StatelessWidget {
  const SettingSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: colors.textColor,
              fontSize: WorkoutTypography.fontSize,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
