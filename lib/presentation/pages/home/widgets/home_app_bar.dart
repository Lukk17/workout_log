import 'package:flutter/material.dart';
import 'package:workout_log/presentation/app.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.dims,
    required this.onOpenSettings,
    required this.onOpenCalendar,
  });

  final ResponsiveDimensions dims;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenCalendar;

  @override
  Size get preferredSize => Size.fromHeight(dims.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final titleFontSize = dims.width * (dims.isPortrait ? 0.055 : 0.03);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.settings, color: colors.titleColor),
        onPressed: onOpenSettings,
      ),
      title: Text(
        MyApp.title,
        style: TextStyle(color: colors.titleColor, fontSize: titleFontSize),
      ),
      backgroundColor: colors.appBarColor,
      centerTitle: !dims.isPortrait,
      actions: <Widget>[
        MaterialButton(
          padding: const EdgeInsets.all(5),
          onPressed: onOpenCalendar,
          child: dims.isPortrait
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.calendar_today, color: colors.titleColor),
                      Text('Calendar',
                          style: TextStyle(color: colors.titleColor)),
                    ],
                  ),
                )
              : Icon(Icons.calendar_today, color: colors.iconColor),
        ),
      ],
    );
  }
}
