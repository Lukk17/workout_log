import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/data/alarm/alarm_service.dart';
import 'package:workout_log/data/alarm/notification_gateway.dart';
import 'package:workout_log/presentation/pages/timer/timer_page.dart';
import 'package:workout_log/presentation/providers/alarm_providers.dart';
import 'package:workout_log/presentation/providers/timer_preset_provider.dart';

import '../../../helpers/test_app.dart';

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

  testWidgets('Hydrates from a persisted preset on first build (180s -> 03:00)',
      (tester) async {
    // Persisted value differs from the in-memory default (60s) so we
    // know the hydration path ran instead of just rendering the default.
    SharedPreferences.setMockInitialValues({'timer_preset_seconds': 180});
    await _useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('03:00'), findsOneWidget);
  });

  testWidgets('Custom duration dialog with blank input returns null (no change)',
      (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    // Clear both fields and confirm. parse fails -> 0 + 0 = 0 -> the
    // dialog returns null and _pickPreset is never invoked.
    final minutesField = find.widgetWithText(TextField, 'Minutes');
    final secondsField = find.widgetWithText(TextField, 'Seconds');
    await tester.enterText(minutesField, '');
    await tester.enterText(secondsField, '');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    // Dial still shows the default 01:00, dialog dismissed.
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Custom duration'), findsNothing);
  });

  testWidgets('Custom duration dialog with valid input updates the dial',
      (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Minutes'), '4');
    await tester.enterText(
        find.widgetWithText(TextField, 'Seconds'), '15');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    expect(find.text('04:15'), findsOneWidget);
  });

  testWidgets('Countdown reaching zero fires the alarm and shows Rest over',
      (tester) async {
    final gateway = _FakeGateway();
    await _useTallSurface(tester);
    await tester.pumpWidget(testApp(
      child: const Scaffold(body: TimerPage()),
      overrides: [
        notificationGatewayProvider.overrideWithValue(gateway),
        alarmServiceProvider.overrideWithValue(AlarmService(gateway)),
      ],
    ));
    await tester.pumpAndSettle();

    // Pick the shortest preset (30s) then advance the fake clock past
    // its expiry. We pump in 1s slices to match the ticker cadence.
    await tester.tap(find.text('30s'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    for (var i = 0; i < 32; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();

    expect(find.text('Rest over'), findsOneWidget);
    expect(gateway.shown, hasLength(1));
    expect(gateway.shown.single.title, 'Rest over');

    // Dismiss the alarm dialog -> ring() is followed by cancel() and
    // the dial resets to the selected duration.
    await tester.tap(find.text('Time to lift'));
    await tester.pumpAndSettle();
    expect(find.text('00:30'), findsOneWidget);
    expect(gateway.cancelled, [1001]);
  });
}

class _FakeGateway implements NotificationGateway {
  final List<({int id, String title, String body})> shown = [];
  final List<int> cancelled = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    shown.add((id: id, title: title, body: body));
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}
