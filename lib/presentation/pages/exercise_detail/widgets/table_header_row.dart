import 'package:flutter/material.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class TableHeaderRow extends StatelessWidget {
  const TableHeaderRow({super.key, required this.layout});

  final DetailTableLayout layout;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final height = layout.isPortrait
        ? layout.portraitColumnHeight
        : layout.headerLandscapeColumnHeight;
    Widget cell(String text, double width) => Container(
      height: height,
      width: width,
      alignment: const FractionalOffset(0.5, 0.5),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textColor,
          fontSize: WorkoutTypography.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    return Row(
      children: <Widget>[
        cell('series', layout.seriesColumnWidth),
        cell('load', layout.columnWidth),
        cell('repeats', layout.columnWidth),
      ],
    );
  }
}
