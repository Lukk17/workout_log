import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/alarm/alarm_service.dart';

/// The underlying notifications plugin. Tests override this with an
/// in-memory fake; production gets the real singleton.
final flutterLocalNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>(
  (ref) => FlutterLocalNotificationsPlugin(),
);

final alarmServiceProvider = Provider<AlarmService>(
  (ref) => AlarmService(ref.watch(flutterLocalNotificationsProvider)),
);
