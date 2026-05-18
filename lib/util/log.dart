import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

// kDebugMode is const false in release, so the tree-shaker removes
// both the call and its argument expression — logFine is zero-cost in
// production builds.
void logFine(Object? message, {required String name}) {
  if (kDebugMode) developer.log('$message', name: name);
}

void logWarn(Object? message, {required String name, Object? error}) {
  developer.log(
    '$message',
    name: name,
    level: 900, // WARNING
    error: error,
  );
}
