import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text("Volunteer Leaderboard"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy(
              'volunteerScore',
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(
              child: Text(
                "No volunteers found",
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              const Center(
                child: Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Top Volunteers",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ...List.generate(users.length, (index) {
                final data =
                    users[index].data()
                        as Map<String, dynamic>;

                final rank = index + 1;

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          rank == 1
                              ? Colors.amber
                              : rank == 2
                                  ? Colors.grey
                                  : rank == 3
                                      ? Colors.orange
                                      : AppTheme.primary,
                      child: Text(
                        "$rank",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    title: Text(
                      data["name"] ?? "Unknown",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      data["role"] ?? "",
                    ),

                    trailing: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        Text(
                          "${data["volunteerScore"] ?? 0}",
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}