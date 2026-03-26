class Issue {
  final int id;
  final String title;
  final String project;
  final String status;
  final String priority;
  final String assignee;
  final String reporter;
  final String createdAt;

  Issue({
    required this.id,
    required this.title,
    required this.project,
    required this.status,
    required this.priority,
    required this.assignee,
    required this.reporter,
    required this.createdAt,
  });
}