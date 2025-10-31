import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String baseUrl = 'http://localhost:3000';

  void init({required String baseUrl}) {
    this.baseUrl = baseUrl;
  }

  Future<Map<String, String>> _defaultHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<T> post<T>(String path, Map body, T Function(dynamic) parser) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _defaultHeaders();
    final res = await http.post(uri, body: jsonEncode(body), headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      return parser(decoded);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<T> get<T>(String path, T Function(dynamic) parser) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _defaultHeaders();
    final res = await http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      return parser(decoded);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<T> put<T>(String path, Map body, T Function(dynamic) parser) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _defaultHeaders();
    final res = await http.put(uri, body: jsonEncode(body), headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      return parser(decoded);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<T> delete<T>(String path, T Function(dynamic) parser) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _defaultHeaders();
    final res = await http.delete(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      return parser(decoded);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
