import 'package:workout_log/data/alarm/notification_gateway.dart';
import 'package:workout_log/util/log.dart';

/// Copy reused by both the OS notification and the in-app dialog so
/// the two surfaces never drift.
const String alarmTitle = 'Rest over';
const String alarmBody = 'Time to lift';

class AlarmService {
  AlarmService(this._gateway);

  final NotificationGateway _gateway;
  static const _tag = 'AlarmService';
  static const _notificationId = 1001;

  Future<void> initialize() => _gateway.initialize();

  Future<bool> requestPermissions() async {
    final granted = await _gateway.requestPermissions();
    logFine('notification permission: $granted', name: _tag);
    return granted;
  }

  Future<void> ring() async {
    // Reusing _notificationId means the OS replaces any prior alarm
    // notification instead of stacking them.
    await _gateway.show(id: _notificationId, title: alarmTitle, body: alarmBody);
    logFine('alarm fired', name: _tag);
  }

  Future<void> cancel() => _gateway.cancel(_notificationId);
}
