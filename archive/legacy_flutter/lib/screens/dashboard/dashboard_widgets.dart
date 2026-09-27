import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A tappable Material card used across all dashboard screens for quick
/// navigation actions (e.g. "Users", "Leaderboard", "Report Animal").
class DashboardActionCard extends StatelessWidget {
  const DashboardActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primary).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.text.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small stat tile used for quick summary numbers at the top of a
/// dashboard (e.g. total cases, balance, rank).
class DashboardStatTile extends StatelessWidget {
  const DashboardStatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: color ?? AppTheme.primary, size: 22),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.text.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable header banner matching the existing HomeScreen visual style.
class DashboardHeaderBanner extends StatelessWidget {
  const DashboardHeaderBanner({
    required this.greeting,
    required this.title,
    super.key,
  });

  final String greeting;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple logout button reused across all three dashboards. Demo-only: it
/// just routes back to the login screen, no FirebaseAuth sign-out required
/// since the demo buttons bypass real authentication.
class DashboardLogoutAction extends StatelessWidget {
  const DashboardLogoutAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      icon: const Icon(Icons.logout),
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      },
    );
  }
}
