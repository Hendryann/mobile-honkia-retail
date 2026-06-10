import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const _storage = FlutterSecureStorage();

  static String get _base => dotenv.env['API_URL']!;

  static Future<Map<String, String>> _headers({
    bool auth = false,
    String contentType = 'application/json',
  }) async {
    final headers = <String, String>{'Content-Type': contentType};
    if (auth) {
      final token = await _storage.read(key: 'jwt');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String path, {bool auth = false}) async {
    return http.get(
      Uri.parse('$_base$path'),
      headers: await _headers(auth: auth),
    );
  }

  static Future<http.Response> post(
    String path, {
    Object? body,
    bool auth = false,
    String contentType = 'application/json',
  }) async {
    return http.post(
      Uri.parse('$_base$path'),
      headers: await _headers(auth: auth, contentType: contentType),
      body: contentType == 'application/json' ? jsonEncode(body) : body,
    );
  }

  static Future<http.Response> patch(
    String path, {
    Object? body,
    bool auth = false,
  }) async {
    return http.patch(
      Uri.parse('$_base$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path, {bool auth = false}) async {
    return http.delete(
      Uri.parse('$_base$path'),
      headers: await _headers(auth: auth),
    );
  }
}
