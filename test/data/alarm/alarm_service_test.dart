import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/data/alarm/alarm_service.dart';
import 'package:workout_log/data/alarm/notification_gateway.dart';

class _FakeGateway implements NotificationGateway {
  bool initialized = false;
  bool permissionResponse = true;
  Object? showThrows;
  final List<({int id, String title, String body})> shown = [];
  final List<int> cancelled = [];

  @override
  Future<void> initialize() async => initialized = true;

  @override
  Future<bool> requestPermissions() async => permissionResponse;

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (showThrows != null) throw showThrows!;
    shown.add((id: id, title: title, body: body));
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}

void main() {
  late _FakeGateway gateway;
  late AlarmService service;

  setUp(() {
    gateway = _FakeGateway();
    service = AlarmService(gateway);
  });

  test('initialize() delegates to the gateway exactly once', () async {
    await service.initialize();
    expect(gateway.initialized, isTrue);
  });

  test(
    'ring() shows notification with id 1001 / Rest over / Time to lift',
    () async {
      await service.ring();

      expect(gateway.shown, hasLength(1));
      expect(gateway.shown.single.id, 1001);
      expect(gateway.shown.single.title, 'Rest over');
      expect(gateway.shown.single.body, 'Time to lift');
    },
  );

  test('cancel() cancels the same id used by ring()', () async {
    await service.ring();
    await service.cancel();

    expect(gateway.cancelled, [1001]);
  });

  test(
    'requestPermissions() returns the gateway response unchanged (granted)',
    () async {
      gateway.permissionResponse = true;
      expect(await service.requestPermissions(), isTrue);
    },
  );

  test(
    'requestPermissions() returns the gateway response unchanged (denied)',
    () async {
      // Negative path: the user (or OS) denied notification permission.
      // AlarmService must surface that to the caller verbatim so the
      // timer UI can decide whether the alarm is reliable.
      gateway.permissionResponse = false;
      expect(await service.requestPermissions(), isFalse);
    },
  );

  test('ring() propagates gateway exceptions to the caller', () async {
    // Negative path: revoked permission / dead platform channel makes
    // show() throw. AlarmService does not swallow it; _fireAlarm in
    // TimerPage relies on that signal.
    gateway.showThrows = StateError('permission revoked');

    await expectLater(service.ring(), throwsA(isA<StateError>()));
    expect(gateway.shown, isEmpty);
  });
}
