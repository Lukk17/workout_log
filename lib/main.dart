import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/setting/appTheme.dart';
import 'package:workout_log/util/appBuilder.dart';
import 'package:workout_log/view/helloWorldView.dart';

void main() async {
  /// get shared preferences, if never set, set to default values
  /// if already set, save that values as app values
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('prefs main before ${prefs.getBool("isDark")}');
  if (prefs.getBool("isDark") == null) {
    prefs.setBool("isDark", AppThemeSettings.theme == AppThemeSettings.themeD);
  } else if (prefs.getBool("isDark") == true) {
    AppThemeSettings.theme = AppThemeSettings.themeD;
  } else {
    AppThemeSettings.theme = AppThemeSettings.themeL;
  }

  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static const String _TITLE = "It is your time !";

  @override
  Widget build(BuildContext context) {
    //  Lock to portrait orientation
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.portraitUp,
//      DeviceOrientation.portraitDown,
//    ]);

    return AppBuilder(builder: (context) {
      return MaterialApp(
        title: 'Private WorkLog',
        theme: AppThemeSettings.theme,
        home: HelloWorldView(
          title: _TITLE,
          callback: (widget) => {},
        ),
      );
    });
  }
}
