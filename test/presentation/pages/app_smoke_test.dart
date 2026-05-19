import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/data/alarm/alarm_service.dart';
import 'package:workout_log/data/alarm/notification_gateway.dart';
import 'package:workout_log/presentation/app.dart';
import 'package:workout_log/presentation/pages/home/home_page.dart';
import 'package:workout_log/presentation/providers/alarm_providers.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';

import '../../test_helper.dart';

class _NoopGateway implements NotificationGateway {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}

void main() {
  initSqfliteForTests();

  late DaoTestEnv env;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'is_dark': true,
      'background_image': false,
    });
    env = await DaoTestEnv.create();
  });

  tearDown(() => env.dispose());

  testWidgets('MyApp mounts HomePage inside ProviderScope without throwing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(env.appDatabase),
          exerciseDaoProvider.overrideWithValue(env.exerciseDao),
          workLogDaoProvider.overrideWithValue(env.workLogDao),
          notificationGatewayProvider.overrideWithValue(_NoopGateway()),
          alarmServiceProvider.overrideWithValue(AlarmService(_NoopGateway())),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
  });
}
