import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/util/log.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Page-local state: which month is currently focused in the calendar
/// header. autoDispose so two consecutive openings don't carry state
/// across.
final _focusedDayProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  static const _tag = 'CalendarPage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider);
    final focused = ref.watch(_focusedDayProvider) ?? selected;
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
              focusedDay: focused,
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
                  onTap: () => _openYearPicker(context, ref, focused),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
              onDaySelected: (day, _) => _pick(context, ref, day),
              onPageChanged: (next) =>
                  ref.read(_focusedDayProvider.notifier).state = next,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.today),
                  label: const Text('Today'),
                  onPressed: () => _pick(context, ref, DateTime.now()),
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

  void _pick(BuildContext context, WidgetRef ref, DateTime day) {
    final normalized = _startOfDay(day);
    ref.read(selectedDateProvider.notifier).state = normalized;
    logFine('Chosen date: $normalized', name: _tag);
    Navigator.of(context).pop();
  }

  Future<void> _openYearPicker(
    BuildContext context,
    WidgetRef ref,
    DateTime focused,
  ) async {
    final navigator = Navigator.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: focused,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null || !context.mounted) {
      return;
    }

    final normalized = _startOfDay(picked);
    ref.read(selectedDateProvider.notifier).state = normalized;
    logFine('Chosen date (year picker): $normalized', name: _tag);
    navigator.pop();
  }
}
