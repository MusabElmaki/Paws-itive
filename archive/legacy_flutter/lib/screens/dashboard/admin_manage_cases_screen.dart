import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/empty_state.dart';

/// Uses the EXISTING `reports` collection (same one HomeScreen reads from)
/// so admins can see and update real animal case reports.
class AdminManageCasesScreen extends StatelessWidget {
  const AdminManageCasesScreen({super.key});

  static const _statusOptions = [
    'Healthy',
    'Needs Feeding',
    'Injured',
    'Sick',
  ];

  Future<void> _updateStatus(
    BuildContext context,
    String reportId,
    String currentStatus,
  ) async {
    final newStatus = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Update case status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ..._statusOptions.map(
                (status) => ListTile(
                  title: Text(status),
                  trailing: status == currentStatus
                      ? const Icon(
                          Icons.check_circle,
                          color: AppTheme.success,
                        )
                      : null,
                  onTap: () => Navigator.pop(sheetContext, status),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (newStatus == null || newStatus == currentStatus) return;

    await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
      'healthStatus': newStatus,
    });

    // Notify the reporting user that their case status changed (closes
    // another gap in the report→notification flow: previously status
    // changes were silent).
    final reportDoc =
        await FirebaseFirestore.instance.collection('reports').doc(reportId).get();
    final reportData = reportDoc.data();
    final reportedByUid = reportData?['userId'];

    if (reportedByUid != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': reportedByUid,
        'title': 'Case status updated',
        'message': 'Your reported case is now marked as "$newStatus".',
        'reportId': reportId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Case marked as "$newStatus"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Manage Cases')),
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
              message: 'Reported animal cases will appear here for review',
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

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: data['imageBase64'] != null
                            ? Image.memory(
                                base64Decode(data['imageBase64']),
                                width: 84,
                                height: 84,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 84,
                                height: 84,
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
                              data['animalType'] ?? 'Unknown',
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
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.primary),
                        tooltip: 'Update status',
                        onPressed: () =>
                            _updateStatus(context, doc.id, status),
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
