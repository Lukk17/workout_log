import 'package:flutter/material.dart';

class AppThemeSettings {
  static ThemeData theme = themeD;

  static ThemeData _themeD = ThemeData(brightness: Brightness.dark);

  static ThemeData _themeL = ThemeData(brightness: Brightness.light);

  static ThemeData get themeD {
    buttonColor = Colors.red;
    buttonSplashColor = Colors.lightGreen;
    appBarColor = Colors.grey[900]!;
    tabBarColor = Colors.amber;
    timerColor = Colors.cyanAccent;
    buttonTextColor = Colors.grey[800]!;
    cardTextColor = Colors.amber;
    textColor = Colors.amber;
    specialTextColor = Colors.lightGreen[300]!;
    primaryColor = Colors.lightGreen[800]!;
    secondaryColor = Colors.white;
    iconColor = Colors.amber;
    tabBarIconColor = Colors.amber;
    titleColor = Colors.amber;
    backgroundColor = Colors.black;
    indicatorColor = Colors.red;
    borderColor = Colors.red;
    drawerColor = Colors.grey[800]!;

    background = "graphics/background.jpg";

    return _themeD;
  }

  static ThemeData get themeL {
    buttonColor = Colors.blue;
    buttonSplashColor = Colors.deepPurpleAccent;
    appBarColor = Colors.blue;
    tabBarColor = Colors.black87;
    timerColor = Colors.amberAccent;
    buttonTextColor = Colors.white;
    cardTextColor = Colors.white;
    textColor = Colors.black87;
    specialTextColor = Colors.black87;
    primaryColor = Colors.blue;
    secondaryColor = Colors.white;
    iconColor = Colors.white;
    tabBarIconColor = Colors.black87;
    titleColor = Colors.white;
    backgroundColor = Colors.white;
    indicatorColor = Colors.blue;
    borderColor = Colors.blue;
    drawerColor = Colors.blue[100]!;

    background = "graphics/lightBackground.jpg";

    return _themeL;
  }

  static Color buttonColor = Colors.red;
  static Color buttonSplashColor = Colors.lightGreen;
  static Color appBarColor = Colors.grey[900]!;
  static Color tabBarColor = Colors.amber;
  static Color timerColor = Colors.cyanAccent;
  static Color buttonTextColor = Colors.grey[800]!;
  static Color cardTextColor = Colors.amber;
  static Color textColor = Colors.amber;
  static Color specialTextColor = Colors.lightGreen[300]!;
  static Color primaryColor = Colors.lightGreen[800]!;
  static Color secondaryColor = Colors.white;
  static Color iconColor = Colors.amber;
  static Color tabBarIconColor = Colors.amber;
  static Color titleColor = Colors.amber;
  static Color backgroundColor = Colors.black;
  static Color indicatorColor = Colors.red;
  static Color borderColor = Colors.red;
  static Color drawerColor = Colors.grey[800]!;

  static Color chestColor = Colors.red;
  static Color backColor = Colors.white;
  static Color armColor = Colors.deepPurple;
  static Color legColor = Colors.green;
  static Color abdominalColor = Colors.indigo;
  static Color cardioColor = Colors.black;

  static Color circleColor = Colors.blueAccent;
  static Color arcColor = Colors.red;

  static Color shadowColor = Colors.black;

  static Color greenButtonColor = Colors.green;
  static Color cancelButtonColor = Colors.red;
  static Color nextButton = Colors.red;
  static Color previousButton = Colors.red;
  static Color timerCircleColor = Colors.blue;
  static Color specialButtonColor = Colors.red;

  static double fontSize = 20;
  static double headerSize = 30;
  static double buttonFontSize = 20;
  static double bodyPartFontSize = 20;

  static double tableHeaderBorderWidth = 5;
  static double tableCellBorderWidth = 3;
  static double timerCircleWidth = 15;

  static StrokeCap strokeCap = StrokeCap.round;
  static PaintingStyle paintingStyle = PaintingStyle.stroke;

  static String background = "";

  static List<Shadow> textBorder = [
    Shadow(
        // bottomLeft
        offset: Offset(-2, -2),
        color: shadowColor),
    Shadow(
        // bottomRight
        offset: Offset(2, -2),
        color: shadowColor),
    Shadow(
        // topRight
        offset: Offset(2, 2),
        color: shadowColor),
    Shadow(
        // topLeft
        offset: Offset(-2, 2),
        color: shadowColor),
  ];
}
