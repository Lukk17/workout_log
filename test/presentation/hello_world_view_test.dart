import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';
import 'package:workout_log/presentation/theme/app_theme.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('themeModeProvider toggles light -> dark and persists', (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          final mode = ref.watch(themeModeProvider);
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: mode,
            home: const SizedBox.shrink(),
          );
        }),
      ),
    );
    // Wait for the StateNotifier to load its initial value from SharedPreferences.
    await tester.pumpAndSettle();

    // First launch with no stored pref → defaults to dark.
    expect(container.read(themeModeProvider), ThemeMode.dark);

    // Toggle off — should flip to light and persist.
    await container.read(themeModeProvider.notifier).toggle(false);
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_dark'), isFalse);
  });

  testWidgets('backgroundImageProvider toggle persists', (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          ref.watch(backgroundImageProvider);
          return const MaterialApp(home: SizedBox.shrink());
        }),
      ),
    );
    await tester.pumpAndSettle();

    // First launch with no stored pref → defaults to true.
    expect(container.read(backgroundImageProvider), isTrue);

    await container.read(backgroundImageProvider.notifier).set(false);
    await tester.pumpAndSettle();
    expect(container.read(backgroundImageProvider), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('background_image'), isFalse);
  });
}
