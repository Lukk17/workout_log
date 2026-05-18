import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/util/log.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Modal calendar shown from the home page app bar.
///
/// Interactions:
///   - Tap a day in the grid -> selects + dismisses.
///   - Tap the "May 2026" header -> opens the year-grid picker for
///     fast cross-year jumps. Picking a date there both selects and
///     dismisses; picking nothing returns to the grid unchanged.
///   - Tap "Today" -> jumps to and selects today, then dismisses.
///   - Tap "Close" -> dismiss without changing the date.
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
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TableCalendar(
              locale: 'en_US',
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focused,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
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
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) => InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _openYearPicker,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          DateFormat.yMMMM('en_US').format(day),
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              onDaySelected: _onDaySelected,
              onPageChanged: (focused) => setState(() => _focused = focused),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.today),
                  label: const Text('Today'),
                  onPressed: () => _pick(DateTime.now()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onDaySelected(DateTime day, DateTime focused) => _pick(day);

  void _pick(DateTime day) {
    final normalized = _startOfDay(day);
    ref.read(selectedDateProvider.notifier).state = normalized;
    logFine('Chosen date: $normalized', name: _tag);
    Navigator.of(context).pop();
  }

  Future<void> _openYearPicker() async {
    final navigator = Navigator.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _focused,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null || !mounted) return;
    final normalized = _startOfDay(picked);
    ref.read(selectedDateProvider.notifier).state = normalized;
    logFine('Chosen date (year picker): $normalized', name: _tag);
    navigator.pop();
  }
}
