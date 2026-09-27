import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, this.compact = false, super.key});

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: style.border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 10 : 13, color: style.foreground),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status,
            style: TextStyle(
              color: style.foreground,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String value) {
    switch (value.toLowerCase()) {
      case 'healthy':
        return _StatusStyle(
          foreground: AppTheme.success,
          background: AppTheme.success.withValues(alpha: 0.12),
          border: AppTheme.success.withValues(alpha: 0.26),
          icon: Icons.check_circle,
        );
      case 'needs feeding':
        return _StatusStyle(
          foreground: const Color(0xFF8A5E20),
          background: AppTheme.accent.withValues(alpha: 0.16),
          border: AppTheme.accent.withValues(alpha: 0.34),
          icon: Icons.restaurant,
        );
      case 'injured':
        return _StatusStyle(
          foreground: AppTheme.error,
          background: AppTheme.error.withValues(alpha: 0.10),
          border: AppTheme.error.withValues(alpha: 0.26),
          icon: Icons.medical_services,
        );
      case 'sick':
        return _StatusStyle(
          foreground: const Color(0xFF7B669B),
          background: const Color(0xFF7B669B).withValues(alpha: 0.12),
          border: const Color(0xFF7B669B).withValues(alpha: 0.30),
          icon: Icons.health_and_safety,
        );
      default:
        return _StatusStyle(
          foreground: Colors.grey.shade700,
          background: Colors.grey.withValues(alpha: 0.14),
          border: Colors.grey.withValues(alpha: 0.30),
          icon: Icons.help_outline,
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.foreground,
    required this.background,
    required this.border,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final Color border;
  final IconData icon;
}
