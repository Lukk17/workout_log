import 'package:workout_log/data/alarm/notification_gateway.dart';
import 'package:workout_log/util/log.dart';

class AlarmService {
  AlarmService(this._gateway);

  final NotificationGateway _gateway;
  static const _tag = 'AlarmService';
  static const _notificationId = 1001;
  static const _title = 'Rest over';
  static const _body = 'Time to lift.';

  Future<void> initialize() => _gateway.initialize();

  Future<bool> requestPermissions() async {
    final granted = await _gateway.requestPermissions();
    logFine('notification permission: $granted', name: _tag);
    return granted;
  }

  Future<void> ring() async {
    // Reusing _notificationId means the OS replaces any prior alarm
    // notification instead of stacking them.
    await _gateway.show(id: _notificationId, title: _title, body: _body);
    logFine('alarm fired', name: _tag);
  }

  Future<void> cancel() => _gateway.cancel(_notificationId);
}
