import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/presentation/pages/timer/widgets/countdown_dial.dart';

import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('Renders MM:SS for sub-minute remaining', (tester) async {
    await tester.pumpWidget(testApp(
      child: const Scaffold(
        body: CountdownDial(
          remaining: Duration(seconds: 45),
          total: Duration(seconds: 60),
        ),
      ),
    ));

    expect(find.text('00:45'), findsOneWidget);
  });

  testWidgets('Pads single-digit minutes and seconds with zero', (tester) async {
    await tester.pumpWidget(testApp(
      child: const Scaffold(
        body: CountdownDial(
          remaining: Duration(minutes: 4, seconds: 5),
          total: Duration(minutes: 5),
        ),
      ),
    ));

    expect(find.text('04:05'), findsOneWidget);
  });

  testWidgets('Renders 00:00 at zero remaining without dividing by zero',
      (tester) async {
    await tester.pumpWidget(testApp(
      child: const Scaffold(
        body: CountdownDial(
          remaining: Duration.zero,
          total: Duration.zero,
        ),
      ),
    ));

    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('CircularProgressIndicator value equals remaining/total',
      (tester) async {
    await tester.pumpWidget(testApp(
      child: const Scaffold(
        body: CountdownDial(
          remaining: Duration(seconds: 30),
          total: Duration(seconds: 60),
        ),
      ),
    ));

    final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator));
    expect(indicator.value, 0.5);
  });
}
