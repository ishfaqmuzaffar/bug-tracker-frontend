import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_config.dart';
import '../models/issue.dart';

class IssuesService {
  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<Map<String, String>> _jsonHeaders() async {
    final token = await _token();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Issue>> getIssues() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/issues');

    final response = await http.get(
      uri,
      headers: await _jsonHeaders(),
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

  Future<Issue> getIssue(int id) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/issues/$id');

    final response = await http.get(
      uri,
      headers: await _jsonHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      return Issue.fromJson(Map<String, dynamic>.from(decoded));
    }

    throw Exception('Failed to load issue: ${response.body}');
  }

  Future<void> createIssue({
    required String title,
    required String description,
    required String status,
    required String priority,
    required String project,
    required String assignee,
    required String reporter,
    PlatformFile? attachment,
  }) async {
    final token = await _token();
    final uri = Uri.parse('${AppConfig.baseUrl}/issues');

    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['status'] = status;
    request.fields['priority'] = priority;
    request.fields['project'] = project;
    request.fields['assignee'] = assignee;
    request.fields['reporter'] = reporter;

    if (attachment != null) {
      if (attachment.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachment',
            attachment.bytes as Uint8List,
            filename: attachment.name,
          ),
        );
      } else if (attachment.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            attachment.path!,
            filename: attachment.name,
          ),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

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
      headers: await _jsonHeaders(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update issue status: ${response.body}');
    }
  }

  Future<Issue> addComment({
    required int id,
    required String message,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/issues/$id/comments');

    final response = await http.post(
      uri,
      headers: await _jsonHeaders(),
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      return Issue.fromJson(Map<String, dynamic>.from(decoded));
    }

    throw Exception('Failed to add comment: ${response.body}');
  }
}