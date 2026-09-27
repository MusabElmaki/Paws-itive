import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class _RankedVolunteer {
  const _RankedVolunteer(this.name, this.points, this.casesHandled);
  final String name;
  final int points;
  final int casesHandled;
}

const _rankings = [
  _RankedVolunteer('Nur Aisyah', 340, 18),
  _RankedVolunteer('Lim Wei Jian', 305, 15),
  _RankedVolunteer('Musab Yusof', 280, 14),
  _RankedVolunteer('Tan Mei Ling', 210, 10),
  _RankedVolunteer('Faris Rahman', 165, 8),
];

/// Demo-only screen: hardcoded leaderboard rankings for Sprint 4
/// presentation. The "real" Firestore-backed leaderboard already exists
/// at /leaderboard for the volunteer-facing flow.
class AdminLeaderboardScreen extends StatelessWidget {
  const AdminLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: Icon(Icons.emoji_events, size: 72, color: Colors.amber),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Top Volunteers This Month',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_rankings.length, (index) {
            final volunteer = _rankings[index];
            final rank = index + 1;

            final rankColor = switch (rank) {
              1 => Colors.amber,
              2 => Colors.grey,
              3 => Colors.orange,
              _ => AppTheme.primary,
            };

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: rankColor,
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  volunteer.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${volunteer.casesHandled} cases handled'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text('${volunteer.points} pts'),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
