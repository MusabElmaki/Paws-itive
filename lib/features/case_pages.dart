part of 'feature_pages.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CatReport>>(
      stream: FirestoreGateway.instance.watchReports(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
        final reports = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PagedCollectionPage(
                    title: 'All reports',
                    query: FirebaseFirestore.instance
                        .collection('reports')
                        .orderBy('createdAt', descending: true),
                    itemBuilder: (ctx, doc) =>
                        doc.data()['archived'] == true ||
                            doc.data()['linkedTo'] != null
                        ? const SizedBox.shrink()
                        : _AdminReportCard(
                            report: CatReport.fromMap(doc.id, doc.data()),
                            profile: profile,
                          ),
                  ),
                ),
              ),
              child: const Text('All reports (browse history)'),
            ),

            const PageHeader(
              title: 'Reports',
              subtitle:
                  'Every submitted report and its volunteer workflow status.',
              icon: Icons.fact_check_outlined,
            ),
            const SizedBox(height: 16),
            if (snapshot.hasError)
              _ErrorPanel(error: snapshot.error!)
            else if (reports.isEmpty)
              const EmptyStatePanel(
                icon: Icons.assignment_outlined,
                title: 'No reports yet',
                subtitle:
                    'User submissions will appear here once the platform receives reports.',
              )
            else
              ...reports.map(
                (report) => _AdminReportCard(report: report, profile: profile),
              ),
          ],
        );
      },
    );
  }
}

class _AdminReportCard extends StatelessWidget {
  const _AdminReportCard({required this.report, required this.profile});

  final CatReport report;
  final AppUserProfile profile;

  Future<void> _assign(BuildContext context) async {
    final users = await FirestoreGateway.instance.watchAllUsers().first;
    final volunteers = users
        .where(
          (u) =>
              u.role == UserRole.volunteer &&
              u.isApprovedVolunteer &&
              !u.isSuspended &&
              u.status == UserStatus.active,
        )
        .toList();
    if (!context.mounted) return;
    if (volunteers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No volunteers registered yet.')),
      );
      return;
    }
    final selected = await showModalBottomSheet<AppUserProfile>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Assign to volunteer',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            ...volunteers.map(
              (v) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(v.fullName),
                subtitle: Text(v.email),
                onTap: () => Navigator.pop(ctx, v),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await FirestoreGateway.instance.assignReport(
      report.id,
      volunteerId: selected.uid,
      status: ReportStatus.beingAssisted,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned to ${selected.fullName}.')),
      );
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This permanently removes the report.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirestoreGateway.instance.deleteReport(report.id);
    }
  }

  /// Admin changes the case status. When marking a case **resolved**, the
  /// volunteer who was assigned to it is credited with the resolve points.
  Future<void> _setStatus(BuildContext context, ReportStatus status) =>
      runAction(
        context,
        () => FirestoreGateway.instance.setReportStatus(report.id, status),
        success: 'Case updated.',
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatThumb(
                  url: report.photoUrl.isNotEmpty ? report.photoUrl : null,
                  size: 64,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.locationName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if ([
                        'Critical',
                        'Injured',
                      ].contains(report.reportedCondition))
                        const Text(
                          'URGENT',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        'By ${report.reporterName.isEmpty ? 'Unknown' : report.reporterName} • ${_formatDate(report.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (report.catName.isNotEmpty ||
                          report.reportedCondition.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 6,
                            children: [
                              if (report.catName.isNotEmpty)
                                _StatusPill(label: '🐾 ${report.catName}'),
                              if (report.reportedCondition.isNotEmpty)
                                _StatusPill(label: report.reportedCondition),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        report.description.isEmpty
                            ? 'No description'
                            : report.description,
                      ),
                    ],
                  ),
                ),
                _StatusPill(label: report.status.label),
              ],
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                PopupMenuButton<ReportStatus>(
                  onSelected: (status) => _setStatus(context, status),
                  itemBuilder: (_) => ReportStatus.values
                      .map(
                        (s) => PopupMenuItem(
                          value: s,
                          child: Text('Mark: ${s.label}'),
                        ),
                      )
                      .toList(),
                  child: const _ActionChip(
                    icon: Icons.flag_outlined,
                    label: 'Status',
                  ),
                ),
                InkWell(
                  onTap: () => runAction(context, () => _assign(context)),
                  child: const _ActionChip(
                    icon: Icons.person_add_alt,
                    label: 'Assign',
                  ),
                ),
                if (report.catId != null)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CatProfileDetailPage(
                          catId: report.catId!,
                          profile: profile,
                        ),
                      ),
                    ),
                    child: const _ActionChip(
                      icon: Icons.pets_outlined,
                      label: 'Cat',
                    ),
                  ),
                InkWell(
                  onTap: () => runAction(context, () => _delete(context)),
                  child: const _ActionChip(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    danger: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.error : AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class VolunteerCasesPage extends StatelessWidget {
  const VolunteerCasesPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CatReport>>(
      stream: FirestoreGateway.instance.watchReports(onlyActive: true),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
        final reports = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PagedCollectionPage(
                    title: 'All active cases',
                    query: FirebaseFirestore.instance
                        .collection('reports')
                        .where(
                          'status',
                          whereIn: ['reported', 'underReview', 'beingAssisted'],
                        )
                        .orderBy('createdAt', descending: true),
                    itemBuilder: (ctx, doc) =>
                        doc.data()['archived'] == true ||
                            doc.data()['linkedTo'] != null
                        ? const SizedBox.shrink()
                        : _VolunteerCaseCard(
                            report: CatReport.fromMap(doc.id, doc.data()),
                            profile: profile,
                          ),
                  ),
                ),
              ),
              child: const Text('All active cases (browse history)'),
            ),

            const PageHeader(
              title: 'Volunteer cases',
              subtitle:
                  'Handle reported cats, review statuses, and close active cases.',
              icon: Icons.volunteer_activism,
            ),
            const SizedBox(height: 16),
            if (snapshot.hasError)
              _ErrorPanel(error: snapshot.error!)
            else if (reports.isEmpty)
              const EmptyStatePanel(
                icon: Icons.assignment_turned_in_outlined,
                title: 'No active cases',
                subtitle:
                    'Volunteer assignments will appear when users submit reports.',
              )
            else
              ...reports.map(
                (report) =>
                    _VolunteerCaseCard(report: report, profile: profile),
              ),
          ],
        );
      },
    );
  }
}

class _VolunteerCaseCard extends StatelessWidget {
  const _VolunteerCaseCard({required this.report, required this.profile});

  final CatReport report;
  final AppUserProfile profile;

  bool get _mine => report.assignedVolunteerId == profile.uid;
  bool get _unassigned =>
      report.assignedVolunteerId == null || report.assignedVolunteerId!.isEmpty;

  Future<void> _accept(BuildContext context) => runAction(
    context,
    () => FirestoreGateway.instance.assignReport(
      report.id,
      volunteerId: profile.uid,
    ),
    success: 'Case accepted.',
  );
  Future<void> _setStatus(BuildContext context, ReportStatus status) =>
      runAction(
        context,
        () => FirestoreGateway.instance.setReportStatus(report.id, status),
        success: 'Case updated.',
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatThumb(
                  url: report.photoUrl.isNotEmpty ? report.photoUrl : null,
                  size: 64,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.locationName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if ([
                        'Critical',
                        'Injured',
                      ].contains(report.reportedCondition))
                        const Text(
                          'URGENT',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (report.catName.isNotEmpty ||
                          report.reportedCondition.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 6,
                            children: [
                              if (report.catName.isNotEmpty)
                                _StatusPill(label: '🐾 ${report.catName}'),
                              if (report.reportedCondition.isNotEmpty)
                                _StatusPill(label: report.reportedCondition),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        report.description.isEmpty
                            ? 'No description'
                            : report.description,
                      ),
                      if (_mine)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Assigned to you',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _StatusPill(label: report.status.label),
              ],
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (_unassigned)
                  InkWell(
                    onTap: () => _accept(context),
                    child: const _ActionChip(
                      icon: Icons.handshake_outlined,
                      label: 'Accept',
                    ),
                  )
                else if (_mine) ...[
                  PopupMenuButton<ReportStatus>(
                    onSelected: (status) => _setStatus(context, status),
                    itemBuilder: (_) => ReportStatus.values
                        .where(
                          (s) =>
                              (report.status == ReportStatus.reported &&
                                  s == ReportStatus.underReview) ||
                              (report.status == ReportStatus.beingAssisted &&
                                  s == ReportStatus.resolved),
                        )
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Text('Mark: ${s.label}'),
                          ),
                        )
                        .toList(),
                    child: const _ActionChip(
                      icon: Icons.flag_outlined,
                      label: 'Status',
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        _showFundRequestDialog(context, profile, report),
                    child: const _ActionChip(
                      icon: Icons.savings_outlined,
                      label: 'Call for fund',
                    ),
                  ),
                ] else
                  const _ActionChip(
                    icon: Icons.lock_outline,
                    label: 'Assigned',
                  ),
                if (report.catId != null)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CatProfileDetailPage(
                          catId: report.catId!,
                          profile: profile,
                        ),
                      ),
                    ),
                    child: const _ActionChip(
                      icon: Icons.pets_outlined,
                      label: 'Cat',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showFundRequestDialog(
  BuildContext context,
  AppUserProfile profile,
  CatReport report,
) async {
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  final submitted = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Request funding'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (RM)',
              prefixText: 'RM ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason (e.g. vet treatment)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Submit'),
        ),
      ],
    ),
  );

  if (submitted != true) return;
  final amount = double.tryParse(amountController.text.trim()) ?? 0;
  if (!amount.isFinite ||
      amount <= 0 ||
      amount > 100000 ||
      reasonController.text.trim().isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount and reason.')),
      );
    }
    return;
  }
  await FirestoreGateway.instance.createFundRequest(
    catId: report.catId ?? report.id,
    catName: report.locationName,
    requestedBy: profile.uid,
    requestedByName: profile.fullName,
    amount: amount,
    reason: reasonController.text.trim(),
    reportId: report.id,
  );
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funding request submitted.')));
  }
}
