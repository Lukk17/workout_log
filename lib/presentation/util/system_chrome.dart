import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void blockOrientation({required bool portrait}) {
  SystemChrome.setPreferredOrientations(portrait
      ? const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
      : const [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
}

void unlockOrientation() {
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
