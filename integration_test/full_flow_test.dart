// Integration test — end-to-end golden flow.
//
// Run on a connected device or emulator:
//
//   flutter test integration_test/full_flow_test.dart -d <device-id>
//
// Not part of the unit test suite — `flutter test` skips integration_test/
// by default. Requires a real Android/iOS surface because it exercises
// sqflite (the real native plugin, not sqflite_common_ffi).
//
// Flow exercised:
//   1. App launches and seeds the exercise catalogue.
//   2. User opens the "+ Add exercise" dialog and selects a seeded exercise.
//   3. A workout card appears for today.
//   4. Swipe-to-delete the workout via the start action pane.
//   5. The card disappears.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/presentation/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('add a workout, then delete it', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

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
    await tester.drag(
      find.text('Push Up'),
      const Offset(300, 0),
    );
    await tester.pumpAndSettle();

    // Tap delete in the revealed action pane.
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    // Card is gone.
    expect(find.text('Push Up'), findsNothing);
  });
}
