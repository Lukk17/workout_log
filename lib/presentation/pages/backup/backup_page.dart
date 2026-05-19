import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/backup/backup_service.dart';
import 'package:workout_log/presentation/pages/backup/widgets/backup_body.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';
import 'package:workout_log/util/log.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  static const _tag = 'BackupPage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        builder: (context, snap) => BackupBody(
          backupFilePath: snap.data,
          onBackup: () => _backup(context, ref),
          onRestore: () => _restore(context, ref),
        ),
      ),
    );
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    logFine('Creating backup...', name: _tag);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(backupServiceProvider).backup();

      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(const SnackBar(content: Text('Backup created.')));
    } on BackupException catch (e) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    logFine('Restoring from backup...', name: _tag);
    final messenger = ScaffoldMessenger.of(context);
    final selectedDate = ref.read(selectedDateProvider);

    // restore() now replaces existing data. Confirm before we wipe.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace current workouts?'),
        content: const Text(
          'Restoring will delete every workout currently in the app '
          'and replace it with the contents of backup.json. '
          'This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(backupServiceProvider).restore();

      if (!context.mounted) {
        return;
      }

      ref.invalidate(exercisesProvider);
      ref.invalidate(workLogsByDateProvider(selectedDate));
      messenger.showSnackBar(const SnackBar(content: Text('Backup restored.')));
    } on BackupException catch (e) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }
}
