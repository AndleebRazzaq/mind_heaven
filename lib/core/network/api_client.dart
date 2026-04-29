import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_client_contract.dart';

class ApiClient implements ApiClientContract {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.baseUrl;

  static String _unreachableHint(String baseUrl) {
    return 'Cannot reach API at $baseUrl.\n\n'
        'On a real phone, 127.0.0.1 is the phone, not your PC.\n\n'
        'Fix (USB debugging):\n'
        '  Run: adb reverse tcp:8001 tcp:8001\n'
        '  Or: .\\scripts\\run_android_with_api.ps1\n\n'
        'Emulator (no adb reverse):\n'
        '  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001\n\n'
        'Phone on Wi‑Fi (no USB reverse):\n'
        '  flutter run --dart-define=API_BASE_URL=http://YOUR_PC_LAN_IP:8001\n\n'
        'Start the server: backend\\run_backend.ps1';
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body ?? {}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API error: ${response.statusCode} ${response.body}');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('Invalid JSON response');
    } on http.ClientException catch (e) {
      final msg = e.message;
      if (msg.contains('SocketException') ||
          msg.contains('Connection refused') ||
          msg.contains('Failed host lookup') ||
          msg.contains('Network is unreachable')) {
        throw Exception(_unreachableHint(_baseUrl));
      }
      rethrow;
    }
  }
}
