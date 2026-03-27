import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_config.dart';
import '../models/issue.dart';
import '../services/issues_service.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';

class IssueDetailScreen extends StatefulWidget {
  final int issueId;

  const IssueDetailScreen({super.key, required this.issueId});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final IssuesService _issuesService = IssuesService();
  final TextEditingController _commentController = TextEditingController();

  Issue? _issue;
  bool _loading = true;
  bool _savingComment = false;
  String? _error;
  String? _role;

  bool get _canUpdateStatus {
    final role = (_role ?? '').toUpperCase();
    return role == 'ADMIN' || role == 'DEVELOPER';
  }

  bool get _canAddComment {
    final role = (_role ?? '').toUpperCase();
    return role == 'ADMIN' || role == 'DEVELOPER' || role == 'TESTER';
  }

  @override
  void initState() {
    super.initState();
    _loadIssue();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadIssue() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final role = await _issuesService.getCurrentRole();
      final issue = await _issuesService.getIssue(widget.issueId);

      if (!mounted) return;
      setState(() {
        _role = role;
        _issue = issue;
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

  Future<void> _changeStatus(String value) async {
    try {
      await _issuesService.updateIssueStatus(
        id: widget.issueId,
        status: value,
      );
      await _loadIssue();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Issue status updated to $value')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _submitComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _savingComment = true;
    });

    try {
      final updated = await _issuesService.addComment(
        id: widget.issueId,
        message: message,
      );

      if (!mounted) return;
      setState(() {
        _issue = updated;
        _commentController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _savingComment = false;
      });
    }
  }

  Future<void> _openAttachment() async {
    final issue = _issue;
    if (issue == null || issue.attachmentPath == null || issue.attachmentPath!.isEmpty) {
      return;
    }

    final cleanPath = issue.attachmentPath!.replaceAll('\\', '/');
    final path = cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath;
    final uri = Uri.parse('${AppConfig.baseUrl}/$path');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open attachment.')),
      );
    }
  }

  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issue = _issue;

    return Scaffold(
      appBar: AppBar(
        title: Text(issue == null ? 'Issue Details' : 'Issue #${issue.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  )
                : issue == null
                    ? const Center(child: Text('Issue not found.'))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  issue.title,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                StatusBadge(status: issue.status),
                                PriorityBadge(priority: issue.priority),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                issue.description,
                                style: const TextStyle(fontSize: 15, height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(width: 220, child: _infoTile('Project', issue.project)),
                                SizedBox(width: 220, child: _infoTile('Assignee', issue.assignee)),
                                SizedBox(width: 220, child: _infoTile('Reporter', issue.reporter)),
                                SizedBox(width: 220, child: _infoTile('Created', issue.createdAtDisplay)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 12),
                                if (_canUpdateStatus)
                                  DropdownButton<String>(
                                    value: issue.status,
                                    items: const [
                                      'Open',
                                      'In Progress',
                                      'Resolved',
                                      'Closed',
                                    ]
                                        .map(
                                          (e) => DropdownMenuItem<String>(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null || value == issue.status) return;
                                      _changeStatus(value);
                                    },
                                  )
                                else
                                  Text(
                                    issue.status,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                const Spacer(),
                                if (issue.attachmentPath != null &&
                                    issue.attachmentPath!.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: _openAttachment,
                                    icon: const Icon(Icons.attach_file_rounded),
                                    label: Text(
                                      issue.attachmentName?.isNotEmpty == true
                                          ? issue.attachmentName!
                                          : 'Open Attachment',
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Comments',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            if (_canAddComment)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _commentController,
                                      minLines: 3,
                                      maxLines: 5,
                                      decoration: const InputDecoration(
                                        hintText: 'Write a comment...',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _savingComment ? null : _submitComment,
                                          icon: const Icon(Icons.send_rounded),
                                          label: Text(
                                            _savingComment ? 'Posting...' : 'Add Comment',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (_canAddComment) const SizedBox(height: 16),
                            if (issue.comments.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'No comments yet.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: issue.comments.map((comment) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.message,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          comment.createdAtDisplay,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
      ),
    );
  }
}