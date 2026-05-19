import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_log/presentation/app.dart';
import 'package:workout_log/presentation/providers/alarm_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Build the container ourselves so the bootstrap initialize() call
  // runs against the very same AlarmService instance the running app
  // will use — no override gymnastics to share the plugin singleton.
  final container = ProviderContainer();
  // Initialize the notification channel up front so the OS knows about
  // it before the first alarm fires. Permission is requested lazily
  // the first time the user lands on the Timer page.
  await container.read(alarmServiceProvider).initialize();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}
