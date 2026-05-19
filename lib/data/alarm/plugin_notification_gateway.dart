import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workout_log/data/alarm/notification_gateway.dart';

class PluginNotificationGateway implements NotificationGateway {
  PluginNotificationGateway(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'rest_timer_alarm';
  static const _channelName = 'Rest timer alarm';
  static const _channelDescription = 'Plays when the rest timer reaches zero.';

  @override
  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: false,
      requestAlertPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    if (Platform.isAndroid) {
      // Android 8+ requires the channel up front so the alarm sound and
      // heads-up behavior survive the first show() call.
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true, badge: false);
      return granted ?? false;
    }
    return true;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: false,
      visibility: NotificationVisibility.public,
    );
    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);
}
