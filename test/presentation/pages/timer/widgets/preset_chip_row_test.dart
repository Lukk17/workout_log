import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/presentation/pages/timer/widgets/preset_chip_row.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('labelFor', () {
    test('seconds < 120 render with "s" suffix', () {
      expect(PresetChipRow.labelFor(30), '30s');
      expect(PresetChipRow.labelFor(60), '60s');
      expect(PresetChipRow.labelFor(90), '90s');
      expect(PresetChipRow.labelFor(119), '119s');
    });

    test('seconds >= 120 render as integer minutes', () {
      expect(PresetChipRow.labelFor(120), '2 min');
      expect(PresetChipRow.labelFor(180), '3 min');
      expect(PresetChipRow.labelFor(300), '5 min');
    });
  });

  testWidgets('Renders one ChoiceChip per preset', (tester) async {
    await tester.pumpWidget(testApp(
      child: Scaffold(
        body: PresetChipRow(
          presets: const [30, 60, 90],
          selected: const Duration(seconds: 60),
          enabled: true,
          onPick: (_) {},
        ),
      ),
    ));

    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(find.text('30s'), findsOneWidget);
    expect(find.text('60s'), findsOneWidget);
    expect(find.text('90s'), findsOneWidget);
  });

  testWidgets('Tapping a chip invokes onPick with the matching duration',
      (tester) async {
    Duration? picked;
    await tester.pumpWidget(testApp(
      child: Scaffold(
        body: PresetChipRow(
          presets: const [30, 60, 90],
          selected: const Duration(seconds: 60),
          enabled: true,
          onPick: (d) => picked = d,
        ),
      ),
    ));

    await tester.tap(find.text('90s'));
    await tester.pump();

    expect(picked, const Duration(seconds: 90));
  });

  testWidgets('When disabled, chips have null onSelected', (tester) async {
    await tester.pumpWidget(testApp(
      child: Scaffold(
        body: PresetChipRow(
          presets: const [30, 60],
          selected: const Duration(seconds: 60),
          enabled: false,
          onPick: (_) {},
        ),
      ),
    ));

    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
    expect(chips.every((c) => c.onSelected == null), isTrue);
  });
}
