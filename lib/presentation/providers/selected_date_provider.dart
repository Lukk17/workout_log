import 'package:flutter_riverpod/legacy.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

final selectedDateProvider = StateProvider<DateTime>(
  (ref) => _startOfDay(DateTime.now()),
);
