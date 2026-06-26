import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/empty_state.dart';

/// Volunteer-facing case list with a "Help" button so volunteers can mark
/// themselves as helping with a specific animal, per stakeholder
/// requirement ("there will be a feature to participate in helping the
/// cat"). Writes the volunteer's uid into `reports/{id}.helpingVolunteers`.
class VolunteerCasesScreen extends StatelessWidget {
  const VolunteerCasesScreen({super.key});

  Future<void> _toggleHelping(
    BuildContext context,
    String reportId,
    List<dynamic> currentHelpers,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isHelping = currentHelpers.contains(user.uid);
    final reportRef = FirebaseFirestore.instance.collection('reports').doc(reportId);

    try {
      await reportRef.update({
        'helpingVolunteers': isHelping
            ? FieldValue.arrayRemove([user.uid])
            : FieldValue.arrayUnion([user.uid]),
      });

      // Notify the volunteer of the action (closes the notification gap
      // for the volunteer-participation flow too).
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'title': isHelping ? 'Stopped helping case' : 'You are now helping',
        'message': isHelping
            ? 'You are no longer marked as helping this case.'
            : 'You have volunteered to help with this case. Thank you!',
        'reportId': reportId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHelping
                  ? 'No longer marked as helping'
                  : 'Marked as helping this case',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Animal Cases')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const EmptyState(
              title: 'No cases yet',
              message: 'Reported animal cases will appear here',
              buttonLabel: '',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final doc = reports[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = (data['healthStatus'] ?? 'Unknown').toString();
              final helpers = (data['helpingVolunteers'] as List?) ?? [];
              final isHelping = currentUser != null &&
                  helpers.contains(currentUser.uid);

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: data['imageBase64'] != null
                                ? Image.memory(
                                    base64Decode(data['imageBase64']),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.pets),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['catName'] ?? data['animalType'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        data['location'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                StatusChip(status: status, compact: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.groups,
                            size: 16,
                            color: AppTheme.text.withValues(alpha: 0.55),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${helpers.length} volunteer${helpers.length == 1 ? '' : 's'} helping',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.text.withValues(alpha: 0.55),
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () => _toggleHelping(
                              context,
                              doc.id,
                              helpers,
                            ),
                            icon: Icon(
                              isHelping
                                  ? Icons.check_circle
                                  : Icons.volunteer_activism,
                              size: 18,
                            ),
                            label: Text(isHelping ? 'Helping' : 'Help'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              foregroundColor: isHelping
                                  ? AppTheme.success
                                  : AppTheme.primary,
                              side: BorderSide(
                                color: isHelping
                                    ? AppTheme.success
                                    : AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
