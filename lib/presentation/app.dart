import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/pages/home/home_page.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';
import 'package:workout_log/presentation/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static const String title = 'Private WorkoutLog';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: title,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: mode,
      home: HomePage(callback: (widget) => {}),
    );
  }
}
