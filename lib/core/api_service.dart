import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiService {
  static String? token;

  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

  static Future login(String email, String password) async {
    final res = await http.post(
      Uri.parse("${Constants.baseUrl}/auth/login"),
      headers: headers,
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(res.body);
    token = data['token'];
    return data;
  }

  static Future getIssues() async {
    final res = await http.get(
      Uri.parse("${Constants.baseUrl}/issues"),
      headers: headers,
    );
    return jsonDecode(res.body);
  }

  static Future createIssue(Map data) async {
    final res = await http.post(
      Uri.parse("${Constants.baseUrl}/issues"),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }
}