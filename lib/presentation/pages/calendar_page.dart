import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/util/log.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Modal calendar shown from the home page app bar. Tap a day to select
/// and dismiss — no Save button, no "Go to today" button (the calendar
/// header already exposes both interactions natively).
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  static const _tag = 'CalendarPage';

  late DateTime _focused;

  @override
  void initState() {
    super.initState();
    _focused = ref.read(selectedDateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedDateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          locale: 'en_US',
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          focusedDay: _focused,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          selectedDayPredicate: (day) => isSameDay(selected, day),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: _onDaySelected,
          onPageChanged: (focused) => _focused = focused,
        ),
      ),
    );
  }

  void _onDaySelected(DateTime day, DateTime focused) {
    final normalized = _startOfDay(day);
    ref.read(selectedDateProvider.notifier).state = normalized;
    logFine('Chosen date: $normalized', name: _tag);
    Navigator.of(context).pop();
  }
}
