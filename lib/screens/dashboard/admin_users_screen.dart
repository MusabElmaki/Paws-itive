import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class _SampleUser {
  const _SampleUser(this.name, this.email, this.role, this.status);
  final String name;
  final String email;
  final String role;
  final String status;
}

const _sampleUsers = [
  _SampleUser('Ahmad Daniel', 'ahmad.daniel@graduate.utm.my', 'Admin', 'Active'),
  _SampleUser('Nur Aisyah', 'aisyah.nur@graduate.utm.my', 'Volunteer', 'Active'),
  _SampleUser('Lim Wei Jian', 'weijian.lim@graduate.utm.my', 'Volunteer', 'Active'),
  _SampleUser('Musab Yusof', 'musab.yusof@graduate.utm.my', 'Volunteer', 'Active'),
  _SampleUser('Tan Mei Ling', 'meiling.tan@graduate.utm.my', 'User', 'Active'),
  _SampleUser('Faris Rahman', 'faris.rahman@graduate.utm.my', 'User', 'Suspended'),
  _SampleUser('Siti Hawa', 'siti.hawa@graduate.utm.my', 'User', 'Active'),
];

/// Demo-only screen: hardcoded sample users for Sprint 4 presentation.
/// Not wired to Firestore — intentionally out of scope for this sprint.
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Users')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleUsers.length,
        itemBuilder: (context, index) {
          final user = _sampleUsers[index];
          final isActive = user.status == 'Active';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.14),
                child: Text(
                  user.name.substring(0, 1),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(user.role),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppTheme.accent.withValues(
                            alpha: 0.18,
                          ),
                          side: BorderSide.none,
                        ),
                        Chip(
                          label: Text(user.status),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: isActive
                              ? AppTheme.success.withValues(alpha: 0.14)
                              : AppTheme.error.withValues(alpha: 0.12),
                          labelStyle: TextStyle(
                            color: isActive
                                ? AppTheme.success
                                : AppTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
