import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:workout_log/presentation/theme/app_theme.dart';

/// Wraps a widget-under-test in `ProviderScope` (with optional [overrides])
/// and a minimal `MaterialApp` so `MediaQuery`, `Navigator`, `Theme.of`, and
/// `WorkoutColors.of` work during pumping.
Widget testApp({required Widget child, List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: child,
    ),
  );
}
