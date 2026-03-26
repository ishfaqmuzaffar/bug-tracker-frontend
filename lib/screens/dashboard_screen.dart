import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/issue.dart';
import '../services/issues_service.dart';
import '../widgets/priority_badge.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final IssuesService _issuesService = IssuesService();

  bool _loading = true;
  String? _error;
  List<Issue> _issues = [];

  @override
  void initState() {
    super.initState();
    _loadIssues();
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

  int _countByStatus(String status) {
    return _issues.where((e) => e.status.toLowerCase() == status.toLowerCase()).length;
  }

  int _countByPriority(String priority) {
    return _issues.where((e) => e.priority.toLowerCase() == priority.toLowerCase()).length;
  }

  int get _resolvedCount {
    final statuses = {'resolved', 'closed'};
    return _issues.where((e) => statuses.contains(e.status.toLowerCase())).length;
  }

  int get _activeProjects {
    return _issues.map((e) => e.project.trim()).where((e) => e.isNotEmpty).toSet().length;
  }

  List<Issue> get _recentIssues {
    final sorted = [..._issues];
    sorted.sort((a, b) {
      final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return sorted.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.danger),
              const SizedBox(height: 12),
              const Text(
                'Failed to load dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadIssues,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadIssues,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  children: [
                    StatCard(
                      title: 'Total Issues',
                      value: '${_issues.length}',
                      subtitle: 'Live from backend',
                      icon: Icons.bug_report_rounded,
                    ),
                    StatCard(
                      title: 'Open Issues',
                      value: '${_countByStatus('Open')}',
                      subtitle: 'Needs attention',
                      icon: Icons.error_outline_rounded,
                    ),
                    StatCard(
                      title: 'Resolved / Closed',
                      value: '$_resolvedCount',
                      subtitle: 'Completed issues',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    StatCard(
                      title: 'Active Projects',
                      value: '$_activeProjects',
                      subtitle: 'Unique projects',
                      icon: Icons.folder_open_rounded,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1050) {
                  return Column(
                    children: [
                      _RecentIssuesCard(issues: _recentIssues),
                      const SizedBox(height: 16),
                      _SummaryCard(
                        critical: _countByPriority('Critical'),
                        high: _countByPriority('High'),
                        medium: _countByPriority('Medium'),
                        low: _countByPriority('Low'),
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _RecentIssuesCard(issues: _recentIssues),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: _SummaryCard(
                        critical: _countByPriority('Critical'),
                        high: _countByPriority('High'),
                        medium: _countByPriority('Medium'),
                        low: _countByPriority('Low'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentIssuesCard extends StatelessWidget {
  final List<Issue> issues;

  const _RecentIssuesCard({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Card(
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
              'Latest issues from the database',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            if (issues.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    'No issues found yet.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              ...issues.map((issue) => _IssueRow(issue: issue)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int critical;
  final int high;
  final int medium;
  final int low;

  const _SummaryCard({
    required this.critical,
    required this.high,
    required this.medium,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Priority Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _MiniStat(title: 'Critical', value: '$critical'),
                _MiniStat(title: 'High', value: '$high'),
                _MiniStat(title: 'Medium', value: '$medium'),
                _MiniStat(title: 'Low', value: '$low'),
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
                  'Live Backend Connected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'The dashboard is now using your real /issues endpoint. Next step should be create issue form, edit issue form, and project APIs.',
                  style: TextStyle(
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        border: Border.all(color: AppColors.border),
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
                    color: AppColors.textSecondary,
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
                color: AppColors.textSecondary,
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