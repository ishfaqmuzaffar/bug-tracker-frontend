import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  Color _bgColor() {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppColors.success.withValues(alpha: 0.12);
      case 'medium':
        return AppColors.warning.withValues(alpha: 0.12);
      case 'high':
        return Colors.orange.withValues(alpha: 0.12);
      case 'critical':
        return AppColors.danger.withValues(alpha: 0.12);
      default:
        return AppColors.warning.withValues(alpha: 0.12);
    }
  }

  Color _textColor() {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return Colors.orange;
      case 'critical':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: _textColor(),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}