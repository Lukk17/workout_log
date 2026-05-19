import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/body_part_color.dart';
import 'package:workout_log/presentation/widgets/delete_action_pane.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class WorkLogCard extends StatelessWidget {
  const WorkLogCard({
    super.key,
    required this.workLog,
    required this.onDelete,
    required this.onTap,
  });

  final WorkLog workLog;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);
    final cardMargin = dims.height * 0.01;
    final deletePane = DeleteActionPane(onDelete: onDelete);

    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      child: Slidable(
        key: ValueKey(workLog.id),
        startActionPane: deletePane,
        endActionPane: deletePane,
        child: Card(
          color: colors.primaryColor,
          elevation: 8,
          child: ListTile(
            title: Container(
              margin: EdgeInsets.all(cardMargin),
              child: Text(
                workLog.exercise.name,
                style: TextStyle(
                  fontSize: WorkoutTypography.fontSize,
                  color: colors.cardTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    right: dims.width * 0.02,
                    bottom: dims.height * 0.01,
                  ),
                  child: Text(
                    'Series: ${workLog.series.length}',
                    style: TextStyle(
                      fontSize: WorkoutTypography.fontSize,
                      color: colors.cardTextColor,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: dims.width * 0.02,
                    bottom: dims.height * 0.01,
                  ),
                  child: Text(
                    'Reps: ${workLog.getRepsSum()}',
                    style: TextStyle(
                      fontSize: WorkoutTypography.fontSize,
                      color: colors.cardTextColor,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            leading: Column(children: _bodyPartLabels(colors)),
            trailing: Container(
              margin: EdgeInsets.only(top: dims.height * 0.02),
              child: Icon(Icons.arrow_forward, color: colors.secondaryColor),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  List<Widget> _bodyPartLabels(WorkoutColors colors) {
    final parts = [
      ...workLog.exercise.bodyParts,
      ...workLog.exercise.secondaryBodyParts,
    ].take(3);

    return parts
        .map(
          (bp) =>
              Text(bp.displayName, style: TextStyle(color: bp.color(colors))),
        )
        .toList();
  }
}
