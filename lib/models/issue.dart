class Issue {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String project;
  final String assignee;
  final String reporter;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ✅ NEW
  final String? attachmentName;
  final String? attachmentPath;
  final String? attachmentMimeType;

  final List<Comment> comments;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.project,
    required this.assignee,
    required this.reporter,
    required this.createdAt,
    required this.updatedAt,
    this.attachmentName,
    this.attachmentPath,
    this.attachmentMimeType,
    required this.comments,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      project: json['project'] ?? '',
      assignee: json['assignee'] ?? '',
      reporter: json['reporter'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      attachmentName: json['attachmentName'],
      attachmentPath: json['attachmentPath'],
      attachmentMimeType: json['attachmentMimeType'],
      comments: (json['comments'] as List? ?? [])
          .map((e) => Comment.fromJson(e))
          .toList(),
    );
  }

  String get createdAtDisplay {
    return createdAt.toString().split('.')[0];
  }
}

class Comment {
  final int id;
  final String message;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.message,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get createdAtDisplay {
    return createdAt.toString().split('.')[0];
  }
}