part of 'feature_pages.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late final Future<Map<String, int>> _countsFuture = FirestoreGateway.instance
      .computeCounts();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _countsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
        final counts = snapshot.data ?? const <String, int>{};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(
              title: 'Admin center',
              subtitle:
                  'Manage users, volunteers, donations, analytics, and system monitoring.',
              icon: Icons.admin_panel_settings_outlined,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Users',
                  value: '${counts['users'] ?? 0}',
                  icon: Icons.group_outlined,
                ),
                _MetricCard(
                  label: 'Reports',
                  value: '${counts['reports'] ?? 0}',
                  icon: Icons.assignment_outlined,
                ),
                _MetricCard(
                  label: 'Cats',
                  value: '${counts['cats'] ?? 0}',
                  icon: Icons.pets_outlined,
                ),
                _MetricCard(
                  label: 'Donations',
                  value: '${counts['donations'] ?? 0}',
                  icon: Icons.volunteer_activism_outlined,
                ),
                _MetricCard(
                  label: 'Shop items',
                  value: '${counts['shopItems'] ?? 0}',
                  icon: Icons.storefront_outlined,
                ),
                _MetricCard(
                  label: 'Clinics',
                  value: '${counts['clinics'] ?? 0}',
                  icon: Icons.local_hospital_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: const Text('Manage users'),
                subtitle: const Text(
                  'Review volunteer applications, edit roles, and suspend accounts',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdminUsersPage(profile: widget.profile),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_outlined),
                title: const Text('Treasury'),
                subtitle: const Text(
                  'Donations, shop sales, and fund allocations',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdminTreasuryPage(profile: widget.profile),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Fund requests'),
                subtitle: const Text(
                  'Approve and assign money to funding cases',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminFundRequestsPage(profile: widget.profile),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({required this.profile, super.key});

  final AppUserProfile profile;

  Future<void> _editUser(BuildContext context, AppUserProfile user) async {
    UserRole role = user.role;
    bool suspended = user.isSuspended;
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(user.fullName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.email, style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: UserRole.values
                    .map(
                      (r) => DropdownMenuItem(value: r, child: Text(r.label)),
                    )
                    .toList(),
                onChanged: (v) => setLocal(() => role = v ?? role),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Suspended'),
                value: suspended,
                onChanged: (v) => setLocal(() => suspended = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (action == 'save') {
      await FirestoreGateway.instance.updateUser(user.uid, {
        'role': role.name,
        'isApprovedVolunteer':
            role == UserRole.volunteer || role == UserRole.admin,
        'isSuspended': suspended,
        'status': suspended ? 'suspended' : 'active',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage users'),
        actions: [
          IconButton(
            tooltip: 'Volunteer applications',
            icon: const Icon(Icons.pending_actions),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const VolunteerApplicationsPage(),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<AppUserProfile>>(
        stream: FirestoreGateway.instance.watchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
          final users = snapshot.data ?? const <AppUserProfile>[];
          if (users.isEmpty) {
            return const EmptyStatePanel(
              icon: Icons.group_outlined,
              title: 'No users',
              subtitle: 'Registered accounts will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: AppTheme.primary),
                    ),
                  ),
                  title: Text(user.fullName),
                  subtitle: Text(
                    '${user.email}\n${user.role.label}${user.isSuspended ? ' • SUSPENDED' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        runAction(context, () => _editUser(context, user)),
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

class AdminTreasuryPage extends StatelessWidget {
  const AdminTreasuryPage({required this.profile, super.key});
  final AppUserProfile profile;
  @override
  Widget build(BuildContext context) => const VerifiedTreasuryPage();
}

class AdminFundRequestsPage extends StatelessWidget {
  const AdminFundRequestsPage({required this.profile, super.key});

  final AppUserProfile profile;

  Future<void> _allocate(
    BuildContext context,
    Map<String, dynamic> request,
  ) async {
    final amount = (request['amount'] as num?)?.toDouble() ?? 0;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve & reserve funds'),
        content: Text(
          'Allocate RM ${amount.toStringAsFixed(2)} for "${request['catName'] ?? 'cat'}"?\n\nReason: ${request['reason'] ?? ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await FirestoreGateway.instance.reviewFundRequest(
      requestId: request['id'] as String,
      approve: true,
      reviewedBy: profile.uid,
      note: 'Allocated RM ${amount.toStringAsFixed(2)}',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Funding approved and reserved. Record the transfer when it is disbursed.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fund requests')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreGateway.instance.watchFundRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
          final requests = snapshot.data ?? const [];
          if (requests.isEmpty) {
            return const EmptyStatePanel(
              icon: Icons.savings_outlined,
              title: 'No fund requests',
              subtitle:
                  'Volunteers can request funding from their accepted cases.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final r = requests[index];
              final status = (r['status'] ?? 'pending').toString();
              final amount = (r['amount'] as num?)?.toDouble() ?? 0;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'RM ${amount.toStringAsFixed(2)} • ${r['catName'] ?? 'Cat'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          _StatusPill(label: status.toUpperCase()),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(r['reason']?.toString() ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        'Requested by ${r['requestedByName'] ?? r['requestedBy'] ?? 'volunteer'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (status == 'approved')
                        Wrap(
                          children: [
                            TextButton(
                              onPressed: () => recordDisbursement(
                                context,
                                r['id'] as String,
                              ),
                              child: const Text('Record disbursement'),
                            ),
                            TextButton(
                              onPressed: () => runAction(
                                context,
                                () =>
                                    FirestoreGateway.instance.reviewFundRequest(
                                      requestId: r['id'] as String,
                                      approve: false,
                                      reviewedBy: profile.uid,
                                      note: 'Reservation cancelled',
                                    ),
                              ),
                              child: const Text('Cancel reservation'),
                            ),
                          ],
                        ),
                      if (status == 'pending') ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton(
                              onPressed: () => runAction(
                                context,
                                () => _allocate(context, r),
                              ),
                              child: const Text('Approve & reserve'),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  FirestoreGateway.instance.reviewFundRequest(
                                    requestId: r['id'] as String,
                                    approve: false,
                                    reviewedBy: profile.uid,
                                    note: 'Rejected',
                                  ),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                      ],
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
