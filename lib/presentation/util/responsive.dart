import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class Util {
  static String pattern = "yyyy-MM-dd";
  static DateFormat formatter = DateFormat(pattern);

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static void blockOrientation(bool isPortraitOrientation) {
    if (isPortraitOrientation) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }

  static void unlockOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Color getBpColor(BodyPart bp, WorkoutColors colors) {
    switch (bp) {
      case BodyPart.chest:
        return colors.chestColor;
      case BodyPart.back:
        return colors.backColor;
      case BodyPart.leg:
        return colors.legColor;
      case BodyPart.arm:
        return colors.armColor;
      case BodyPart.cardio:
        return colors.cardioColor;
      case BodyPart.abdominal:
        return colors.abdominalColor;
      case BodyPart.undefined:
        return Colors.white70;
    }
  }

  static String getBpName(BodyPart bp) {
    switch (bp) {
      case BodyPart.chest:
        return "chest";

      case BodyPart.back:
        return "back";

      case BodyPart.leg:
        return "leg";

      case BodyPart.arm:
        return "arm";

      case BodyPart.cardio:
        return "cardio";

      case BodyPart.abdominal:
        return "abdominal";

      case BodyPart.undefined:
        return "";
    }
  }
}
