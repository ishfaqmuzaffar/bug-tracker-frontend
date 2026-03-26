import 'package:flutter/material.dart';
import '../models/issue.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';

  final List<Issue> _issues = [
    Issue(
      id: 1001,
      title: 'Login page breaks on invalid token state',
      project: 'Web Portal',
      status: 'Open',
      priority: 'High',
      assignee: 'Aqib',
      reporter: 'Admin',
      createdAt: '2026-03-25',
    ),
    Issue(
      id: 1002,
      title: 'Dashboard cards overlap on smaller screens',
      project: 'Admin Panel',
      status: 'In Progress',
      priority: 'Medium',
      assignee: 'Hassan',
      reporter: 'Admin',
      createdAt: '2026-03-24',
    ),
    Issue(
      id: 1003,
      title: 'CORS warning seen during auth refresh call',
      project: 'API',
      status: 'Resolved',
      priority: 'Critical',
      assignee: 'Backend Team',
      reporter: 'Admin',
      createdAt: '2026-03-23',
    ),
    Issue(
      id: 1004,
      title: 'Project list flickers after page refresh',
      project: 'Projects',
      status: 'Closed',
      priority: 'Low',
      assignee: 'Nadeem',
      reporter: 'QA',
      createdAt: '2026-03-22',
    ),
  ];

  List<Issue> get _filteredIssues {
    return _issues.where((issue) {
      final matchesSearch =
          issue.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          issue.project.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          issue.assignee.toLowerCase().contains(_searchController.text.toLowerCase());

      final matchesStatus =
          _selectedStatus == 'All' || issue.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final issues = _filteredIssues;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search issues by title, project, or assignee',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      underline: const SizedBox.shrink(),
                      items: const [
                        'All',
                        'Open',
                        'In Progress',
                        'Resolved',
                        'Closed',
                      ].map((e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create Issue'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: issues.isEmpty
                    ? const Center(
                        child: Text(
                          'No issues found.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: DataTable(
                          headingRowHeight: 54,
                          dataRowMinHeight: 64,
                          dataRowMaxHeight: 72,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Title')),
                            DataColumn(label: Text('Project')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Priority')),
                            DataColumn(label: Text('Assignee')),
                            DataColumn(label: Text('Created')),
                          ],
                          rows: issues.map((issue) {
                            return DataRow(
                              cells: [
                                DataCell(Text('#${issue.id}')),
                                DataCell(
                                  SizedBox(
                                    width: 280,
                                    child: Text(
                                      issue.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(issue.project)),
                                DataCell(StatusBadge(status: issue.status)),
                                DataCell(PriorityBadge(priority: issue.priority)),
                                DataCell(Text(issue.assignee)),
                                DataCell(Text(issue.createdAt)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}