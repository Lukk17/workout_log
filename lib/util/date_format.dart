import 'package:intl/intl.dart';

/// The canonical date format the app persists into SQLite and renders in
/// "today vs other day" labels. Lives in `lib/util/` so domain + data
/// layers can use it without depending on the presentation layer.
const String dateFormatPattern = 'yyyy-MM-dd';
final DateFormat dateFormatter = DateFormat(dateFormatPattern);
