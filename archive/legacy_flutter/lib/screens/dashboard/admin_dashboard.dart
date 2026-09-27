import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'dashboard_widgets.dart';
import 'admin_users_screen.dart';
import 'admin_leaderboard_screen.dart';
import 'admin_treasury_screen.dart';
import 'admin_manage_cases_screen.dart';
import 'clinics_screen.dart';

/// Sprint 4 demo: Admin Dashboard.
///
/// NOTE: This is a presentation-layer demo screen only. Access here is
/// granted purely by tapping "Login as Admin" on the login screen — there
/// is no real role-based access control wired up yet (by design, per
/// Sprint 4 scope).
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: const [DashboardLogoutAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const DashboardHeaderBanner(
            greeting: 'Welcome back, Admin 👋',
            title: 'UTM Paws-itive',
          ),
          const SizedBox(height: 18),

          // Quick stats row
          const Row(
            children: [
              DashboardStatTile(
                label: 'Open Cases',
                value: '12',
                icon: Icons.assignment_late,
              ),
              SizedBox(width: 12),
              DashboardStatTile(
                label: 'Volunteers',
                value: '34',
                icon: Icons.groups,
              ),
              SizedBox(width: 12),
              DashboardStatTile(
                label: 'Treasury (RM)',
                value: '2,480',
                icon: Icons.savings,
                color: AppTheme.success,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Administration',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.pets,
            title: 'Manage Cases',
            subtitle: 'Review and update reported animal cases',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminManageCasesScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.people,
            title: 'Users',
            subtitle: 'View registered users and volunteers',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.emoji_events,
            title: 'Leaderboard',
            subtitle: 'Top-ranked volunteers this month',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminLeaderboardScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.account_balance_wallet,
            title: 'Treasury',
            subtitle: 'Club fund balance and recent transactions',
            iconColor: AppTheme.success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminTreasuryScreen()),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.local_hospital,
            title: 'Clinics & Careline',
            subtitle: 'Manage nearby veterinary contact information',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ClinicsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
