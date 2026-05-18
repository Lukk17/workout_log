import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/presentation/pages/timer_page.dart';

import '../helpers/test_app.dart';

// The real FlutterLocalNotificationsPlugin is fine on the test surface:
// requestPermissions short-circuits (no Android/iOS binding present) and
// the test never reaches countdown-zero so ring() isn't called.

Future<void> _useTallSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap() => testApp(child: const Scaffold(body: TimerPage()));

  // Returns the widget's [Text] descendants flattened to a list of
  // displayed strings. find.text() doesn't traverse the subtree inside
  // a selected Material 3 ChoiceChip; walking the element tree by hand
  // finds the label regardless.
  Iterable<String> allText(WidgetTester tester) sync* {
    for (final el in tester.allWidgets) {
      if (el is Text && el.data != null) yield el.data!;
    }
  }

  testWidgets('Renders default 60s preset selected (01:00)', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('Picking a long preset (3 min) updates the countdown',
      (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('3 min'));
    await tester.pumpAndSettle();

    expect(find.text('03:00'), findsOneWidget);
  });

  testWidgets('Start button flips to Pause while running', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('Custom chip opens the custom-duration dialog', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    expect(find.text('Custom duration'), findsOneWidget);
    expect(find.text('Minutes'), findsOneWidget);
    expect(find.text('Seconds'), findsOneWidget);
  });

  testWidgets('All six preset labels are present in the widget tree',
      (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final texts = allText(tester).toSet();
    for (final label in ['30s', '60s', '90s', '2 min', '3 min', '5 min']) {
      expect(texts, contains(label), reason: 'missing $label');
    }
  });
}
