import 'package:flutter/material.dart';
import '../models/issue.dart';
import '../widgets/priority_badge.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  List<Issue> _sampleIssues() {
    return [
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
        assignee: 'Team Backend',
        reporter: 'Admin',
        createdAt: '2026-03-23',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final issues = _sampleIssues();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 1200;
              final isMedium = constraints.maxWidth > 800;

              int count = 1;
              if (isWide) {
                count = 4;
              } else if (isMedium) {
                count = 2;
              }

              return GridView.count(
                crossAxisCount: count,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.9,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StatCard(
                    title: 'Total Issues',
                    value: '148',
                    subtitle: '+12 this week',
                    icon: Icons.bug_report_rounded,
                  ),
                  StatCard(
                    title: 'Open Issues',
                    value: '32',
                    subtitle: 'Needs attention',
                    icon: Icons.error_outline_rounded,
                  ),
                  StatCard(
                    title: 'Resolved',
                    value: '96',
                    subtitle: 'Closed successfully',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  StatCard(
                    title: 'Active Projects',
                    value: '8',
                    subtitle: 'Across all teams',
                    icon: Icons.folder_open_rounded,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Issues',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Latest activity across active projects',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 18),
                        ...issues.map((issue) => _IssueRow(issue: issue)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Priority Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 18),
                            _MiniStat(title: 'Critical', value: '6'),
                            _MiniStat(title: 'High', value: '14'),
                            _MiniStat(title: 'Medium', value: '28'),
                            _MiniStat(title: 'Low', value: '12'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Team Notes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              '• Auth module is stable now\n\n• UI redesign is in progress\n\n• Next target: real issue CRUD and projects section',
                              style: TextStyle(
                                height: 1.6,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IssueRow extends StatelessWidget {
  final Issue issue;

  const _IssueRow({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${issue.id} • ${issue.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${issue.project} • Assigned to ${issue.assignee}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: issue.status),
          const SizedBox(width: 10),
          PriorityBadge(priority: issue.priority),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}