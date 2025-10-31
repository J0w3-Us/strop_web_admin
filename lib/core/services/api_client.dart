import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String baseUrl = 'http://localhost:3000';

  void init({required String baseUrl}) {
    this.baseUrl = baseUrl;
  }

  Future<T> post<T>(String path, Map body, T Function(dynamic) parser) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      return parser(decoded);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<T> get<T>(String path, T Function(dynamic) parser) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      return parser(decoded);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
