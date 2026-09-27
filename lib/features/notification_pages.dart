part of 'feature_pages.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<NotificationRecord>>(
        stream: FirestoreGateway.instance.watchNotifications(
          profile.uid,
          role: profile.role,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
          final notifications = snapshot.data ?? const [];
          if (notifications.isEmpty) {
            return const EmptyStatePanel(
              icon: Icons.notifications_none,
              title: 'No notifications yet',
              subtitle:
                  'Alerts for reports, assignments, funding, and status updates will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.body),
                  trailing:
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(profile.uid)
                            .collection('notification_reads')
                            .doc(item.id)
                            .snapshots(),
                        builder: (_, read) => IconButton(
                          icon: Icon(
                            read.data?.exists == true
                                ? Icons.check_circle
                                : Icons.mark_email_read_outlined,
                          ),
                          onPressed: () => runAction(context, () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(profile.uid)
                                .collection('notification_reads')
                                .doc(item.id)
                                .set({'readAt': FieldValue.serverTimestamp()});
                          }),
                        ),
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

String _formatDate(DateTime date) {
  final local = date.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

Future<void> _callPhone(BuildContext context, String rawPhone) async {
  final sanitized = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
  final uri = Uri(scheme: 'tel', path: sanitized);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not start a call to $rawPhone')),
    );
  }
}

class PaymentEvidence {
  const PaymentEvidence({
    required this.data,
    required this.type,
    required this.name,
  });

  final String data; // image: data URI; pdf: data:application/pdf;base64,...
  final String type; // 'image' | 'pdf'
  final String name;
}

/// Lets the donor pick a receipt (JPG/PNG/PDF). Images are compressed; PDFs are
/// size-checked before uploading to private Storage.
Future<PaymentEvidence?> _pickEvidence(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;
  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes == null) return null;

  final ext = (file.extension ?? '').toLowerCase();
  if (ext == 'pdf') {
    if (bytes.length > 4 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'PDF too large (max 4MB). Try a photo of the receipt.',
            ),
          ),
        );
      }
      return null;
    }
    return PaymentEvidence(
      data: 'data:application/pdf;base64,${base64Encode(bytes)}',
      type: 'pdf',
      name: file.name,
    );
  }

  final encoded = ImageUtil.encodeThumbnail(bytes, maxWidth: 1000, quality: 70);
  if (encoded == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read that image.')),
      );
    }
    return null;
  }
  return PaymentEvidence(data: encoded, type: 'image', name: file.name);
}

/// Dialog that asks the donor for proof of a manual (QR/DuitNow) transfer plus
/// an optional message. Returns true after the donation is recorded.
Future<bool> _showDonationEvidenceDialog(
  BuildContext context, {
  required AppUserProfile profile,
  required double amount,
}) async {
  final messageController = TextEditingController();
  PaymentEvidence? evidence;
  bool saving = false;
  final requestId = Workflows.instance.newId();

  final recorded = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Send payment proof'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Donation: RM ${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please attach your receipt or a screenshot of the transfer so an admin can verify your donation.',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: saving
                    ? null
                    : () async {
                        final picked = await _pickEvidence(ctx);
                        if (!ctx.mounted) return;
                        if (picked != null) setLocal(() => evidence = picked);
                      },
                icon: Icon(
                  evidence == null ? Icons.attach_file : Icons.check_circle,
                  color: evidence == null ? null : AppTheme.success,
                ),
                label: Text(evidence?.name ?? 'Attach receipt (image / PDF)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Message (optional)',
                  hintText: 'e.g. transferred via Maybank at 3pm',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: (evidence == null || saving)
                ? null
                : () async {
                    setLocal(() => saving = true);
                    try {
                      final chosen = evidence!;
                      final bytes = base64Decode(chosen.data.split(',').last);
                      final path =
                          'receipts/${profile.uid}/$requestId/receipt.${chosen.type == 'pdf' ? 'pdf' : 'jpg'}';
                      await Workflows.instance.upload(
                        path,
                        bytes,
                        chosen.type == 'pdf' ? 'application/pdf' : 'image/jpeg',
                      );
                      await Workflows.instance.call('submitManualDonation', {
                        'requestId': requestId,
                        'amount': amount,
                        'evidencePath': path,
                        'message': messageController.text.trim(),
                      });
                      if (ctx.mounted) Navigator.pop(ctx, true);
                    } catch (error) {
                      if (!ctx.mounted) return;
                      setLocal(() => saving = false);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Could not record: $error')),
                        );
                      }
                    }
                  },
            child: Text(saving ? 'Sending...' : 'Submit proof'),
          ),
        ],
      ),
    ),
  );
  return recorded == true;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
