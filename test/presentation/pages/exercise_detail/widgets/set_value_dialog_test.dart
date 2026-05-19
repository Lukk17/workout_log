import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/set_value_dialog.dart';

import '../../../../helpers/test_app.dart';

Future<String?> _openDialog(WidgetTester tester) async {
  String? captured;
  await tester.pumpWidget(testApp(
    child: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () async {
              captured = await showDialog<String>(
                context: context,
                builder: (_) => const SetValueDialog(
                  title: 'Edit load value',
                  hint: '60',
                  isPortrait: true,
                  screenHeight: 1200,
                ),
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

  return captured;
}

void main() {
  testWidgets('Renders title + SAVE/CANCEL buttons', (tester) async {
    await _openDialog(tester);

    expect(find.text('Edit load value'), findsOneWidget);
    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
  });

  testWidgets('SAVE with valid numeric input returns the normalized string',
      (tester) async {
    String? result;
    await tester.pumpWidget(testApp(
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => const SetValueDialog(
                    title: 'Edit load value',
                    hint: '60',
                    isPortrait: true,
                    screenHeight: 1200,
                  ),
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
    await tester.enterText(find.byType(TextField), '0085');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    // int.parse('0085').toString() canonicalises to '85'.
    expect(result, '85');
  });

  testWidgets('CANCEL pops without returning a value', (tester) async {
    String? result;
    bool called = false;
    await tester.pumpWidget(testApp(
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => const SetValueDialog(
                    title: 'Edit load value',
                    hint: '60',
                    isPortrait: true,
                    screenHeight: 1200,
                  ),
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
    await tester.enterText(find.byType(TextField), '85');
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(result, isNull);
  });

  testWidgets('SAVE with non-numeric input throws (handled by caller)',
      (tester) async {
    // The dialog deliberately uses int.parse and lets the exception
    // bubble up so the caller can decide whether to surface it. The
    // test pins the contract.
    await tester.pumpWidget(testApp(
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (_) => const SetValueDialog(
                  title: 'Edit load value',
                  hint: '60',
                  isPortrait: true,
                  screenHeight: 1200,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('SAVE'));
    await tester.pump();

    expect(tester.takeException(), isA<FormatException>());
  });
}
