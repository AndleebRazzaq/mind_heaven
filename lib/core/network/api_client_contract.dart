abstract class ApiClientContract {
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  });
}
