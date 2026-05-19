import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/backup/backup_service.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';
import 'package:workout_log/util/log.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  static const _tag = 'BackupPage';

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return ResponsiveScaffold(
      appBarBuilder: (context, dims) => PreferredSize(
        preferredSize: Size.fromHeight(dims.appBarHeight),
        child: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text('Backup')],
          ),
          backgroundColor: colors.appBarColor,
        ),
      ),
      body: FutureBuilder<String>(
        future: ref.watch(backupServiceProvider).backupFilePath,
        builder: (context, snap) => _BackupBody(
          backupFilePath: snap.data,
          onBackup: _backup,
          onRestore: _restore,
        ),
      ),
    );
  }

  Future<void> _backup() async {
    logFine('Creating backup...', name: _tag);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(backupServiceProvider).backup();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Backup created.')));
    } on ExternalStorageUnavailableException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restore() async {
    logFine('Restoring from backup...', name: _tag);
    final messenger = ScaffoldMessenger.of(context);
    final selectedDate = ref.read(selectedDateProvider);
    try {
      await ref.read(backupServiceProvider).restore();
      if (!mounted) return;
      ref.invalidate(exercisesProvider);
      ref.invalidate(workLogsByDateProvider(selectedDate));
      messenger.showSnackBar(const SnackBar(content: Text('Backup restored.')));
    } on ExternalStorageUnavailableException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }
}

class _BackupBody extends StatelessWidget {
  const _BackupBody({
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
