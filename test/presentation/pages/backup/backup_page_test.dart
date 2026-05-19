import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/data/backup/backup_service.dart';
import 'package:workout_log/presentation/pages/backup/backup_page.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';

import '../../../helpers/test_app.dart';
import '../../../test_helper.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

class _ThrowingBackupService extends BackupService {
  _ThrowingBackupService(super.dao);

  @override
  Future<String> get backupFilePath async =>
      throw ExternalStorageUnavailableException('boom');

  @override
  Future<void> backup() async =>
      throw ExternalStorageUnavailableException('write denied');

  @override
  Future<void> restore() async =>
      throw ExternalStorageUnavailableException('read denied');
}

class _RecordingBackupService extends BackupService {
  _RecordingBackupService(super.dao, this.dirPath);

  final String dirPath;
  int backupCalls = 0;

  @override
  Future<String> get backupFilePath async => '$dirPath/backup.json';

  @override
  Future<void> backup() async {
    backupCalls++;
  }

  @override
  Future<void> restore() async {}
}

void main() {
  initSqfliteForTests();

  late DaoTestEnv env;
  late Directory backupDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'is_dark': true,
      'background_image': false,
    });
    env = await DaoTestEnv.create();
    backupDir = await Directory.systemTemp.createTemp('backup_page_test_');
  });

  tearDown(() async {
    // Windows holds a transient handle on backup.json right after the
    // service writes it, so a deletion right after the test sometimes
    // races with the OS releasing it. A bounded retry avoids the
    // PathAccessException without masking real failures.
    if (await backupDir.exists()) {
      for (var attempt = 0; attempt < 5; attempt++) {
        try {
          await backupDir.delete(recursive: true);
          break;
        } on FileSystemException {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }
    }
    await env.dispose();
  });

  Future<void> useTallSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget wrap({BackupService? override}) => testApp(
    child: const BackupPage(),
    overrides: [
      appDatabaseProvider.overrideWithValue(env.appDatabase),
      exerciseDaoProvider.overrideWithValue(env.exerciseDao),
      workLogDaoProvider.overrideWithValue(env.workLogDao),
      backupServiceProvider.overrideWithValue(
        override ??
            BackupService(env.workLogDao, storageDir: () async => backupDir),
      ),
    ],
  );

  testWidgets('Renders the resolved backup path once FutureBuilder settles', (
    tester,
  ) async {
    await useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await _settle(tester);

    expect(find.textContaining('backup.json'), findsAtLeastNWidgets(1));
    expect(find.text('Create backup'), findsOneWidget);
    expect(find.text('Import backup'), findsOneWidget);
  });

  testWidgets('Create backup button delegates to BackupService.backup()', (
    tester,
  ) async {
    // End-to-end "tap -> file on disk" needs real DB I/O inside the
    // widget tree, which doesn't compose with flutter_test's FakeAsync
    // zone. The persistent side effect is already covered by
    // test/data/backup/backup_service_test.dart; here we just verify
    // the page wires the button to the right service method.
    await useTallSurface(tester);
    final recording = _RecordingBackupService(env.workLogDao, backupDir.path);

    await tester.pumpWidget(wrap(override: recording));
    await _settle(tester);

    await tester.tap(find.text('Create backup'));
    await _settle(tester);

    expect(recording.backupCalls, 1);
  });

  testWidgets('Import backup -> Cancel keeps the dialog from running restore', (
    tester,
  ) async {
    await useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await _settle(tester);

    await tester.tap(find.text('Import backup'));
    await _settle(tester);
    expect(find.text('Replace current workouts?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await _settle(tester);

    expect(find.text('Replace current workouts?'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets(
    'Import backup -> Replace surfaces an error SnackBar when no backup file',
    (tester) async {
      await useTallSurface(tester);
      await tester.pumpWidget(wrap());
      await _settle(tester);

      await tester.tap(find.text('Import backup'));
      await _settle(tester);
      await tester.tap(find.text('Replace'));
      // The file-existence check is real I/O, so pump via runAsync to let
      // the actual filesystem call finish before checking for the
      // resulting SnackBar.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await _settle(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Restore failed'), findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'Import backup -> Replace surfaces ExternalStorage failure SnackBar',
    (tester) async {
      await useTallSurface(tester);
      await tester.pumpWidget(
        wrap(override: _ThrowingBackupService(env.workLogDao)),
      );
      await _settle(tester);

      await tester.tap(find.text('Import backup'));
      await _settle(tester);
      await tester.tap(find.text('Replace'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await _settle(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('Restore failed: read denied'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Create backup surfaces ExternalStorage failure SnackBar', (
    tester,
  ) async {
    await useTallSurface(tester);
    await tester.pumpWidget(
      wrap(override: _ThrowingBackupService(env.workLogDao)),
    );
    await _settle(tester);

    await tester.tap(find.text('Create backup'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _settle(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Backup failed: write denied'), findsOneWidget);
  });
}
