import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'dashboard_widgets.dart';
import 'volunteer_map_preview_screen.dart';
import 'volunteer_apply_fund_screen.dart';
import 'volunteer_cases_screen.dart';
import 'clinics_screen.dart';

/// Sprint 4 demo: Volunteer Dashboard. Reached directly from the
/// "Login as Volunteer" button on the login screen.
class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Volunteer Dashboard'),
        actions: const [DashboardLogoutAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const DashboardHeaderBanner(
            greeting: 'Welcome back, Volunteer 👋',
            title: 'UTM Paws-itive',
          ),
          const SizedBox(height: 24),

          Text(
            'Volunteer Tools',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.pets,
            title: 'Animal Cases',
            subtitle: 'View reported animals and mark cases you\'re helping with',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VolunteerCasesScreen()),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.map,
            title: 'Map Preview',
            subtitle: 'Visualize reported animal locations on campus',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VolunteerMapPreviewScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.request_quote,
            title: 'Apply for Fund',
            subtitle: 'Request funding for animal care expenses',
            iconColor: AppTheme.success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VolunteerApplyFundScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.local_hospital,
            title: 'Clinics & Careline',
            subtitle: 'Nearby veterinary contacts for urgent cases',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ClinicsScreen()),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.emoji_events,
            title: 'Leaderboard',
            subtitle: 'See how you rank among fellow volunteers',
            onTap: () => Navigator.pushNamed(context, '/leaderboard'),
          ),
        ],
      ),
    );
  }
}
