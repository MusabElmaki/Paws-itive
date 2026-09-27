part of 'feature_pages.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: FirestoreGateway.instance.watchLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
        final entries = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(
              title: 'Community rankings',
              subtitle:
                  'Points from volunteering, donating, and shop support — climb the tiers for bigger discounts.',
              icon: Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 16),
            if (snapshot.hasError)
              _ErrorPanel(error: snapshot.error!)
            else if (entries.isEmpty)
              const EmptyStatePanel(
                icon: Icons.emoji_events_outlined,
                title: 'No ranking data yet',
                subtitle:
                    'Points will populate when volunteers start submitting updates and closing cases.',
              )
            else
              ...entries.asMap().entries.map((entry) {
                final tier = rankTierFor(entry.value.points);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${entry.key + 1}')),
                    title: Text('${tier.emoji} ${entry.value.name}'),
                    subtitle: Text(
                      '${tier.label} • ${entry.value.casesClosed} cases • ${entry.value.healthUpdates} health',
                    ),
                    trailing: Text(
                      '${entry.value.points} pts',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
            backgroundImage:
                (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                ? const Icon(Icons.person, size: 44, color: AppTheme.primary)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PaymentHistoryPage(uid: profile.uid),
            ),
          ),
          child: const Text('Payment history'),
        ),
        Center(
          child: Text(
            profile.fullName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Center(
          child: Text(
            profile.role.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: profile.email,
                ),
                if (profile.phoneNumber != null &&
                    profile.phoneNumber!.isNotEmpty)
                  _ProfileRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: profile.phoneNumber!,
                  ),
                if (profile.bio.isNotEmpty)
                  _ProfileRow(
                    icon: Icons.info_outline,
                    label: 'Bio',
                    value: profile.bio,
                  ),
                _ProfileRow(
                  icon: Icons.stars_outlined,
                  label: 'Points',
                  value: '${profile.points}',
                ),
                _ProfileRow(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Rank tier',
                  value:
                      '${rankTierFor(profile.points).emoji} ${rankTierFor(profile.points).label} • ${(rankTierFor(profile.points).discount * 100).toStringAsFixed(0)}% shop discount',
                ),
                if (profile.role == UserRole.volunteer)
                  _ProfileRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Volunteer',
                    value: profile.isApprovedVolunteer
                        ? 'Approved'
                        : 'Pending approval',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (profile.role == UserRole.volunteer)
          VolunteerAvailability(uid: profile.uid),
        if (profile.role == UserRole.volunteer)
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FundraisingManagePage(profile: profile),
              ),
            ),
            icon: const Icon(Icons.savings_outlined),
            label: const Text('My fundraising projects'),
          ),
        if (profile.role == UserRole.volunteer) const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DonatePage(profile: profile)),
          ),
          icon: const Icon(Icons.volunteer_activism),
          label: const Text('Make a donation'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => AuthService.instance.signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}

class FundraisingManagePage extends StatelessWidget {
  const FundraisingManagePage({required this.profile, super.key});

  final AppUserProfile profile;

  Future<void> _edit(
    BuildContext context, [
    FundraisingProject? existing,
  ]) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    final goalController = TextEditingController(
      text: existing?.goalAmount.toStringAsFixed(0) ?? '',
    );
    final imageController = TextEditingController(
      text: existing?.imageUrl ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null ? 'New fundraising project' : 'Edit project',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: goalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Goal amount (RM)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final goal = double.tryParse(goalController.text.trim()) ?? 0;
    if (titleController.text.trim().isEmpty || goal <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a title and a valid goal.')),
        );
      }
      return;
    }
    try {
      await FirestoreGateway.instance.createFundraising(
        FundraisingProject(
          id: existing?.id ?? '',
          title: titleController.text.trim(),
          description: descController.text.trim(),
          goalAmount: goal,
          raisedAmount: existing?.raisedAmount ?? 0,
          createdBy: profile.uid,
          createdByName: profile.fullName,
          imageUrl: imageController.text.trim().isEmpty
              ? null
              : imageController.text.trim(),
          createdAt: existing?.createdAt ?? DateTime.now(),
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existing == null ? 'Project created.' : 'Project updated.',
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My fundraising')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => runAction(context, () => _edit(context)),
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
      body: StreamBuilder<List<FundraisingProject>>(
        stream: FirestoreGateway.instance.watchFundraising(
          createdBy: profile.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
          if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
          final projects = snapshot.data ?? const <FundraisingProject>[];
          if (projects.isEmpty) {
            return const EmptyStatePanel(
              icon: Icons.savings_outlined,
              title: 'No projects yet',
              subtitle:
                  'Tap "New project" to start raising funds for a cat in need.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: projects
                .map(
                  (p) => FundraisingCard(
                    project: p,
                    profile: profile,
                    onManage: () => runAction(context, () => _edit(context, p)),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
