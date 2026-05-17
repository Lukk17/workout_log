import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_log/presentation/app.dart';

void main() async {
  // logFine / logWarn (lib/util/log.dart) wrap dart:developer.log directly —
  // no global Logger.root configuration needed. DevTools shows the log
  // stream live; on Android `developer.log` is bridged to logcat.
  await initializeDateFormatting();
  runApp(const ProviderScope(child: MyApp()));
}
