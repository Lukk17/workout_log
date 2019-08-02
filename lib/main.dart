import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/appBuilder.dart';
import 'package:workout_log/util/notification.dart';
import 'package:workout_log/util/timerService.dart';
import 'package:workout_log/view/helloWorldView.dart';

void main() async {
  //  await AndroidAlarmManager.initialize();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static TimerService timerService = TimerService();
  static NotificationService notificationService;
  static GlobalKey<ScaffoldState> globalKey;
  static const String TITLE = "Private WorkoutLog";

  @override
  Widget build(BuildContext context) {
    /// setup logger
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: \t ${rec.time}: ===================================== > \t ${rec.loggerName}: \t ${rec.message}');
    });
    final Logger _log = new Logger("Application");
    _log.fine("started");

    return AppBuilder(builder: (context) {
      notificationService = NotificationService(context);

      return MaterialApp(
        title: TITLE,
        theme: AppThemeSettings.theme,
        home: HelloWorldView(
          callback: (widget) => {},
        ),
      );
    });
  }
}
