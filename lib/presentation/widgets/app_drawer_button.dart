import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

/// Distinguished from Flutter Material's built-in `DrawerButton`
/// (the hamburger icon that opens a Scaffold drawer). This one is a
/// rectangular MaterialButton meant for the *contents* of a drawer.
class AppDrawerButton extends StatelessWidget {
  const AppDrawerButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return MaterialButton(
      color: colors.buttonColor,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: colors.buttonTextColor,
          fontSize: WorkoutTypography.fontSize,
        ),
      ),
    );
  }
}
