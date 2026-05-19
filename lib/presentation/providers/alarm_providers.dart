import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/alarm/alarm_service.dart';
import 'package:workout_log/data/alarm/notification_gateway.dart';
import 'package:workout_log/data/alarm/plugin_notification_gateway.dart';

// Private now: nothing outside this file should reach for the raw
// plugin. main.dart drives initialization through the container, not
// by overriding this provider.
final _flutterLocalNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>(
      (ref) => FlutterLocalNotificationsPlugin(),
    );

final notificationGatewayProvider = Provider<NotificationGateway>(
  (ref) =>
      PluginNotificationGateway(ref.watch(_flutterLocalNotificationsProvider)),
);

final alarmServiceProvider = Provider<AlarmService>(
  (ref) => AlarmService(ref.watch(notificationGatewayProvider)),
);
