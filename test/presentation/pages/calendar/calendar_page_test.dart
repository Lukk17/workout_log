import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_log/presentation/pages/calendar/calendar_page.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';

import '../../../helpers/test_app.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(() async {
    // CalendarPage formats months with the 'en_US' locale; without
    // initialization DateFormat throws on first format() call.
    await initializeDateFormatting('en_US');
  });

  testWidgets('Renders TableCalendar with Close + Today actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp(child: const CalendarPage()));
    await _settle(tester);

    expect(find.byType(TableCalendar), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets(
    '"Today" button writes today\'s start-of-day to selectedDateProvider',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      late ProviderContainer container;
      await tester.pumpWidget(
        testApp(
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return const CalendarPage();
            },
          ),
        ),
      );
      await _settle(tester);

      // Pre-seed selectedDateProvider to a value we know is not "today" so
      // the assertion is meaningful even when the test happens to run at
      // midnight.
      container.read(selectedDateProvider.notifier).state = DateTime(
        2020,
        1,
        1,
      );

      await tester.tap(find.text('Today'));
      await _settle(tester);

      final picked = container.read(selectedDateProvider);
      final now = DateTime.now();
      expect(picked.year, now.year);
      expect(picked.month, now.month);
      expect(picked.day, now.day);
      expect(picked.hour, 0, reason: 'normalized to start-of-day');
      expect(picked.minute, 0);
    },
  );

  testWidgets(
    'Close button pops the dialog without changing the selected date',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      late ProviderContainer container;
      await tester.pumpWidget(
        testApp(
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return Scaffold(
                body: Builder(
                  builder: (context) {
                    return Center(
                      child: FilledButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => const CalendarPage(),
                        ),
                        child: const Text('Open'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await _settle(tester);

      final pinned = DateTime(2025, 3, 14);
      container.read(selectedDateProvider.notifier).state = pinned;

      await tester.tap(find.text('Open'));
      await _settle(tester);
      expect(find.byType(CalendarPage), findsOneWidget);

      await tester.tap(find.text('Close'));
      await _settle(tester);

      expect(find.byType(CalendarPage), findsNothing);
      expect(container.read(selectedDateProvider), pinned);
    },
  );
}
