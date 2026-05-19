import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/presentation/pages/timer/widgets/custom_duration_dialog.dart';

import '../../../../helpers/test_app.dart';

Future<Duration?> _open(WidgetTester tester) async {
  Duration? result;
  await tester.pumpWidget(testApp(
    child: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () async {
              result = await showDialog<Duration>(
                context: context,
                builder: (_) => const CustomDurationDialog(),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  ));

  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();

  return result;
}

void main() {
  testWidgets('Defaults to 2 minutes / 0 seconds', (tester) async {
    await _open(tester);

    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Minutes'))
          .controller
          ?.text,
      '2',
    );
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Seconds'))
          .controller
          ?.text,
      '0',
    );
  });

  testWidgets('Set returns the parsed Duration', (tester) async {
    Duration? captured;
    await tester.pumpWidget(testApp(
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () async {
                captured = await showDialog<Duration>(
                  context: context,
                  builder: (_) => const CustomDurationDialog(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Minutes'), '4');
    await tester.enterText(find.widgetWithText(TextField, 'Seconds'), '15');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    expect(captured, const Duration(minutes: 4, seconds: 15));
  });

  testWidgets('Set returns null when both inputs are blank', (tester) async {
    Duration? captured;
    bool called = false;
    await tester.pumpWidget(testApp(
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () async {
                captured = await showDialog<Duration>(
                  context: context,
                  builder: (_) => const CustomDurationDialog(),
                );
                called = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Minutes'), '');
    await tester.enterText(find.widgetWithText(TextField, 'Seconds'), '');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(captured, isNull);
  });

  testWidgets('Cancel pops with null without parsing', (tester) async {
    Duration? captured;
    bool called = false;
    await tester.pumpWidget(testApp(
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () async {
                captured = await showDialog<Duration>(
                  context: context,
                  builder: (_) => const CustomDurationDialog(),
                );
                called = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Minutes'), '99');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(captured, isNull);
  });
}
