import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final name = userData["name"] ?? "User";
          final email = userData["email"] ?? "";
          final role = userData["role"] ?? "Student";

          final reportsCount =
              userData["reportsCount"] ?? 0;

          final volunteerScore =
              userData["volunteerScore"] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : "U",
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Reports",
                      reportsCount.toString(),
                      Icons.assignment,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      "Score",
                      volunteerScore.toString(),
                      Icons.emoji_events,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text("Name"),
                        subtitle: Text(name),
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text("Email"),
                        subtitle: Text(email),
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.badge),
                        title: const Text("Role"),
                        subtitle: Text(role),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/edit-profile',
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/leaderboard',
                  );
                },
                icon: const Icon(Icons.emoji_events),
                label: const Text(
                  "Volunteer Leaderboard",
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "My Reports",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("reports")
                    .where(
                      "userId",
                      isEqualTo: currentUser.uid,
                    )
                    .snapshots(),
                builder: (context, reportSnapshot) {
                  if (!reportSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final reports =
                      reportSnapshot.data!.docs;

                  if (reports.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "No reports submitted yet",
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: reports.map((doc) {
                      final report =
                          doc.data()
                              as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.pets),
                          ),

                          title: Text(
                            report["animalType"] ??
                                "Unknown",
                          ),

                          subtitle: Text(
                            report["location"] ?? "",
                          ),

                          trailing: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              report["healthStatus"] ??
                                  "",
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  static Widget _statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primary,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(title),
          ],
        ),
      ),
    );
  }
}