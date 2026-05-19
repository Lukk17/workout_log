import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);
    return Container(
      color: colors.backgroundColor,
      child: TabBar(
        indicatorColor: colors.indicatorColor,
        labelColor: colors.tabBarColor,
        controller: tabController,
        tabs: <Widget>[
          Tab(
            text: dims.isPortrait ? 'Log' : null,
            icon: Icon(Icons.assignment, color: colors.tabBarIconColor),
          ),
          Tab(
            text: dims.isPortrait ? 'Timer' : null,
            icon: Icon(Icons.timer, color: colors.tabBarIconColor),
          ),
        ],
      ),
    );
  }
}
