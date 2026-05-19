// Integration test — end-to-end golden flow.
//
// Run on a connected device or emulator:
//
//   flutter test integration_test/full_flow_test.dart -d <device-id>
//
// Not part of the unit test suite — `flutter test` skips integration_test/
// by default. Requires a real Android/iOS surface because it exercises
// sqflite (the real native plugin, not sqflite_common_ffi).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/presentation/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('add a workout, then delete it', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Bottom tab bar has Log + Timer; Log is selected by default and
    // its FAB is reachable.
    expect(find.byTooltip('Add exercise'), findsOneWidget);

    // Open the add-exercise dialog.
    await tester.tap(find.byTooltip('Add exercise'));
    await tester.pumpAndSettle();

    // Pick "Push Up" from the seeded catalogue.
    expect(find.text('Push Up'), findsWidgets);
    await tester.tap(find.text('Push Up').first);
    await tester.pumpAndSettle();

    // Workout card should now be visible.
    expect(find.text('Push Up'), findsOneWidget);
    expect(find.text('Series: 0'), findsOneWidget);

    // Swipe the card right to reveal the delete action.
    await tester.drag(find.text('Push Up'), const Offset(300, 0));
    await tester.pumpAndSettle();

    // Tap delete in the revealed action pane.
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    // Card is gone.
    expect(find.text('Push Up'), findsNothing);
  });

  testWidgets('Timer tab renders a countdown and survives tab swap',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Tap the Timer tab in the bottom TabBar (icon-only in landscape;
    // we find it by the icon to be orientation-agnostic).
    await tester.tap(find.byIcon(Icons.timer).first);
    await tester.pumpAndSettle();

    // Countdown should be visible (default preset 60s -> "01:00").
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    // Pick the 90s preset.
    await tester.tap(find.text('90s'));
    await tester.pumpAndSettle();
    expect(find.text('01:30'), findsOneWidget);

    // Swap to Log and back — preset should still be 90s (state survives
    // via AutomaticKeepAliveClientMixin).
    await tester.tap(find.byIcon(Icons.assignment).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.timer).first);
    await tester.pumpAndSettle();
    expect(find.text('01:30'), findsOneWidget);
  });

  testWidgets('Calendar dialog Today button selects today and dismisses',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Open the calendar from the app bar.
    await tester.tap(find.byIcon(Icons.calendar_today).first);
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    // Dialog dismissed; the "Today" label re-appears on the work log
    // page (which renders "Today" when the selected date matches now).
    expect(find.text('Today'), findsOneWidget);
  });
}
