import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_config.dart';
import '../models/issue.dart';

class IssuesService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Issue>> getIssues() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/issues');

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map((e) => Issue.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (decoded is Map && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((e) => Issue.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      return [];
    }

    throw Exception('Failed to load issues: ${response.body}');
  }

  Future<void> createIssue({
    required String title,
    required String description,
    required String status,
    required String priority,
    required String project,
    required String assignee,
    required String reporter,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/issues');

    final body = {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'project': project,
      'assignee': assignee,
      'reporter': reporter,
    };

    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to create issue: ${response.body}');
    }
  }

  Future<void> updateIssueStatus({
    required int id,
    required String status,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/issues/$id/status');

    final response = await http.patch(
      uri,
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update issue status: ${response.body}');
    }
  }
}