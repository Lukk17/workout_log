import 'package:flutter_riverpod/legacy.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// The user's currently selected date for the workout log view. Normalized
/// to start-of-day in device-local time so DB queries that filter on the
/// YYYY-MM-DD `created` column match cleanly.
final selectedDateProvider =
    StateProvider<DateTime>((ref) => _startOfDay(DateTime.now()));
