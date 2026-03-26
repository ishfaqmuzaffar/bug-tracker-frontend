class Issue {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String project;
  final String assignee;
  final String reporter;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic> comments;

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
    required this.comments,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return fallback;
    }

    DateTime? readDate(String key) {
      final value = json[key];
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return Issue(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: readString(['title'], fallback: 'Untitled issue'),
      description: readString(['description'], fallback: ''),
      status: readString(['status'], fallback: 'Open'),
      priority: readString(['priority'], fallback: 'Medium'),
      project: readString(['project', 'projectName'], fallback: 'General'),
      assignee: readString(['assignee', 'assignedTo'], fallback: 'Unassigned'),
      reporter: readString(['reporter', 'reportedBy', 'createdBy'], fallback: 'Unknown'),
      createdAt: readDate('createdAt'),
      updatedAt: readDate('updatedAt'),
      comments: (json['comments'] as List?) ?? const [],
    );
  }

  String get createdAtDisplay {
    if (createdAt == null) return '-';
    final y = createdAt!.year.toString().padLeft(4, '0');
    final m = createdAt!.month.toString().padLeft(2, '0');
    final d = createdAt!.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}