import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';
import 'package:workout_log/presentation/theme/app_theme.dart';
import 'package:workout_log/view/helloWorldView.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint(
        '${rec.level.name}: \t ${rec.time}: ===================================== > \t ${rec.loggerName}: \t ${rec.message}');
  });

  await initializeDateFormatting();
  runApp(const ProviderScope(child: MyApp()));
}

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
      home: HelloWorldView(callback: (widget) => {}),
    );
  }
}
