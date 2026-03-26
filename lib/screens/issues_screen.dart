import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/issue.dart';
import '../services/issues_service.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final IssuesService _issuesService = IssuesService();

  bool _loading = true;
  String? _error;
  String _selectedStatus = 'All';
  List<Issue> _issues = [];

  @override
  void initState() {
    super.initState();
    _loadIssues();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIssues() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final issues = await _issuesService.getIssues();
      if (!mounted) return;
      setState(() {
        _issues = issues;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  List<Issue> get _filteredIssues {
    final q = _searchController.text.trim().toLowerCase();

    return _issues.where((issue) {
      final matchesSearch = q.isEmpty ||
          issue.title.toLowerCase().contains(q) ||
          issue.project.toLowerCase().contains(q) ||
          issue.assignee.toLowerCase().contains(q) ||
          issue.reporter.toLowerCase().contains(q) ||
          issue.priority.toLowerCase().contains(q);

      final matchesStatus =
          _selectedStatus == 'All' || issue.status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _showCreateIssueDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final projectController = TextEditingController();
    final assigneeController = TextEditingController();
    final reporterController = TextEditingController();

    String status = 'Open';
    String priority = 'Medium';
    bool saving = false;
    String? dialogError;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              if (titleController.text.trim().isEmpty) {
                setDialogState(() {
                  dialogError = 'Title is required.';
                });
                return;
              }

              setDialogState(() {
                saving = true;
                dialogError = null;
              });

              try {
                await _issuesService.createIssue(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  status: status,
                  priority: priority,
                  project: projectController.text.trim().isEmpty
                      ? 'General'
                      : projectController.text.trim(),
                  assignee: assigneeController.text.trim().isEmpty
                      ? 'Unassigned'
                      : assigneeController.text.trim(),
                  reporter: reporterController.text.trim().isEmpty
                      ? 'Admin'
                      : reporterController.text.trim(),
                );

                if (!mounted) return;
                Navigator.of(context).pop();
                await _loadIssues();

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Issue created successfully.')),
                );
              } catch (e) {
                setDialogState(() {
                  dialogError = e.toString().replaceFirst('Exception: ', '');
                  saving = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Create Issue'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: projectController,
                        decoration: const InputDecoration(labelText: 'Project'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: assigneeController,
                        decoration: const InputDecoration(labelText: 'Assignee'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: reporterController,
                        decoration: const InputDecoration(labelText: 'Reporter'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          'Open',
                          'In Progress',
                          'Resolved',
                          'Closed',
                        ]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            status = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: const [
                          'Low',
                          'Medium',
                          'High',
                          'Critical',
                        ]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            priority = value;
                          });
                        },
                      ),
                      if (dialogError != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.danger.withOpacity(0.20),
                            ),
                          ),
                          child: Text(
                            dialogError!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : save,
                  child: Text(saving ? 'Saving...' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _changeStatus(Issue issue, String newStatus) async {
    try {
      await _issuesService.updateIssueStatus(
        id: issue.id,
        status: newStatus,
      );

      await _loadIssues();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Issue #${issue.id} updated to $newStatus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
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
                      decoration: const InputDecoration(
                        hintText: 'Search issues by title, project, assignee, reporter, priority',
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
                      border: Border.all(color: AppColors.border),
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
                      ]
                          .map((e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
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
                      onPressed: _showCreateIssueDialog,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create Issue'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _loadIssues,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 44, color: AppColors.danger),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to load issues',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else if (issues.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No issues found.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowHeight: 54,
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 78,
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Title')),
                          DataColumn(label: Text('Project')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Priority')),
                          DataColumn(label: Text('Assignee')),
                          DataColumn(label: Text('Reporter')),
                          DataColumn(label: Text('Comments')),
                          DataColumn(label: Text('Created')),
                          DataColumn(label: Text('Actions')),
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
                              DataCell(Text(issue.reporter)),
                              DataCell(Text('${issue.comments.length}')),
                              DataCell(Text(issue.createdAtDisplay)),
                              DataCell(
                                PopupMenuButton<String>(
                                  tooltip: 'Change status',
                                  onSelected: (value) => _changeStatus(issue, value),
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'Open', child: Text('Open')),
                                    PopupMenuItem(
                                        value: 'In Progress', child: Text('In Progress')),
                                    PopupMenuItem(value: 'Resolved', child: Text('Resolved')),
                                    PopupMenuItem(value: 'Closed', child: Text('Closed')),
                                  ],
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.more_horiz_rounded),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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