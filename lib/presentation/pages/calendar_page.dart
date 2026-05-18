import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/util/log.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Modal calendar shown from the home page app bar.
///
/// Three ways to pick:
///   - Tap a day in the grid — selects + dismisses immediately.
///   - "Today" chip — jumps to today and dismisses.
///   - "Pick date…" chip — opens Material 3 `showDatePicker` which lets
///     you tap the year header to jump distant months/years quickly.
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
              onDaySelected: _onDaySelected,
              onPageChanged: (focused) => setState(() => _focused = focused),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.today),
                  label: const Text('Today'),
                  onPressed: () => _pick(DateTime.now()),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Pick date…'),
                  onPressed: _openMaterialDatePicker,
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

  Future<void> _openMaterialDatePicker() async {
    final navigator = Navigator.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(selectedDateProvider),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      // Open in year-grid view so a jump of years is one tap, not 24
      // chevron clicks.
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null || !mounted) return;
    final normalized = _startOfDay(picked);
    ref.read(selectedDateProvider.notifier).state = normalized;
    logFine('Chosen date (year picker): $normalized', name: _tag);
    navigator.pop();
  }
}
