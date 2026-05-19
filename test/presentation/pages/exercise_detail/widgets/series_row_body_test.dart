import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/series_row_body.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

import '../../../../helpers/test_app.dart';

Widget _wrap(Widget child) {
  return testApp(
    child: Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          height: 100,
          child: child,
        ),
      ),
    ),
  );
}

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

void main() {
  testWidgets('Renders 1-based index in the first cell, not 0-based',
      (tester) async {
    await tester.pumpWidget(_wrap(
      SeriesRowBody(
        index: 0,
        load: '60',
        reps: '10',
        cellHeight: 80,
        layout: _layoutFor(600, 1200),
        onEditLoad: () {},
        onEditRepeats: () {},
      ),
    ));

    expect(find.text('1'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('Index 5 renders as "6" (still 1-based)', (tester) async {
    await tester.pumpWidget(_wrap(
      SeriesRowBody(
        index: 5,
        load: '0',
        reps: '0',
        cellHeight: 80,
        layout: _layoutFor(600, 1200),
        onEditLoad: () {},
        onEditRepeats: () {},
      ),
    ));

    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('Tapping the load cell calls onEditLoad', (tester) async {
    var loadTapped = 0;
    var repsTapped = 0;
    await tester.pumpWidget(_wrap(
      SeriesRowBody(
        index: 0,
        load: '60',
        reps: '10',
        cellHeight: 80,
        layout: _layoutFor(600, 1200),
        onEditLoad: () => loadTapped++,
        onEditRepeats: () => repsTapped++,
      ),
    ));

    await tester.tap(find.text('60'));
    await tester.pump();

    expect(loadTapped, 1);
    expect(repsTapped, 0);
  });

  testWidgets('Tapping the reps cell calls onEditRepeats', (tester) async {
    var loadTapped = 0;
    var repsTapped = 0;
    await tester.pumpWidget(_wrap(
      SeriesRowBody(
        index: 0,
        load: '60',
        reps: '10',
        cellHeight: 80,
        layout: _layoutFor(600, 1200),
        onEditLoad: () => loadTapped++,
        onEditRepeats: () => repsTapped++,
      ),
    ));

    await tester.tap(find.text('10'));
    await tester.pump();

    expect(loadTapped, 0);
    expect(repsTapped, 1);
  });
}
