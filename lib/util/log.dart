import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only log. The `kDebugMode` guard is a `const false` in release,
/// so the tree-shaker removes both the call and the argument expression
/// from production builds — these are zero-cost in release.
void logFine(Object? message, {required String name}) {
  if (kDebugMode) developer.log('$message', name: name);
}

/// Always logged. Use for genuinely user-visible problems (failed restore,
/// dropped DB inserts) — these reach DevTools / logcat in every build.
void logWarn(Object? message, {required String name, Object? error}) {
  developer.log(
    '$message',
    name: name,
    level: 900, // WARNING
    error: error,
  );
}
