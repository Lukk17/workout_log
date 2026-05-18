import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workout_log/util/log.dart';

class AlarmService {
  AlarmService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static const _tag = 'AlarmService';
  static const _channelId = 'rest_timer_alarm';
  static const _channelName = 'Rest timer alarm';
  static const _notificationId = 1001;

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
      // Android 8+ needs the channel created up front for sound + heads-up
      // behavior to apply.
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Plays when the rest timer reaches zero.',
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

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      logFine('Android notification permission: $granted', name: _tag);
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        sound: true,
        badge: false,
      );
      logFine('iOS notification permission: $granted', name: _tag);
      return granted ?? false;
    }
    return true;
  }

  Future<void> ring() async {
    // Reusing the same _notificationId means the OS replaces any prior
    // alarm notification instead of stacking them.
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Plays when the rest timer reaches zero.',
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
      _notificationId,
      'Rest over',
      'Time to lift.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
    logFine('alarm fired', name: _tag);
  }

  Future<void> cancel() async {
    await _plugin.cancel(_notificationId);
  }
}
