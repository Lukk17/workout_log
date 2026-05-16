import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/data/db/db_provider.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  final Logger _log = Logger('backupView');

  double _screenHeight = 100;
  bool _isPortraitOrientation = false;

  double _appBarHeightPortrait = 30;
  double _appBarHeightLandscape = 30;

  void setupDimensions() {
    _screenHeight = Util.getScreenHeight(context);
    _appBarHeightPortrait = _screenHeight * 0.08;
    _appBarHeightLandscape = _screenHeight * 0.1;
  }

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return OrientationBuilder(builder: (context, orientation) {
      _isPortraitOrientation = orientation == Orientation.portrait;
      setupDimensions();

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(_isPortraitOrientation
              ? _appBarHeightPortrait
              : _appBarHeightLandscape),
          child: AppBar(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text('Backup')],
            ),
            backgroundColor: colors.appBarColor,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Text(
                  'Make sure to put backup file under: \n Android/data/com.lukk.workoutlog/files/\n'
                  ' and name it: backup.json\n'),
            ),
            MaterialButton(
              color: colors.buttonColor,
              child: Text(
                'Import backup',
                style: TextStyle(
                  color: colors.buttonTextColor,
                  fontSize: WorkoutTypography.fontSize,
                ),
              ),
              onPressed: _restore,
            ),
            SizedBox(height: _screenHeight * 0.25),
            const Center(
              child: Text(
                  'Backup will be created inside:\n Android/data/com.lukk.workoutlog/files/backup.json \n'),
            ),
            MaterialButton(
              color: colors.buttonColor,
              child: Text(
                'Create backup',
                style: TextStyle(
                  color: colors.buttonTextColor,
                  fontSize: WorkoutTypography.fontSize,
                ),
              ),
              onPressed: _backup,
            ),
          ],
        ),
      );
    });
  }

  Future<void> _backup() async {
    _log.fine('Creating backup...');
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(dbProvider).backup();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Backup created.')));
    } on ExternalStorageUnavailableException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restore() async {
    _log.fine('Restoring from backup...');
    final messenger = ScaffoldMessenger.of(context);
    final selectedDate = ref.read(selectedDateProvider);
    try {
      await ref.read(dbProvider).restore();
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
