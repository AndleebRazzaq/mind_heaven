class AppConfig {
  // Physical device: 127.0.0.1 is the phone — run `adb reverse tcp:8001 tcp:8001`
  // or use scripts/run_android_with_api.ps1 before `flutter run`.
  // Android emulator: --dart-define=API_BASE_URL=http://10.0.2.2:8001
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8001',
  );
}
