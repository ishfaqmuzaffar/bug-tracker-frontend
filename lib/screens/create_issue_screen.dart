import 'package:flutter/material.dart';
import '../core/api_service.dart';

class CreateIssueScreen extends StatefulWidget {
  const CreateIssueScreen({super.key});

  @override
  State<CreateIssueScreen> createState() => _CreateIssueScreenState();
}

class _CreateIssueScreenState extends State<CreateIssueScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();

  void submit() async {
    await ApiService.createIssue({
      "title": title.text,
      "description": desc.text,
      "status": "Open",
      "priority": "Medium"
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Issue Created")),
    );

    title.clear();
    desc.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: "Title")),
          TextField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: submit, child: const Text("Create Issue"))
        ],
      ),
    );
  }
}