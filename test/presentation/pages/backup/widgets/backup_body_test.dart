import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/presentation/pages/backup/widgets/backup_body.dart';

import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('Null path renders the resolving placeholder', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp(
      child: Scaffold(
        body: BackupBody(
          backupFilePath: null,
          onBackup: () {},
          onRestore: () {},
        ),
      ),
    ));

    expect(find.textContaining('…resolving path…'), findsAtLeastNWidgets(1));
  });

  testWidgets('Resolved path is rendered twice (import + create captions)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp(
      child: Scaffold(
        body: BackupBody(
          backupFilePath: '/storage/Android/data/x/files/backup.json',
          onBackup: () {},
          onRestore: () {},
        ),
      ),
    ));

    expect(
      find.textContaining('/storage/Android/data/x/files/backup.json'),
      findsNWidgets(2),
    );
  });

  testWidgets('Import backup button calls onRestore', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var restoreCalls = 0;
    var backupCalls = 0;

    await tester.pumpWidget(testApp(
      child: Scaffold(
        body: BackupBody(
          backupFilePath: '/x/backup.json',
          onBackup: () => backupCalls++,
          onRestore: () => restoreCalls++,
        ),
      ),
    ));

    await tester.tap(find.text('Import backup'));
    await tester.pump();

    expect(restoreCalls, 1);
    expect(backupCalls, 0);
  });

  testWidgets('Create backup button calls onBackup', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var restoreCalls = 0;
    var backupCalls = 0;

    await tester.pumpWidget(testApp(
      child: Scaffold(
        body: BackupBody(
          backupFilePath: '/x/backup.json',
          onBackup: () => backupCalls++,
          onRestore: () => restoreCalls++,
        ),
      ),
    ));

    await tester.tap(find.text('Create backup'));
    await tester.pump();

    expect(backupCalls, 1);
    expect(restoreCalls, 0);
  });
}
