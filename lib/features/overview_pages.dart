part of 'feature_pages.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStatePanel extends StatelessWidget {
  const EmptyStatePanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: FirestoreGateway.instance.computeCounts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
        final counts = snapshot.data ?? const <String, int>{};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PageHeader(
              title: 'UTM Paws-itive',
              subtitle: profile.role == UserRole.admin
                  ? 'University-wide admin overview of stray cat operations.'
                  : 'Your central dashboard for cat reports, updates, and support.',
              icon: Icons.pets,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
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
                  label: 'Clinics',
                  value: '${counts['clinics'] ?? 0}',
                  icon: Icons.local_hospital_outlined,
                ),
              ],
            ),
            if (profile.role != UserRole.admin) ...[
              const SizedBox(height: 16),
              Card(
                color: AppTheme.success.withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.volunteer_activism,
                        color: AppTheme.success,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Support the cats',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Donate via QR / DuitNow to fund food and treatment.',
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DonatePage(profile: profile),
                          ),
                        ),
                        child: const Text('Donate'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (profile.role == UserRole.user) ...[
              const SizedBox(height: 16),
              Text(
                'My recent reports',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<CatReport>>(
                stream: FirestoreGateway.instance.watchReports(
                  reporterId: profile.uid,
                ),
                builder: (context, reportSnapshot) {
                  final myReports = reportSnapshot.data ?? const <CatReport>[];
                  if (myReports.isEmpty) {
                    return const EmptyStatePanel(
                      icon: Icons.assignment_outlined,
                      title: 'No reports yet',
                      subtitle:
                          'Use the Report tab to submit your first cat sighting.',
                    );
                  }
                  return Column(
                    children: myReports
                        .take(5)
                        .map(
                          (report) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.pets_outlined),
                              title: Text(report.locationName),
                              subtitle: Text(
                                report.description.isEmpty
                                    ? 'No description'
                                    : report.description,
                              ),
                              trailing: _StatusPill(label: report.status.label),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ] else
              const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({required this.profile, super.key});

  final AppUserProfile profile;

  Future<void> _joinAsVolunteer(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join as volunteer'),
        content: const Text(
          'Become a volunteer to help injured cats, manage cases, and start fundraising projects?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await Workflows.instance.requestVolunteer();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are now a volunteer! 🎉')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not update: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PageHeader(
          title: 'Welcome, ${profile.fullName.split(' ').first}!',
          subtitle:
              'Thanks for helping UTM\'s campus cats. Here\'s what\'s happening.',
          icon: Icons.waving_hand_outlined,
        ),
        const SizedBox(height: 16),
        if (profile.role == UserRole.user)
          Card(
            color: AppTheme.primary.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.volunteer_activism_outlined,
                    color: AppTheme.primary,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Want to do more?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Join as a volunteer to assist cases and raise funds.',
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _joinAsVolunteer(context),
                    child: const Text('Join'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Current fundraising',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Icon(Icons.savings_outlined, color: AppTheme.primary),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<FundraisingProject>>(
          stream: FirestoreGateway.instance.watchFundraising(onlyActive: true),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
            if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
            final projects = snapshot.data ?? const <FundraisingProject>[];
            if (projects.isEmpty) {
              return const EmptyStatePanel(
                icon: Icons.savings_outlined,
                title: 'No active fundraising',
                subtitle:
                    'Fundraising projects from volunteers will appear here.',
              );
            }
            return Column(
              children: projects
                  .map((p) => FundraisingCard(project: p, profile: profile))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        Text('Recent reports', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        StreamBuilder<List<CatReport>>(
          stream: FirestoreGateway.instance.watchReports(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
            if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
            final reports = (snapshot.data ?? const <CatReport>[])
                .take(5)
                .toList();
            if (reports.isEmpty) {
              return const EmptyStatePanel(
                icon: Icons.assignment_outlined,
                title: 'No reports yet',
                subtitle: 'Be the first to report a cat that needs help.',
              );
            }
            return Column(
              children: reports
                  .map(
                    (report) => Card(
                      child: ListTile(
                        leading: CatThumb(
                          url: report.photoUrl.isNotEmpty
                              ? report.photoUrl
                              : null,
                        ),
                        title: Text(report.locationName),
                        subtitle: Text(
                          report.description.isEmpty
                              ? 'No description'
                              : report.description,
                        ),
                        trailing: _StatusPill(label: report.status.label),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class FundraisingCard extends StatelessWidget {
  const FundraisingCard({
    required this.project,
    required this.profile,
    this.onManage,
    super.key,
  });

  final FundraisingProject project;
  final AppUserProfile profile;
  final VoidCallback? onManage;

  Future<void> _donate(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Donate to "${project.title}"'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: 'RM ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Donate'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final amount = double.tryParse(controller.text.trim()) ?? 0;
    if (!amount.isFinite || amount <= 0 || amount > 100000) return;

    if (!context.mounted) return;
    await openCheckout(
      context,
      kind: 'donation',
      amount: amount,
      projectId: project.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile.role == UserRole.admin;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatThumb(url: project.imageUrl, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'by ${project.createdByName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (onManage != null)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: onManage,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(project.description),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: project.progress,
                minHeight: 8,
                backgroundColor: AppTheme.border,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RM ${project.raisedAmount.toStringAsFixed(0)} of RM ${project.goalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text('${(project.progress * 100).toStringAsFixed(0)}%'),
              ],
            ),
            if (!isAdmin) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _donate(context),
                  icon: const Icon(Icons.favorite_outline),
                  label: const Text('Donate to this project'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.error.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppTheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Could not load data',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$error', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  const Text(
                    'If this says PERMISSION_DENIED, deploy the Firestore rules.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
