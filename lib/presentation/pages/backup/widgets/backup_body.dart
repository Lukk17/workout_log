import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class BackupBody extends StatelessWidget {
  const BackupBody({
    super.key,
    required this.backupFilePath,
    required this.onBackup,
    required this.onRestore,
  });

  final String? backupFilePath;
  final VoidCallback onBackup;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);
    final path = backupFilePath ?? '…resolving path…';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(child: Text('Place a backup file at:\n$path\nto import it.')),
        MaterialButton(
          color: colors.buttonColor,
          onPressed: onRestore,
          child: Text(
            'Import backup',
            style: TextStyle(
              color: colors.buttonTextColor,
              fontSize: WorkoutTypography.fontSize,
            ),
          ),
        ),
        SizedBox(height: dims.height * 0.25),
        Center(child: Text('Backup will be created at:\n$path')),
        MaterialButton(
          color: colors.buttonColor,
          onPressed: onBackup,
          child: Text(
            'Create backup',
            style: TextStyle(
              color: colors.buttonTextColor,
              fontSize: WorkoutTypography.fontSize,
            ),
          ),
        ),
      ],
    );
  }
}
