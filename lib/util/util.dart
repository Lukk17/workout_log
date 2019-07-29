import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:workout_log/setting/appThemeSettings.dart';

class Util {
  static bool rebuild = false;


  static TextEditingController _textController = TextEditingController();

  static TextEditingController textController() {
    _textController.clear();
    return _textController;
  }

  static String pattern = "yyyy-MM-dd";
  static DateFormat formatter = new DateFormat(pattern);

  static Widget addHorizontalLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppThemeSettings.borderColor),
        ),
      ),
    );
  }

  static Widget addVerticalLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppThemeSettings.borderColor),
        ),
      ),
    );
  }

  static Widget spacer(double size) {
    return Container(margin: EdgeInsets.all(size));
  }

  static Widget spacerSelectable({double top, double bottom, double left, double right}) {
    if (top == null) top = 0;
    if (bottom == null) bottom = 0;
    if (left == null) left = 0;
    if (right == null) right = 0;
    return Container(margin: EdgeInsets.fromLTRB(left, top, right, bottom));
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  ///  block orientation change
  static blockOrientation(bool _isPortraitOrientation) {
    if (_isPortraitOrientation) {
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

  /// restore orientation ability to change
  static unlockOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
