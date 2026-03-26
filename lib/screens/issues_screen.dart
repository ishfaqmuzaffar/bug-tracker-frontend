import 'package:flutter/material.dart';
import '../core/api_service.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  List issues = [];

  @override
  void initState() {
    super.initState();
    loadIssues();
  }

  void loadIssues() async {
    final data = await ApiService.getIssues();
    setState(() => issues = data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: issues.length,
      itemBuilder: (context, i) {
        final issue = issues[i];

        return Card(
          child: ListTile(
            title: Text(issue['title']),
            subtitle: Text(issue['status']),
          ),
        );
      },
    );
  }
}