/// Thin seam between [AlarmService] and the underlying notifications
/// plugin. Lets the service depend on an interface it can fake in tests
/// instead of the third-party plugin whose platform-interface singleton
/// is not test-friendly.
abstract class NotificationGateway {
  Future<void> initialize();

  Future<bool> requestPermissions();

  Future<void> show({
    required int id,
    required String title,
    required String body,
  });

  Future<void> cancel(int id);
}
