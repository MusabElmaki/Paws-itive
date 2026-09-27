import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/domain.dart';
import '../core/image_util.dart';
import '../core/workflows.dart';

Future<void> runAction(
  BuildContext context,
  Future<void> Function() action, {
  String success = 'Saved.',
}) async {
  try {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(success)));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not complete: $e')));
    }
  }
}

class StoredPhoto extends StatefulWidget {
  const StoredPhoto({
    required this.path,
    this.height = 160,
    this.width,
    super.key,
  });
  final String? path;
  final double height;
  final double? width;
  @override
  State<StoredPhoto> createState() => _StoredPhotoState();
}

class _StoredPhotoState extends State<StoredPhoto> {
  Future<Uint8List?>? _data;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(StoredPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _load();
  }

  void _load() {
    final path = widget.path ?? '';
    _data =
        path.startsWith('reports/') ||
            path.startsWith('receipts/') ||
            path.startsWith('cats/')
        ? FirebaseStorage.instance.ref(path).getData(5 * 1024 * 1024)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox(
      height: widget.height,
      width: widget.width,
      child: const Center(child: Icon(Icons.pets)),
    );
    if (_data != null) {
      return FutureBuilder<Uint8List?>(
        future: _data,
        builder: (_, s) => s.data == null
            ? fallback
            : Image.memory(
                s.data!,
                height: widget.height,
                width: widget.width,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => fallback,
              ),
      );
    }
    final provider = ImageUtil.providerFor(widget.path);
    return provider == null
        ? fallback
        : Image(
            image: provider,
            height: widget.height,
            width: widget.width,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stack) => fallback,
          );
  }
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({this.initial, super.key});
  final LatLng? initial;
  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final _map = MapController();
  LatLng? _point;
  bool _locating = false;
  @override
  void initState() {
    super.initState();
    _point = widget.initial;
  }

  Future<void> _gps() async {
    setState(() => _locating = true);
    await runAction(context, () async {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Enable location services or tap the map.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission denied. Tap the map instead.');
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      setState(() => _point = LatLng(p.latitude, p.longitude));
      _map.move(_point!, 17);
    }, success: 'Location selected. Check the pin before saving.');
    if (mounted) setState(() => _locating = false);
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose the sighting location')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Tap the map where you saw the cat. The map centre is not saved unless you select a pin.',
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _point ?? const LatLng(1.5603, 103.6378),
              initialZoom: 16,
              onTap: (_, p) => setState(() => _point = p),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.utm.pawsitive',
              ),
              if (_point != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _point!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _locating ? null : _gps,
                  child: Text(_locating ? 'Locating…' : 'Use GPS'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _point == null
                      ? null
                      : () => Navigator.pop(context, _point),
                  child: const Text('Use this pin'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Future<bool> openCheckout(
  BuildContext context, {
  required String kind,
  double? amount,
  String? projectId,
  List<Map<String, dynamic>>? items,
}) async {
  try {
    final checkout = await Workflows.instance.checkout(
      requestId: Workflows.instance.newId(),
      kind: kind,
      amount: amount,
      projectId: projectId,
      items: items,
    );
    if (!context.mounted) return false;
    final uri = Uri.parse(checkout['url'] as String);
    if (uri.scheme != 'https' || uri.host != 'checkout.stripe.com') {
      throw StateError('Invalid checkout address.');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open checkout.');
    }
    if (!context.mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('payments')
                .doc(checkout['paymentId'] as String)
                .snapshots(),
            builder: (_, s) {
              final paid = s.data?.data()?['status'] == 'paid';
              return AlertDialog(
                title: Text(paid ? 'Payment verified' : 'Waiting for payment'),
                content: Text(
                  s.hasError
                      ? 'Could not check payment status. Check your payment history before retrying.'
                      : paid
                      ? 'Your payment was verified and recorded.'
                      : 'Complete checkout in your browser. Payment will be recorded automatically, even if you close this window.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, paid),
                    child: Text(paid ? 'Done' : 'Close'),
                  ),
                ],
              );
            },
          ),
        ) ??
        false;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Checkout unavailable: $e')));
    }
    return false;
  }
}

class CareTimeline extends StatelessWidget {
  const CareTimeline({required this.catId, required this.profile, super.key});
  final String catId;
  final AppUserProfile profile;
  Future<void> _add(BuildContext context) async {
    final controller = TextEditingController();
    String kind = 'note';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setLocal) => AlertDialog(
          title: const Text('Add care entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: kind,
                items: ['note', 'feeding', 'medical']
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setLocal(() => kind = v!),
              ),
              TextField(
                controller: controller,
                maxLines: 4,
                maxLength: 2000,
                decoration: const InputDecoration(labelText: 'What happened?'),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    final note = controller.text.trim();
    if (confirmed != true || note.isEmpty || !context.mounted) return;
    await runAction(context, () async {
      await Workflows.instance.call('addCareEntry', {
        'catId': catId,
        'kind': kind,
        'note': note,
        'requestId': Workflows.instance.newId(),
      });
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Care timeline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (profile.role == UserRole.admin || profile.isApprovedVolunteer)
            TextButton(
              onPressed: () => _add(context),
              child: const Text('Add entry'),
            ),
        ],
      ),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('cats')
            .doc(catId)
            .collection('timeline')
            .orderBy('createdAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (_, s) {
          if (s.hasError) {
            return const Text('Could not load the care timeline.');
          }
          if (!s.hasData) return const LinearProgressIndicator();
          if (s.data!.docs.isEmpty) return const Text('No care entries yet.');
          return Column(
            children: s.data!.docs.map((doc) {
              final d = doc.data();
              return ListTile(
                title: Text('${d['kind']}: ${d['note']}'),
                subtitle: Text(
                  '${d['actorName']} • ${(d['createdAt'] as Timestamp?)?.toDate().toLocal() ?? ''}',
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}

class ReviewQueuePage extends StatelessWidget {
  const ReviewQueuePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Duplicate review')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .where('duplicateStatus', whereIn: ['pending', 'linked'])
          .limit(100)
          .snapshots(),
      builder: (_, s) {
        if (s.hasError) {
          return const Center(child: Text('Could not load review queue.'));
        }
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(
          children: [
            if (s.data!.docs.isEmpty)
              const ListTile(title: Text('No suggestions to review.')),
            ...s.data!.docs.map((doc) {
              final d = doc.data();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('${d['locationName']} — ${d['duplicateStatus']}'),
                      Row(
                        children: [
                          Expanded(
                            child: StoredPhoto(path: d['photoUrl'] as String?),
                          ),
                          Expanded(
                            child:
                                FutureBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>
                                >(
                                  future: FirebaseFirestore.instance
                                      .collection('cats')
                                      .doc(d['candidateCatId'] as String)
                                      .get(),
                                  builder: (_, candidate) {
                                    final photos =
                                        candidate.data?.data()?['photoUrls']
                                            as List?;
                                    return StoredPhoto(
                                      path: photos?.isNotEmpty == true
                                          ? photos!.first as String
                                          : null,
                                    );
                                  },
                                ),
                          ),
                        ],
                      ),
                      const Text(
                        'Compare markings and location. Linking preserves both original histories.',
                      ),
                      Wrap(
                        children:
                            (d['duplicateStatus'] == 'linked'
                                    ? ['undo']
                                    : ['link', 'reject'])
                                .map(
                                  (decision) => TextButton(
                                    onPressed: () =>
                                        runAction(context, () async {
                                          await Workflows.instance
                                              .call('reviewDuplicate', {
                                                'reportId': doc.id,
                                                'decision': decision,
                                              });
                                        }),
                                    child: Text(decision),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    ),
  );
}

class FinancialReviewPage extends StatelessWidget {
  const FinancialReviewPage({super.key});
  Future<void> _approve(BuildContext context, String donationId) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify bank transaction'),
        content: TextField(
          controller: controller,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: 'Unique bank transaction reference',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Verify received'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await runAction(context, () async {
        await Workflows.instance.call('reviewDonation', {
          'id': donationId,
          'approve': true,
          'reference': controller.text.trim(),
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Review receipts')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .where('status', isEqualTo: 'pending')
          .limit(100)
          .snapshots(),
      builder: (_, s) {
        if (s.hasError) {
          return const Center(child: Text('Could not load receipts.'));
        }
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(
          children: [
            if (s.data!.docs.isEmpty)
              const ListTile(title: Text('No pending receipts.')),
            ...s.data!.docs.map((doc) {
              final d = doc.data(), path = d['evidencePath'] as String?;
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text('RM ${d['amount']} — ${d['userName']}'),
                      subtitle: Text(d['message'] as String? ?? ''),
                    ),
                    if (path?.endsWith('.pdf') == true)
                      TextButton(
                        onPressed: () => runAction(context, () async {
                          final bytes = await FirebaseStorage.instance
                              .ref(path)
                              .getData(5 * 1024 * 1024);
                          if (bytes == null) {
                            throw StateError('Receipt is unavailable.');
                          }
                          await FilePicker.platform.saveFile(
                            fileName: 'receipt.pdf',
                            bytes: bytes,
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );
                        }, success: 'Receipt downloaded for review.'),
                        child: const Text('Download PDF receipt'),
                      )
                    else
                      StoredPhoto(path: path, height: 240),
                    const Text(
                      'Compare the receipt with the bank transaction before approving.',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => runAction(context, () async {
                            await Workflows.instance.call('reviewDonation', {
                              'id': doc.id,
                              'approve': false,
                              'note':
                                  'Payment could not be verified. Contact the society.',
                            });
                          }),
                          child: const Text('Reject'),
                        ),
                        FilledButton(
                          onPressed: () => _approve(context, doc.id),
                          child: const Text('Verify received'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    ),
  );
}

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({required this.uid, super.key});
  final String uid;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Payment history')),
    body: ListView(
      children: ['payments', 'donations']
          .map(
            (collection) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(collection)
                  .where('userId', isEqualTo: uid)
                  .limit(100)
                  .snapshots(),
              builder: (_, s) {
                if (s.hasError) {
                  return const ListTile(
                    title: Text('Could not load payment history.'),
                  );
                }
                return Column(
                  children: (s.data?.docs ?? [])
                      .where(
                        (d) =>
                            collection != 'donations' ||
                            d.data()['source'] != 'stripe',
                      )
                      .map((doc) {
                        final d = doc.data();
                        return ListTile(
                          title: Text(
                            'RM ${((d['amountCents'] as num? ?? 0) / 100).toStringAsFixed(2)}',
                          ),
                          subtitle: Text(
                            '${d['status'] ?? 'Unverified legacy record'} • ${d['kind'] ?? d['source']}',
                          ),
                        );
                      })
                      .toList(),
                );
              },
            ),
          )
          .toList(),
    ),
  );
}

class VolunteerApplicationsPage extends StatelessWidget {
  const VolunteerApplicationsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Volunteer applications')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('volunteers')
          .where('approvalStatus', isEqualTo: 'pending')
          .limit(100)
          .snapshots(),
      builder: (_, s) {
        if (s.hasError) {
          return const Center(child: Text('Could not load applications.'));
        }
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(
          children: [
            if (s.data!.docs.isEmpty)
              const ListTile(title: Text('No pending applications.')),
            ...s.data!.docs.map(
              (doc) => FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .get(),
                builder: (_, user) => ListTile(
                  title: Text(
                    user.data?.data()?['fullName'] as String? ?? doc.id,
                  ),
                  subtitle: Text(user.data?.data()?['email'] as String? ?? ''),
                  trailing: Wrap(
                    children: ['user', 'volunteer']
                        .map(
                          (role) => TextButton(
                            onPressed: () => runAction(context, () async {
                              await Workflows.instance.call('manageUser', {
                                'uid': doc.id,
                                'role': role,
                                'suspended': false,
                              });
                            }),
                            child: Text(
                              role == 'volunteer' ? 'Approve' : 'Reject',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class FinanceBalance extends StatelessWidget {
  const FinanceBalance({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('finance')
        .doc('summary')
        .snapshots(),
    builder: (_, s) {
      if (s.hasError) {
        return const Text('Could not load verified fund balance.');
      }
      if (!s.hasData) return const LinearProgressIndicator();
      final d = s.data?.data() ?? {};
      final balance = (d['balanceCents'] as num? ?? 0) / 100,
          reserved = (d['reservedCents'] as num? ?? 0) / 100;
      return ListTile(
        title: Text('Available: RM ${(balance - reserved).toStringAsFixed(2)}'),
        subtitle: Text(
          'Verified balance RM ${balance.toStringAsFixed(2)} | Reserved RM ${reserved.toStringAsFixed(2)}',
        ),
      );
    },
  );
}

class VolunteerAvailability extends StatelessWidget {
  const VolunteerAvailability({required this.uid, super.key});
  final String uid;
  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
    builder: (_, s) => SwitchListTile(
      title: const Text('Available for new cases'),
      subtitle: const Text('Receive alerts about new and urgent sightings.'),
      value: s.data?.data()?['available'] != false,
      onChanged: s.hasData
          ? (value) => runAction(context, () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({'available': value});
            })
          : null,
    ),
  );
}

Future<void> recordDisbursement(BuildContext context, String requestId) async {
  final controller = TextEditingController();
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Record completed transfer'),
      content: TextField(
        controller: controller,
        maxLength: 100,
        decoration: const InputDecoration(
          labelText: 'Bank transaction reference',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Record disbursement'),
        ),
      ],
    ),
  );
  if (confirm == true && context.mounted) {
    await runAction(context, () async {
      await Workflows.instance.call('reviewFundRequest', {
        'id': requestId,
        'status': 'disbursed',
        'reference': controller.text.trim(),
      });
    });
  }
}

class VerifiedTreasuryPage extends StatelessWidget {
  const VerifiedTreasuryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verified treasury')),
    body: ListView(
      children: [
        const FinanceBalance(),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('finance')
              .doc('summary')
              .snapshots(),
          builder: (_, s) {
            if (s.hasError) {
              return const Text('Totals are unavailable. Please retry.');
            }
            final d = s.data?.data() ?? {};
            String amount(String field) =>
                ((d[field] as num? ?? 0) / 100).toStringAsFixed(2);
            return ListTile(
              title: Text(
                'Donations RM ${amount('donationsCents')} | Sales RM ${amount('salesCents')}',
              ),
              subtitle: Text(
                'Disbursed RM ${amount('expensesCents')}. Totals include verified transactions only.',
              ),
            );
          },
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FinancialReviewPage()),
          ),
          child: const Text('Review pending receipts'),
        ),
        const ListTile(title: Text('Recent ledger entries')),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('ledger')
              .orderBy('createdAt', descending: true)
              .limit(100)
              .snapshots(),
          builder: (_, s) {
            if (s.hasError) return const Text('Ledger is unavailable.');
            if (!s.hasData) return const LinearProgressIndicator();
            return Column(
              children: s.data!.docs.map((doc) {
                final d = doc.data();
                return ListTile(
                  title: Text(
                    '${d['kind']} — RM ${((d['amountCents'] as num) / 100).toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    '${d['reference'] ?? doc.id} • ${(d['createdAt'] as Timestamp?)?.toDate().toLocal() ?? ''}',
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );
}

/// Cursor paging keeps historical records accessible without unbounded listeners.
class PagedCollectionPage extends StatefulWidget {
  const PagedCollectionPage({
    required this.title,
    required this.query,
    required this.itemBuilder,
    super.key,
  });
  final String title;
  final Query<Map<String, dynamic>> query;
  final Widget Function(
    BuildContext,
    QueryDocumentSnapshot<Map<String, dynamic>>,
  )
  itemBuilder;
  @override
  State<PagedCollectionPage> createState() => _PagedCollectionPageState();
}

class _PagedCollectionPageState extends State<PagedCollectionPage> {
  final _items = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  bool _busy = false, _more = true;
  Object? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      if (refresh) {
        _items.clear();
        _more = true;
      }
    });
    try {
      var query = widget.query.limit(30);
      if (_items.isNotEmpty) query = query.startAfterDocument(_items.last);
      final page = await query.get();
      if (!mounted) return;
      setState(() {
        _items.addAll(page.docs);
        _more = page.docs.length == 30;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      actions: [
        IconButton(
          onPressed: _busy ? null : () => _load(refresh: true),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      children: [
        ..._items.map((d) => widget.itemBuilder(context, d)),
        if (_items.isEmpty && !_busy && _error == null)
          const ListTile(title: Text('No records yet.')),
        if (_error != null)
          const ListTile(title: Text('Could not load records. Please retry.')),
        if (_busy) const LinearProgressIndicator(),
        if (_more || _error != null)
          TextButton(
            onPressed: _busy ? null : _load,
            child: const Text('Load more'),
          ),
      ],
    ),
  );
}
