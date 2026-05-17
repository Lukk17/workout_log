import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/presentation/app.dart';

void main() async {
  // Verbose only in debug; release builds drop to warnings to keep logcat clean.
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint(
        '${rec.level.name}: \t ${rec.time}: ===================================== > \t ${rec.loggerName}: \t ${rec.message}');
  });

  await initializeDateFormatting();
  runApp(const ProviderScope(child: MyApp()));
}
