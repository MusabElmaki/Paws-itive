import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

/// Lets a User browse and "contact" volunteers, per stakeholder requirement.
/// Reads real volunteer accounts from the existing `users` collection
/// (role == 'Volunteer'). The "Message" action is a demo confirmation only
/// — no real chat/messaging backend is wired up yet.
class ContactVolunteersScreen extends StatelessWidget {
  const ContactVolunteersScreen({super.key});

  void _showContactDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Contact $name'),
        content: const Text(
          'In the full version, this will open a chat with the volunteer. '
          'For this demo, your request has been noted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Contact Volunteers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Volunteer')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final volunteers = snapshot.data!.docs;

          if (volunteers.isEmpty) {
            return const EmptyState(
              title: 'No volunteers yet',
              message: 'Registered volunteers will appear here so you can reach out',
              buttonLabel: '',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final data = volunteers[index].data() as Map<String, dynamic>;
              final name = (data['name'] ?? 'Volunteer').toString();
              final score = data['volunteerScore'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.14),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1) : '?',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$score volunteer points'),
                  trailing: FilledButton.tonalIcon(
                    onPressed: () => _showContactDialog(context, name),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Message'),
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
