import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/appBuilder.dart';
import 'package:workout_log/util/notification.dart';
import 'package:workout_log/util/timerService.dart';
import 'package:workout_log/view/helloWorldView.dart';

void main() async {
  /// get shared preferences, if never set, set to default values
  /// if already set, save that values as app values
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("isDark") == null) {
    prefs.setBool("isDark", AppThemeSettings.theme == AppThemeSettings.themeD);
  } else if (prefs.getBool("isDark") == true) {
    AppThemeSettings.theme = AppThemeSettings.themeD;
  } else {
    AppThemeSettings.theme = AppThemeSettings.themeL;
  }
//  await AndroidAlarmManager.initialize();

  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static TimerService timerService = TimerService();
  static NotificationService notificationService;
  static GlobalKey<ScaffoldState> globalKey;

  static const String _TITLE = "Private WorkoutLog";

  @override
  Widget build(BuildContext context) {
    return AppBuilder(builder: (context) {
      notificationService = NotificationService(context);
      return MaterialApp(
        title: 'Private WorkoutLog',
        theme: AppThemeSettings.theme,
        home: HelloWorldView(
          title: _TITLE,
          callback: (widget) => {},
        ),
      );
    });
  }
}
