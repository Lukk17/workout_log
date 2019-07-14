import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  BuildContext context;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String _channelID = "1";
  String _channelName = "noti";
  String _channelDescription = "notification";
  String _ticker = "ticker";

  NotificationService(this.context);

  init() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  // fire when a notification has been tapped on
  Future onSelectNotification(String payload) async {
    //  pop to default app view
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              //  pop to default app view
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            },
          )
        ],
      ),
    );
  }

  Future<void> display(
      {@required String title, @required String body, String payload}) async {
    if (payload == null) {
      payload = "default";
    }

    await flutterLocalNotificationsPlugin
        .show(0, title, body, _getPlatformSpecifics(), payload: payload);
  }

  Future<void> scheduleNotification() async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 5));

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        _getPlatformSpecifics());
  }

  NotificationDetails _getPlatformSpecifics() {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        _channelID, _channelName, _channelDescription,
        importance: Importance.Max, priority: Priority.High, ticker: _ticker);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    return NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }
}
