import 'package:flutter/material.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({super.key, required this.workLog, required this.layout});

  final WorkLog workLog;
  final DetailTableLayout layout;

  @override
  Size get preferredSize => Size.fromHeight(
    layout.isPortrait ? layout.screenHeight * 0.08 : layout.screenHeight * 0.1,
  );

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: layout.screenWidth * 0.3,
            child: Text(
              workLog.created.toIso8601String().substring(0, 10),
              textAlign: TextAlign.end,
              style: TextStyle(color: colors.titleColor),
            ),
          ),
        ],
      ),
      backgroundColor: colors.appBarColor,
    );
  }
}
