import 'package:flutter/material.dart';

class AppThemeSettings {
  static ThemeData theme = ThemeData(brightness: Brightness.dark);

  static ThemeData _themeD = ThemeData(brightness: Brightness.dark);

  static ThemeData _themeL = ThemeData(brightness: Brightness.light);

  static ThemeData get themeD {
    buttonColor = Colors.redAccent;
    buttonSplashColor = Colors.lightGreen;
    iconColor = Colors.black;
    appBarColor = Colors.redAccent;
    tabBarColor = Colors.white;
    timerColor = Colors.white;
    buttonTextColor = Colors.white;
    textColor = Colors.white;
    specialTextColor = Colors.amber;
    primaryColor = Colors.red;
    secondaryColor = Colors.white;
    calendarIconColor = Colors.white;
    titleColor = Colors.white;
    backgroundColor = Colors.black;
    indicatorColor = Colors.red;
    borderColor = Colors.red;
    drawerColor = Colors.grey[800];

    background = "graphics/background.png";
    workLogBackground = "graphics/bg-cosmos.png";

    return _themeD;
  }

  static ThemeData get themeL {
    buttonColor = Colors.blue;
    buttonSplashColor = Colors.deepPurpleAccent;
    iconColor = Colors.black;
    appBarColor = Colors.blue;
    tabBarColor = Colors.black;
    timerColor = Colors.white;
    buttonTextColor = Colors.white;
    textColor = Colors.black;
    specialTextColor = Colors.black;
    primaryColor = Colors.blue;
    secondaryColor = Colors.white;
    calendarIconColor = Colors.white;
    titleColor = Colors.white;
    backgroundColor = Colors.white;
    indicatorColor = Colors.blue;
    borderColor = Colors.blue;
    drawerColor = Colors.blueAccent[100];

    background = "graphics/lightBackground.png";
    workLogBackground = "graphics/bg-niagara.png";

    return _themeL;
  }

  static Color buttonColor = Colors.red;
  static Color buttonSplashColor = Colors.red;
  static Color iconColor = Colors.white;
  static Color appBarColor = Colors.red;
  static Color tabBarColor = Colors.white;
  static Color timerColor = Colors.white;
  static Color buttonTextColor = Colors.white;
  static Color textColor = Colors.white;
  static Color specialTextColor = Colors.amber;
  static Color primaryColor = Colors.red;
  static Color secondaryColor = Colors.white;
  static Color calendarIconColor = Colors.white;
  static Color titleColor = Colors.white;
  static Color backgroundColor = Colors.black;
  static Color indicatorColor = Colors.red;
  static Color borderColor = Colors.red;
  static Color drawerColor = Colors.black38;

  static Color greenButtonColor = Colors.green;
  static Color cancelButtonColor = Colors.red;
  static Color nextButton = Colors.red;
  static Color previousButton = Colors.red;
  static Color timerCircleColor = Colors.blue;
  static Color specialButtonColor = Colors.red;

  static double fontSize = 20;
  static double headerSize = 40;
  static double buttonFontSize = 20;
  static double bodyPartFontSize = 20;

  static double tableHeaderBorderWidth = 5;
  static double tableCellBorderWidth = 3;
  static double timerCircleWidth = 5;

  static StrokeCap strokeCap = StrokeCap.round;
  static PaintingStyle paintingStyle = PaintingStyle.fill;

  static String background = "graphics/background.png";
  static String timerBackground = "graphics/bg-leaves.png";
  static String workLogBackground = "graphics/bg-cosmos.png";
}
