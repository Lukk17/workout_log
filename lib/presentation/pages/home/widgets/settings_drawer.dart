import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/pages/backup/backup_page.dart';
import 'package:workout_log/presentation/pages/exercise_list/exercise_list_page.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/app_drawer_button.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';
import 'package:workout_log/presentation/widgets/setting_switch_row.dart';

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final showBackground = ref.watch(backgroundImageProvider);

    return Drawer(
      child: Container(
        color: colors.drawerColor,
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  color: colors.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: WorkoutTypography.headerSize,
                ),
              ),
            ),
            SizedBox(height: dims.height * (dims.isPortrait ? 0.2 : 0.1)),
            SettingSwitchRow(
              label: 'Dark mode:',
              value: isDark,
              onChanged: (value) =>
                  ref.read(themeModeProvider.notifier).toggle(value),
            ),
            SizedBox(height: dims.height * 0.1),
            SettingSwitchRow(
              label: 'Background image:',
              value: showBackground,
              onChanged: (value) =>
                  ref.read(backgroundImageProvider.notifier).set(value),
            ),
            SizedBox(height: dims.height * (dims.isPortrait ? 0.1 : 0.05)),
            AppDrawerButton(
              label: 'Backup',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupPage()),
              ),
            ),
            SizedBox(height: dims.height * (dims.isPortrait ? 0.2 : 0.1)),
            AppDrawerButton(
              label: 'Edit Exercises',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExerciseListPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
