import 'package:flutter/material.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class SeriesRowBody extends StatelessWidget {
  const SeriesRowBody({
    super.key,
    required this.index,
    required this.load,
    required this.reps,
    required this.cellHeight,
    required this.layout,
    required this.onEditLoad,
    required this.onEditRepeats,
  });

  final int index;
  final String load;
  final String reps;
  final double cellHeight;
  final DetailTableLayout layout;
  final VoidCallback onEditLoad;
  final VoidCallback onEditRepeats;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final cellStyle = TextStyle(
      color: colors.textColor,
      fontSize: WorkoutTypography.fontSize,
    );

    Widget cell({required double width, required Widget child}) => Container(
      height: cellHeight,
      width: width,
      alignment: const FractionalOffset(0.5, 0.5),
      child: child,
    );

    return Row(
      children: <Widget>[
        cell(
          width: layout.seriesColumnWidth,
          // The column heading is "series", so the first row should
          // read "1" — display the 1-based position rather than the
          // zero-indexed array slot.
          child: Center(child: Text((index + 1).toString(), style: cellStyle)),
        ),
        cell(
          width: layout.columnWidth,
          child: MaterialButton(
            onPressed: onEditLoad,
            child: Text(load, style: cellStyle),
          ),
        ),
        cell(
          width: layout.columnWidth,
          child: MaterialButton(
            onPressed: onEditRepeats,
            child: Text(reps, style: cellStyle),
          ),
        ),
      ],
    );
  }
}
