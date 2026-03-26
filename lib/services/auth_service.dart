import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final prefs = await SharedPreferences.getInstance();

      final token = body['token']?.toString() ?? '';
      final emailValue = body['user']?['email']?.toString() ?? email;
      final role = body['user']?['role']?.toString() ?? 'user';

      await prefs.setString('token', token);
      await prefs.setString('email', emailValue);
      await prefs.setString('role', role);

      return body;
    }

    throw Exception(body['message']?.toString() ?? 'Login failed');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    await prefs.remove('role');
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? 'User';
  }

  Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'user';
  }
}