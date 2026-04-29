abstract class NotificationPermissionOrchestrator {
  Future<bool> requestPermission();
}

class NoopNotificationPermissionOrchestrator
    implements NotificationPermissionOrchestrator {
  @override
  Future<bool> requestPermission() async => true;
}
