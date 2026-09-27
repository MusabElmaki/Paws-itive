part of 'feature_pages.dart';

class MapPage extends StatelessWidget {
  const MapPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CatProfile>>(
      stream: FirestoreGateway.instance.watchCats(),
      builder: (context, catsSnapshot) {
        return StreamBuilder<List<Clinic>>(
          stream: FirestoreGateway.instance.watchClinics(),
          builder: (context, clinicsSnapshot) {
            final cats = catsSnapshot.data ?? const [];
            final clinics = clinicsSnapshot.data ?? const [];

            final markers = <Marker>[
              for (final cat in cats)
                if (cat.latitude != null && cat.longitude != null)
                  Marker(
                    point: LatLng(cat.latitude!, cat.longitude!),
                    width: 46,
                    height: 46,
                    child: GestureDetector(
                      onTap: () => _showMapInfo(
                        context,
                        title: cat.name ?? 'Unnamed cat',
                        subtitle: cat.currentLocationName,
                        onView: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CatProfileDetailPage(
                              catId: cat.id,
                              profile: profile,
                            ),
                          ),
                        ),
                      ),
                      child: const _MapPin(
                        icon: Icons.pets,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              for (final clinic in clinics)
                Marker(
                  point: LatLng(clinic.latitude, clinic.longitude),
                  width: 46,
                  height: 46,
                  child: GestureDetector(
                    onTap: () => _showMapInfo(
                      context,
                      title: clinic.name,
                      subtitle: clinic.address,
                      phone: clinic.phone,
                    ),
                    child: _MapPin(
                      icon: Icons.local_hospital,
                      color: clinic.emergency
                          ? AppTheme.error
                          : AppTheme.success,
                    ),
                  ),
                ),
            ];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const PageHeader(
                  title: 'Map view',
                  subtitle:
                      'Cat locations, feeding zones, and nearby veterinary clinics.',
                  icon: Icons.map_outlined,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 380,
                    // OpenStreetMap via flutter_map (Leaflet-style) — no API key
                    // or billing required, so tiles always render.
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(1.5603, 103.6365),
                        initialZoom: 15,
                        minZoom: 3,
                        maxZoom: 19,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.utm_pawsitive',
                          maxZoom: 19,
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  markers.isEmpty
                      ? 'No cat or clinic locations yet — ask an admin to tap "Seed demo data".  © OpenStreetMap contributors'
                      : 'Tap a pin for details. Paw = cat sightings, hospital = clinics.  © OpenStreetMap contributors',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nearby clinics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (clinics.isEmpty)
                  const EmptyStatePanel(
                    icon: Icons.local_hospital_outlined,
                    title: 'No clinics configured',
                    subtitle:
                        'Ask an admin to run "Seed demo data" to display veterinary contacts.',
                  )
                else
                  ...clinics.map(
                    (clinic) => Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.local_hospital_outlined,
                          color: clinic.emergency
                              ? AppTheme.error
                              : AppTheme.primary,
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(clinic.name)),
                            if (clinic.emergency)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  '24H',
                                  style: TextStyle(
                                    color: AppTheme.error,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(clinic.address),
                            if (clinic.phone != null &&
                                clinic.phone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  clinic.phone!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing:
                            (clinic.phone != null && clinic.phone!.isNotEmpty)
                            ? IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: AppTheme.success,
                                ),
                                tooltip: 'Call ${clinic.name}',
                                onPressed: () =>
                                    _callPhone(context, clinic.phone!),
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Circular pin used for map markers (cats / clinics).
class _MapPin extends StatelessWidget {
  const _MapPin({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

/// Bottom-sheet "popup" shown when a map marker is tapped.
void _showMapInfo(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? phone,
  VoidCallback? onView,
}) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 18),
          Row(
            children: [
              if (onView != null)
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onView();
                  },
                  icon: const Icon(Icons.pets),
                  label: const Text('View profile'),
                ),
              if (phone != null && phone.isNotEmpty) ...[
                if (onView != null) const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _callPhone(context, phone);
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}

class CatsPage extends StatelessWidget {
  const CatsPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CatProfile>>(
      stream: FirestoreGateway.instance.watchCats(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
        final cats = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PagedCollectionPage(
                    title: 'All cat profiles',
                    query: FirebaseFirestore.instance
                        .collection('cats')
                        .orderBy('lastUpdated', descending: true),
                    itemBuilder: (ctx, doc) =>
                        doc.data()['archived'] == true ||
                            doc.data()['linkedTo'] != null
                        ? const SizedBox.shrink()
                        : ListTile(
                            title: Text(
                              doc.data()['name']?.toString() ?? 'Unnamed cat',
                            ),
                            subtitle: Text(
                              doc.data()['currentLocationName']?.toString() ??
                                  '',
                            ),
                            onTap: () => Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (_) => CatProfileDetailPage(
                                  catId: doc.id,
                                  profile: profile,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              child: const Text('All cat profiles (browse history)'),
            ),

            const PageHeader(
              title: 'Cat profiles',
              subtitle: 'Digital records for every tracked cat at UTM.',
              icon: Icons.pets_outlined,
            ),
            const SizedBox(height: 16),
            if (snapshot.hasError)
              _ErrorPanel(error: snapshot.error!)
            else if (cats.isEmpty)
              const EmptyStatePanel(
                icon: Icons.pets_outlined,
                title: 'No cats yet',
                subtitle:
                    'Profiles appear after the first report — or ask an admin to "Seed demo data".',
              )
            else
              ...cats.map(
                (cat) => Card(
                  child: ListTile(
                    leading: CatThumb(
                      url: cat.photoUrls.isNotEmpty
                          ? cat.photoUrls.first
                          : null,
                    ),
                    title: Text(cat.name ?? 'Unnamed cat'),
                    subtitle: Text(
                      '${cat.currentLocationName} • ${cat.currentStatus.label} • ${cat.healthStatus.label}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CatProfileDetailPage(
                          catId: cat.id,
                          profile: profile,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Square thumbnail that loads a cat photo from the network with a graceful
/// paw-icon fallback while loading or on error / when no photo exists.
class CatThumb extends StatelessWidget {
  const CatThumb({required this.url, this.size = 48, super.key});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: StoredPhoto(path: url, width: size, height: size),
    );
  }
}

class CatProfileDetailPage extends StatelessWidget {
  const CatProfileDetailPage({
    required this.catId,
    required this.profile,
    super.key,
  });

  final String catId;
  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile.role == UserRole.admin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat profile'),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Archive cat',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Archive cat profile?'),
                    content: const Text(
                      'This hides the profile from active lists and preserves its history.',
                    ),
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
                  await FirestoreGateway.instance.deleteCat(catId);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: StreamBuilder<CatProfile?>(
        stream: FirestoreGateway.instance.watchCat(catId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
          final cat = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cat == null) {
            return const EmptyStatePanel(
              icon: Icons.pets_outlined,
              title: 'Cat not found',
              subtitle: 'This profile may have been removed.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StoredPhoto(
                path: cat.photoUrls.isEmpty ? null : cat.photoUrls.first,
                height: 240,
              ),
              const SizedBox(height: 16),
              Text(
                cat.name ?? 'Unnamed cat',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(label: cat.currentStatus.label),
                  _StatusPill(label: cat.healthStatus.label),
                  _StatusPill(
                    label: cat.classification == CatClassification.domestic
                        ? 'Domestic'
                        : 'Stray',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileRow(
                        icon: Icons.place_outlined,
                        label: 'Location',
                        value: cat.currentLocationName.isEmpty
                            ? 'Unknown'
                            : cat.currentLocationName,
                      ),
                      if (cat.latitude != null && cat.longitude != null)
                        _ProfileRow(
                          icon: Icons.my_location_outlined,
                          label: 'Coords',
                          value:
                              '${cat.latitude!.toStringAsFixed(5)}, ${cat.longitude!.toStringAsFixed(5)}',
                        ),
                      _ProfileRow(
                        icon: Icons.update,
                        label: 'Updated',
                        value: _formatDate(cat.lastUpdated),
                      ),
                    ],
                  ),
                ),
              ),
              CareTimeline(catId: catId, profile: profile),
              if (cat.feedingHistory.isNotEmpty)
                _NotesCard(title: 'Feeding history', notes: cat.feedingHistory),
              if (cat.volunteerNotes.isNotEmpty)
                _NotesCard(title: 'Volunteer notes', notes: cat.volunteerNotes),
              if (cat.medicalNotes.isNotEmpty)
                _NotesCard(title: 'Medical notes', notes: cat.medicalNotes),
            ],
          );
        },
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.title, required this.notes});

  final String title;
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...notes.map(
                (note) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(note)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
