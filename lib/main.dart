import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_log/data/alarm/alarm_service.dart';
import 'package:workout_log/data/alarm/plugin_notification_gateway.dart';
import 'package:workout_log/presentation/app.dart';
import 'package:workout_log/presentation/providers/alarm_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Initialize the notification channel up front so the OS knows about
  // it before the first alarm fires. The permission prompt is deferred
  // until the user first arrives on the Timer page (less surprising).
  final notifications = FlutterLocalNotificationsPlugin();
  await AlarmService(PluginNotificationGateway(notifications)).initialize();

  runApp(
    ProviderScope(
      overrides: [
        flutterLocalNotificationsProvider.overrideWithValue(notifications),
      ],
      child: const MyApp(),
    ),
  );
}
