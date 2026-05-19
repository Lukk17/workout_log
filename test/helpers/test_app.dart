import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/theme/app_theme.dart';

import '../test_helper.dart';

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

/// Build a standalone [ProviderContainer] that uses the in-memory DAOs
/// from a [DaoTestEnv]. Use for notifier unit tests that don't need a
/// widget tree. Disposed automatically at the end of the test.
ProviderContainer riverpodContainer(DaoTestEnv env) {
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(env.appDatabase),
      exerciseDaoProvider.overrideWithValue(env.exerciseDao),
      workLogDaoProvider.overrideWithValue(env.workLogDao),
    ],
  );
  addTearDown(container.dispose);

  return container;
}
