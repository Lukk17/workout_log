import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/alarm/alarm_service.dart';

final flutterLocalNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>(
  (ref) => FlutterLocalNotificationsPlugin(),
);

final alarmServiceProvider = Provider<AlarmService>(
  (ref) => AlarmService(ref.watch(flutterLocalNotificationsProvider)),
);
