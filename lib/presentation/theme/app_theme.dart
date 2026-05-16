import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  extensions: const <ThemeExtension<dynamic>>[WorkoutColors.dark],
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  extensions: const <ThemeExtension<dynamic>>[WorkoutColors.light],
);
