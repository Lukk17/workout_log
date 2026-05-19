import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/series_row_body.dart';
import 'package:workout_log/presentation/widgets/delete_action_pane.dart';

class SeriesRow extends StatelessWidget {
  const SeriesRow({
    super.key,
    required this.index,
    required this.setKey,
    required this.workLog,
    required this.layout,
    required this.onDelete,
    required this.onEditLoad,
    required this.onEditRepeats,
  });

  final int index;
  final String setKey;
  final WorkLog workLog;
  final DetailTableLayout layout;
  final VoidCallback onDelete;
  final VoidCallback onEditLoad;
  final VoidCallback onEditRepeats;

  @override
  Widget build(BuildContext context) {
    final cellHeight = layout.isPortrait
        ? layout.portraitColumnHeight
        : layout.landscapeColumnHeight;
    final actionMargin = EdgeInsets.symmetric(
      vertical: layout.screenHeight * 0.01,
      horizontal: layout.screenWidth * 0.01,
    );

    return Slidable(
      key: ValueKey(setKey),
      startActionPane: DeleteActionPane(onDelete: onDelete),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          Container(
            margin: actionMargin,
            child: SlidableAction(
              onPressed: (_) => onEditLoad(),
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              icon: Icons.edit,
              label: 'Edit load',
            ),
          ),
          Container(
            margin: actionMargin,
            child: SlidableAction(
              onPressed: (_) => onEditRepeats(),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit repeats',
            ),
          ),
        ],
      ),
      child: SeriesRowBody(
        index: index,
        load: workLog.getLoad(setKey),
        reps: workLog.getReps(setKey),
        cellHeight: cellHeight,
        layout: layout,
        onEditLoad: onEditLoad,
        onEditRepeats: onEditRepeats,
      ),
    );
  }
}
