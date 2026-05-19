import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/body_part_blocks.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

import '../../../../helpers/test_app.dart';

DetailTableLayout _layoutFor(double width, double height) {
  return DetailTableLayout.from(
    ResponsiveDimensions(
      width: width,
      height: height,
      isPortrait: height > width,
      appBarHeight: height * 0.08,
    ),
  );
}

Widget _wrap(Widget child) {
  return testApp(
    child: Scaffold(
      body: Center(
        child: SizedBox(width: 600, height: 400, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('Renders the part name inside each block', (tester) async {
    await tester.pumpWidget(_wrap(
      BodyPartBlocks(
        parts: const {BodyPart.chest, BodyPart.back, BodyPart.arm},
        layout: _layoutFor(600, 1200),
      ),
    ));

    expect(find.text('chest'), findsOneWidget);
    expect(find.text('back'), findsOneWidget);
    expect(find.text('arm'), findsOneWidget);
  });

  testWidgets('Three or fewer parts -> single Row', (tester) async {
    await tester.pumpWidget(_wrap(
      BodyPartBlocks(
        parts: const {BodyPart.chest, BodyPart.back, BodyPart.arm},
        layout: _layoutFor(600, 1200),
      ),
    ));

    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });

  testWidgets('Four parts -> Column of two Rows', (tester) async {
    await tester.pumpWidget(_wrap(
      BodyPartBlocks(
        parts: const {
          BodyPart.chest,
          BodyPart.back,
          BodyPart.arm,
          BodyPart.leg,
        },
        layout: _layoutFor(600, 1200),
      ),
    ));

    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNWidgets(2));
  });

  testWidgets('Empty set renders an empty Row (no labels)', (tester) async {
    await tester.pumpWidget(_wrap(
      BodyPartBlocks(
        parts: const <BodyPart>{},
        layout: _layoutFor(600, 1200),
      ),
    ));

    expect(find.byType(Row), findsOneWidget);
    expect(find.text('chest'), findsNothing);
  });
}
