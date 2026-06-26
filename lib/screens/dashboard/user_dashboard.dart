import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'dashboard_widgets.dart';
import 'donate_screen.dart';
import 'contact_volunteers_screen.dart';
import 'clinics_screen.dart';

/// Sprint 4 demo: User Dashboard. Reached directly from the
/// "Login as User" button on the login screen.
class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: const [DashboardLogoutAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const DashboardHeaderBanner(
            greeting: 'Welcome back 👋',
            title: 'UTM Paws-itive',
          ),
          const SizedBox(height: 24),

          Text(
            'What would you like to do?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.pets,
            title: 'Report Animal',
            subtitle: 'Spotted a stray? Submit a report with photo',
            onTap: () => Navigator.pushNamed(context, '/report'),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.volunteer_activism,
            title: 'Donate',
            subtitle: 'Support the club fund for animal welfare',
            iconColor: AppTheme.success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DonateScreen()),
            ),
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.connect_without_contact,
            title: 'Contact Volunteers',
            subtitle: 'Reach out to volunteers for help or questions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ContactVolunteersScreen(),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Browse',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          DashboardActionCard(
            icon: Icons.list_alt,
            title: 'View All Reports',
            subtitle: 'See animal reports submitted by the community',
            onTap: () => Navigator.pushNamed(context, '/home'),
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
        ],
      ),
    );
  }
}
