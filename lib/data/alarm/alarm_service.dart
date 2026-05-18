import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workout_log/util/log.dart';

/// Thin wrapper around `flutter_local_notifications` for the rest-timer
/// alarm. The notification's own sound channel doubles as the "loud
/// alarm" sound — fires whether the app is foregrounded, backgrounded,
/// or the screen is locked.
class AlarmService {
  AlarmService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static const _tag = 'AlarmService';
  static const _channelId = 'rest_timer_alarm';
  static const _channelName = 'Rest timer alarm';
  static const _notificationId = 1001;

  /// Call once at app startup, before runApp. Idempotent.
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

    // Android 8+ needs the channel created up front for sound + heads-up
    // behavior to be applied.
    if (Platform.isAndroid) {
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

  /// Ask the user for permission to post notifications. Android 13+ and
  /// every iOS version need this; older Android grants it implicitly.
  /// Returns true if granted (or already granted).
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

  /// Fire the alarm notification — heads-up, with the channel's default
  /// alarm sound. Safe to call repeatedly; the same notification ID is
  /// reused so the OS replaces an existing one rather than stacking.
  Future<void> ring() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Plays when the rest timer reaches zero.',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      enableVibration: true,
      // Heads-up display even when app is foregrounded.
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

  /// Dismiss the alarm notification (called when the user hits "Stop"
  /// in the in-app dialog).
  Future<void> cancel() async {
    await _plugin.cancel(_notificationId);
  }
}
