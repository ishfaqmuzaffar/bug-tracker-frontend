import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _bgColor() {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.info.withValues(alpha: 0.12);
      case 'in progress':
        return AppColors.warning.withValues(alpha: 0.12);
      case 'resolved':
        return AppColors.success.withValues(alpha: 0.12);
      case 'closed':
        return AppColors.textSecondary.withValues(alpha: 0.15);
      case 'reopened':
        return AppColors.danger.withValues(alpha: 0.12);
      default:
        return AppColors.info.withValues(alpha: 0.12);
    }
  }

  Color _textColor() {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.info;
      case 'in progress':
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return AppColors.textSecondary;
      case 'reopened':
        return AppColors.danger;
      default:
        return AppColors.info;
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
        status,
        style: TextStyle(
          color: _textColor(),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}