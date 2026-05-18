import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

// `useMaterial3: true` is the default in Flutter 3.16+ but stated
// explicitly here so future Flutter upgrades don't silently change us.
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFAED581), // matches WorkoutColors.dark.specialTextColor
    brightness: Brightness.dark,
  ),
  extensions: const <ThemeExtension<dynamic>>[WorkoutColors.dark],
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // matches WorkoutColors.light.primaryColor
    brightness: Brightness.light,
  ),
  extensions: const <ThemeExtension<dynamic>>[WorkoutColors.light],
);
