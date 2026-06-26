import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_config.dart';
import '../core/domain.dart';
import '../core/image_util.dart';
import '../core/services.dart';
import '../core/cat_matching_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 56),
          const PageHeader(
            title: 'UTM Paws-itive',
            subtitle: 'Sign in to manage cat reports, volunteer work, and campus care.',
            icon: Icons.pets,
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _loading ? null : _login,
                  child: Text(_loading ? 'Signing in...' : 'Login'),
                ),
                TextButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pushNamed(RegisterScreen.routeName),
                  child: const Text('Create new account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  UserRole _role = UserRole.user;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _role,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Join UTM Paws-itive', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full name')),
                const SizedBox(height: 12),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm password'),
                  validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: UserRole.user, child: Text('User')),
                    DropdownMenuItem(value: UserRole.volunteer, child: Text('Volunteer')),
                  ],
                  onChanged: (value) => setState(() => _role = value ?? UserRole.user),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _loading ? null : _register,
                  child: Text(_loading ? 'Creating...' : 'Register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, required this.subtitle, required this.icon, super.key});

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
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
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
                Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.92))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStatePanel extends StatelessWidget {
  const EmptyStatePanel({required this.icon, required this.title, required this.subtitle, super.key});

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
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
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
                _MetricCard(label: 'Reports', value: '${counts['reports'] ?? 0}', icon: Icons.assignment_outlined),
                _MetricCard(label: 'Cats', value: '${counts['cats'] ?? 0}', icon: Icons.pets_outlined),
                _MetricCard(label: 'Donations', value: '${counts['donations'] ?? 0}', icon: Icons.volunteer_activism_outlined),
                _MetricCard(label: 'Clinics', value: '${counts['clinics'] ?? 0}', icon: Icons.local_hospital_outlined),
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
                      const Icon(Icons.volunteer_activism, color: AppTheme.success, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Support the cats', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            const Text('Donate via QR / DuitNow to fund food and treatment.'),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DonatePage(profile: profile)),
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
              Text('My recent reports', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              StreamBuilder<List<CatReport>>(
                stream: FirestoreGateway.instance.watchReports(reporterId: profile.uid),
                builder: (context, reportSnapshot) {
                  final myReports = reportSnapshot.data ?? const <CatReport>[];
                  if (myReports.isEmpty) {
                    return const EmptyStatePanel(
                      icon: Icons.assignment_outlined,
                      title: 'No reports yet',
                      subtitle: 'Use the Report tab to submit your first cat sighting.',
                    );
                  }
                  return Column(
                    children: myReports
                        .take(5)
                        .map((report) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.pets_outlined),
                                title: Text(report.locationName),
                                subtitle: Text(report.description.isEmpty ? 'No description' : report.description),
                                trailing: _StatusPill(label: report.status.label),
                              ),
                            ))
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
        content: const Text('Become a volunteer to help injured cats, manage cases, and start fundraising projects?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Join')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await FirestoreGateway.instance.updateUser(profile.uid, {
        'role': UserRole.volunteer.name,
        'isApprovedVolunteer': true,
        'status': 'active',
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are now a volunteer! 🎉')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update: $error')));
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
          subtitle: 'Thanks for helping UTM\'s campus cats. Here\'s what\'s happening.',
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
                  const Icon(Icons.volunteer_activism_outlined, color: AppTheme.primary, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Want to do more?', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        const Text('Join as a volunteer to assist cases and raise funds.'),
                      ],
                    ),
                  ),
                  FilledButton(onPressed: () => _joinAsVolunteer(context), child: const Text('Join')),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('Current fundraising', style: Theme.of(context).textTheme.titleLarge)),
            const Icon(Icons.savings_outlined, color: AppTheme.primary),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<FundraisingProject>>(
          stream: FirestoreGateway.instance.watchFundraising(onlyActive: true),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
            final projects = snapshot.data ?? const <FundraisingProject>[];
            if (projects.isEmpty) {
              return const EmptyStatePanel(
                icon: Icons.savings_outlined,
                title: 'No active fundraising',
                subtitle: 'Fundraising projects from volunteers will appear here.',
              );
            }
            return Column(children: projects.map((p) => FundraisingCard(project: p, profile: profile)).toList());
          },
        ),
        const SizedBox(height: 16),
        Text('Recent reports', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        StreamBuilder<List<CatReport>>(
          stream: FirestoreGateway.instance.watchReports(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
            final reports = (snapshot.data ?? const <CatReport>[]).take(5).toList();
            if (reports.isEmpty) {
              return const EmptyStatePanel(
                icon: Icons.assignment_outlined,
                title: 'No reports yet',
                subtitle: 'Be the first to report a cat that needs help.',
              );
            }
            return Column(
              children: reports
                  .map((report) => Card(
                        child: ListTile(
                          leading: CatThumb(url: report.photoUrl.isNotEmpty ? report.photoUrl : null),
                          title: Text(report.locationName),
                          subtitle: Text(report.description.isEmpty ? 'No description' : report.description),
                          trailing: _StatusPill(label: report.status.label),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class FundraisingCard extends StatelessWidget {
  const FundraisingCard({required this.project, required this.profile, this.onManage, super.key});

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
          decoration: const InputDecoration(labelText: 'Amount', prefixText: 'RM '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Donate')),
        ],
      ),
    );
    if (ok != true) return;
    final amount = double.tryParse(controller.text.trim()) ?? 0;
    if (amount <= 0) return;
    try {
      await FirestoreGateway.instance.donateToProject(
        projectId: project.id,
        projectTitle: project.title,
        userId: profile.uid,
        userName: profile.fullName,
        amount: amount,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppTheme.success, content: Text('Thank you for donating RM ${amount.toStringAsFixed(2)}!')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Donation failed: $error')));
      }
    }
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
                      Text(project.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('by ${project.createdByName}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (onManage != null)
                  IconButton(icon: const Icon(Icons.more_vert), onPressed: onManage),
              ],
            ),
            const SizedBox(height: 8),
            Text(project.description),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: project.progress, minHeight: 8, backgroundColor: AppTheme.border),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RM ${project.raisedAmount.toStringAsFixed(0)} of RM ${project.goalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
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
                  const Text('Could not load data', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.error)),
                  const SizedBox(height: 4),
                  Text('$error', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  const Text('If this says PERMISSION_DENIED, deploy the Firestore rules.', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportCatPage extends StatefulWidget {
  const ReportCatPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<ReportCatPage> createState() => _ReportCatPageState();
}

class _ReportCatPageState extends State<ReportCatPage> {
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _bytes;
  bool _loading = false;
  bool _showPhotoError = false;
  bool _showLocationError = false;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _bytes = bytes;
      _showPhotoError = false;
    });
  }

  void _clearForm() {
    _locationController.clear();
    _descriptionController.clear();
    setState(() {
      _bytes = null;
      _showPhotoError = false;
      _showLocationError = false;
    });
  }

  Future<void> _submit() async {
    bool valid = true;
    if (_bytes == null) {
      setState(() => _showPhotoError = true);
      valid = false;
    }
    if (_locationController.text.trim().isEmpty) {
      setState(() => _showLocationError = true);
      valid = false;
    }
    if (!valid) return;

    setState(() => _loading = true);
    try {
      final match = await CatMatchingService.instance.match(_bytes!);
      final catId = match.existingCatId ?? FirebaseFirestore.instance.collection(Collections.cats).doc().id;

      final imageUrl = ImageUtil.encodeThumbnail(_bytes!) ?? '';

      final cat = CatProfile(
        id: catId,
        name: match.existingCatName,
        photoUrls: imageUrl.isNotEmpty ? [imageUrl] : const [],
        currentLocationName: _locationController.text.trim(),
        latitude: 1.5603,
        longitude: 103.6378,
        healthStatus: CatHealthStatus.unknown,
        classification: CatClassification.stray,
        feedingHistory: const [],
        volunteerNotes: const [],
        medicalNotes: const [],
        reportIds: const [],
        imageSignature: match.signature,
        currentStatus: ReportStatus.reported,
        lastUpdated: DateTime.now(),
        matchedReportId: null,
      );
      await FirestoreGateway.instance.upsertCat(cat);

      final report = CatReport(
        id: '',
        reporterId: widget.profile.uid,
        reporterName: widget.profile.fullName,
        locationName: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        status: match.isMatch ? ReportStatus.underReview : ReportStatus.reported,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        catId: catId,
        latitude: 1.5603,
        longitude: 103.6378,
        photoUrl: imageUrl,
        imageSignature: match.signature,
        duplicateMessage: match.message,
        duplicateConfidence: match.confidence,
        analysisLabel: 'Cat',
        analysisConfidence: 0.93,
      );

      await FirestoreGateway.instance.createReport(report);
      try {
        await FirestoreGateway.instance.addNotification(
          title: 'New cat report',
          body: '${widget.profile.fullName} submitted a cat report at ${_locationController.text.trim()}.',
          type: 'new_report',
        );
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(match.message)));
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ReportDetailPage(initialMessage: match.message, confidence: match.confidence)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report failed: $error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Header row
        Row(
          children: [
            Expanded(
              child: Text('Report Animal',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: _loading ? null : _clearForm,
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Animal Photo
        _FieldLabel(label: 'Animal Photo', required: true),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _loading ? null : _pickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showPhotoError ? errorColor : AppTheme.primary.withValues(alpha: 0.45),
                width: 2,
              ),
              color: _showPhotoError
                  ? errorColor.withValues(alpha: 0.04)
                  : AppTheme.primary.withValues(alpha: 0.04),
            ),
            clipBehavior: Clip.antiAlias,
            child: _bytes != null
                ? Image.memory(_bytes!, fit: BoxFit.cover, width: double.infinity)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 44,
                        color: _showPhotoError ? errorColor : AppTheme.primary.withValues(alpha: 0.65),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to upload photo',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _showPhotoError ? errorColor : AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'image · JPG, PNG · max 5MB',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
          ),
        ),
        if (_showPhotoError) _InlineError('Animal photo is required before submitting'),
        const SizedBox(height: 20),

        // Location Found
        _FieldLabel(label: 'Location Found', required: true),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          onChanged: (_) {
            if (_showLocationError) setState(() => _showLocationError = false);
          },
          decoration: InputDecoration(
            hintText: 'e.g. N28 Engineering Block, UTM',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _showLocationError ? errorColor : Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: _showLocationError ? errorColor : Colors.grey.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: _showLocationError ? errorColor : AppTheme.primary, width: 2),
            ),
          ),
        ),
        if (_showLocationError) _InlineError('Please enter the location where the animal was found'),
        const SizedBox(height: 20),

        // Description
        _FieldLabel(label: 'Description', required: false),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          minLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: "Describe the animal's condition, appearance, and behaviour...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Submit
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_outlined),
            label: Text(
              _loading ? 'Submitting...' : 'Submit Report',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        if (required)
          Text(' *',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 13, color: color),
          const SizedBox(width: 4),
          Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 12))),
        ],
      ),
    );
  }
}

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({required this.initialMessage, required this.confidence, super.key});

  final String initialMessage;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pets, size: 64, color: AppTheme.primary),
                  const SizedBox(height: 12),
                  Text(initialMessage, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Similarity confidence ${(confidence * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DonatePage extends StatefulWidget {
  const DonatePage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  double _selectedAmount = 20;
  final _customController = TextEditingController();
  bool _recording = false;

  static const _presetAmounts = [10.0, 20.0, 50.0, 100.0];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  double get _amount {
    if (_customController.text.trim().isNotEmpty) {
      return double.tryParse(_customController.text.trim()) ?? _selectedAmount;
    }
    return _selectedAmount;
  }

  Future<void> _confirmDonation() async {
    final amount = _amount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      return;
    }

    setState(() => _recording = true);
    try {
      await FirestoreGateway.instance.recordDonation(
        userId: widget.profile.uid,
        userName: widget.profile.fullName,
        amount: amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.success,
          content: Text('Thank you! RM ${amount.toStringAsFixed(2)} donation recorded.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not record donation: $error')));
    } finally {
      if (mounted) setState(() => _recording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    return Scaffold(
      appBar: AppBar(title: const Text('Donate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageHeader(
            title: 'Support our cats',
            subtitle: 'Scan the QR with your banking app, then confirm to log your gift.',
            icon: Icons.volunteer_activism,
          ),
          const SizedBox(height: 16),
          Text('Select amount', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetAmounts.map((value) {
              final selected = _selectedAmount == value && _customController.text.trim().isEmpty;
              return ChoiceChip(
                label: Text('RM ${value.toStringAsFixed(0)}'),
                selected: selected,
                onSelected: (_) => setState(() {
                  _selectedAmount = value;
                  _customController.clear();
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Or enter a custom amount',
              prefixText: 'RM ',
              prefixIcon: Icon(Icons.attach_money),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Scan to pay ${AppConfig.organisationName}', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Image.asset(
                      'assets/donation_qr.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => QrImageView(
                        data: AppConfig.donationQrPayload(amount: amount),
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                        errorStateBuilder: (ctx, err) => const SizedBox(
                          height: 220,
                          child: Center(child: Text('Could not render QR code.')),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DonationInfoRow(label: 'DuitNow ID', value: AppConfig.duitNowId),
                  _DonationInfoRow(label: AppConfig.bankName, value: '${AppConfig.accountHolder} • ${AppConfig.accountNumber}'),
                  _DonationInfoRow(label: 'Amount', value: 'RM ${amount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: AppConfig.duitNowId));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DuitNow ID copied.')));
                    },
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy DuitNow ID'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _recording ? null : _confirmDonation,
            icon: _recording
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.favorite),
            label: Text(_recording ? 'Recording...' : "I've donated RM ${amount.toStringAsFixed(2)}"),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan the QR code above with your banking app, then tap "I\'ve donated" to log your gift.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DonationInfoRow extends StatelessWidget {
  const _DonationInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CatReport>>(
      stream: FirestoreGateway.instance.watchReports(),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(
              title: 'Reports',
              subtitle: 'Every submitted report and its volunteer workflow status.',
              icon: Icons.fact_check_outlined,
            ),
            const SizedBox(height: 16),
            if (snapshot.hasError)
              _ErrorPanel(error: snapshot.error!)
            else if (reports.isEmpty)
              const EmptyStatePanel(
                icon: Icons.assignment_outlined,
                title: 'No reports yet',
                subtitle: 'User submissions will appear here once the platform receives reports.',
              )
            else
              ...reports.map((report) => _AdminReportCard(report: report, profile: profile)),
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
    final volunteers = users.where((u) => u.role == UserRole.volunteer).toList();
    if (!context.mounted) return;
    if (volunteers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No volunteers registered yet.')));
      return;
    }
    final selected = await showModalBottomSheet<AppUserProfile>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Assign to volunteer', style: TextStyle(fontWeight: FontWeight.w800))),
            ...volunteers.map((v) => ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(v.fullName),
                  subtitle: Text(v.email),
                  onTap: () => Navigator.pop(ctx, v),
                )),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await FirestoreGateway.instance.assignReport(report.id, volunteerId: selected.uid, status: ReportStatus.beingAssisted);
    try {
      await FirestoreGateway.instance.addNotification(
        title: 'New assignment',
        body: 'You were assigned a case at ${report.locationName}.',
        targetUserId: selected.uid,
        type: 'assignment',
      );
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned to ${selected.fullName}.')));
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This permanently removes the report.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await FirestoreGateway.instance.deleteReport(report.id);
    }
  }

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
                CatThumb(url: report.photoUrl.isNotEmpty ? report.photoUrl : null, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.locationName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('By ${report.reporterName.isEmpty ? 'Unknown' : report.reporterName} • ${_formatDate(report.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      Text(report.description.isEmpty ? 'No description' : report.description),
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
                  onSelected: (status) => FirestoreGateway.instance.setReportStatus(report.id, status),
                  itemBuilder: (_) => ReportStatus.values
                      .map((s) => PopupMenuItem(value: s, child: Text('Mark: ${s.label}')))
                      .toList(),
                  child: const _ActionChip(icon: Icons.flag_outlined, label: 'Status'),
                ),
                InkWell(onTap: () => _assign(context), child: const _ActionChip(icon: Icons.person_add_alt, label: 'Assign')),
                if (report.catId != null)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CatProfileDetailPage(catId: report.catId!, profile: profile)),
                    ),
                    child: const _ActionChip(icon: Icons.pets_outlined, label: 'Cat'),
                  ),
                InkWell(onTap: () => _delete(context), child: const _ActionChip(icon: Icons.delete_outline, label: 'Delete', danger: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, this.danger = false});

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
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
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
        final reports = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(
              title: 'Volunteer cases',
              subtitle: 'Handle reported cats, review statuses, and close active cases.',
              icon: Icons.volunteer_activism,
            ),
            const SizedBox(height: 16),
            if (snapshot.hasError)
              _ErrorPanel(error: snapshot.error!)
            else if (reports.isEmpty)
              const EmptyStatePanel(
                icon: Icons.assignment_turned_in_outlined,
                title: 'No active cases',
                subtitle: 'Volunteer assignments will appear when users submit reports.',
              )
            else
              ...reports.map((report) => _VolunteerCaseCard(report: report, profile: profile)),
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
  bool get _unassigned => report.assignedVolunteerId == null || report.assignedVolunteerId!.isEmpty;

  Future<void> _accept(BuildContext context) async {
    await FirestoreGateway.instance.assignReport(report.id, volunteerId: profile.uid, status: ReportStatus.beingAssisted);
    if (report.catId != null) {
      await FirestoreGateway.instance.upsertCat(CatProfile.fromMap(report.catId!, {
        'currentStatus': 'beingAssisted',
        'lastUpdated': FieldValue.serverTimestamp(),
      }));
    }
    try {
      await FirestoreGateway.instance.addNotification(
        title: 'Case accepted',
        body: '${profile.fullName} is assisting the cat at ${report.locationName}.',
        type: 'case_update',
      );
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Case assigned to you.')));
    }
  }

  Future<void> _setStatus(BuildContext context, ReportStatus status) async {
    await FirestoreGateway.instance.setReportStatus(report.id, status);
    if (report.catId != null) {
      await FirestoreGateway.instance.upsertCat(CatProfile.fromMap(report.catId!, {
        'currentStatus': status.name,
        'lastUpdated': FieldValue.serverTimestamp(),
      }));
    }
  }

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
                CatThumb(url: report.photoUrl.isNotEmpty ? report.photoUrl : null, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.locationName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(report.description.isEmpty ? 'No description' : report.description),
                      if (_mine)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Assigned to you', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w800)),
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
                  InkWell(onTap: () => _accept(context), child: const _ActionChip(icon: Icons.handshake_outlined, label: 'Accept'))
                else if (_mine) ...[
                  PopupMenuButton<ReportStatus>(
                    onSelected: (status) => _setStatus(context, status),
                    itemBuilder: (_) => ReportStatus.values.map((s) => PopupMenuItem(value: s, child: Text('Mark: ${s.label}'))).toList(),
                    child: const _ActionChip(icon: Icons.flag_outlined, label: 'Status'),
                  ),
                  InkWell(
                    onTap: () => _showFundRequestDialog(context, profile, report),
                    child: const _ActionChip(icon: Icons.savings_outlined, label: 'Call for fund'),
                  ),
                ] else
                  const _ActionChip(icon: Icons.lock_outline, label: 'Assigned'),
                if (report.catId != null)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CatProfileDetailPage(catId: report.catId!, profile: profile)),
                    ),
                    child: const _ActionChip(icon: Icons.pets_outlined, label: 'Cat'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showFundRequestDialog(BuildContext context, AppUserProfile profile, CatReport report) async {
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
            decoration: const InputDecoration(labelText: 'Amount (RM)', prefixText: 'RM '),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Reason (e.g. vet treatment)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
      ],
    ),
  );

  if (submitted != true) return;
  final amount = double.tryParse(amountController.text.trim()) ?? 0;
  if (amount <= 0 || reasonController.text.trim().isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount and reason.')));
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
  try {
    await FirestoreGateway.instance.addNotification(
      title: 'Funding requested',
      body: '${profile.fullName} requested RM${amount.toStringAsFixed(2)} for a cat at ${report.locationName}.',
      type: 'fund_request',
    );
  } catch (_) {}
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funding request submitted.')));
  }
}

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

            final markers = <Marker>{
              for (final cat in cats)
                if (cat.latitude != null && cat.longitude != null)
                  Marker(
                    markerId: MarkerId(cat.id),
                    position: LatLng(cat.latitude!, cat.longitude!),
                    infoWindow: InfoWindow(title: cat.name ?? 'Cat ${cat.id}', snippet: cat.currentLocationName),
                  ),
              for (final clinic in clinics)
                Marker(
                  markerId: MarkerId('clinic_${clinic.id}'),
                  position: LatLng(clinic.latitude, clinic.longitude),
                  infoWindow: InfoWindow(title: clinic.name, snippet: clinic.address),
                ),
            };

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const PageHeader(
                  title: 'Map view',
                  subtitle: 'Cat locations, feeding zones, and nearby veterinary clinics.',
                  icon: Icons.map_outlined,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 380,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                          target: LatLng(1.5603, 103.6365), zoom: 15),
                      markers: markers,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  markers.isEmpty
                      ? 'No cat or clinic locations yet — ask an admin to tap "Seed demo data".'
                      : 'Tap a pin to see details. Paw pins = cat sightings, hospital pins = clinics.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text('Nearby clinics', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (clinics.isEmpty)
                  const EmptyStatePanel(
                    icon: Icons.local_hospital_outlined,
                    title: 'No clinics configured',
                    subtitle: 'Ask an admin to run "Seed demo data" to display veterinary contacts.',
                  )
                else
                  ...clinics.map((clinic) => Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.local_hospital_outlined,
                            color: clinic.emergency ? AppTheme.error : AppTheme.primary,
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(clinic.name)),
                              if (clinic.emergency)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text('24H', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w800, fontSize: 11)),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(clinic.address),
                              if (clinic.phone != null && clinic.phone!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(clinic.phone!, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                          trailing: (clinic.phone != null && clinic.phone!.isNotEmpty)
                              ? IconButton(
                                  icon: const Icon(Icons.call, color: AppTheme.success),
                                  tooltip: 'Call ${clinic.name}',
                                  onPressed: () => _callPhone(context, clinic.phone!),
                                )
                              : null,
                        ),
                      )),
              ],
            );
          },
        );
      },
    );
  }
}

class CatsPage extends StatelessWidget {
  const CatsPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CatProfile>>(
      stream: FirestoreGateway.instance.watchCats(),
      builder: (context, snapshot) {
        final cats = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                subtitle: 'Profiles appear after the first report — or ask an admin to "Seed demo data".',
              )
            else
              ...cats.map((cat) => Card(
                    child: ListTile(
                      leading: CatThumb(url: cat.photoUrls.isNotEmpty ? cat.photoUrls.first : null),
                      title: Text(cat.name ?? 'Unnamed cat'),
                      subtitle: Text('${cat.currentLocationName} • ${cat.currentStatus.label} • ${cat.healthStatus.label}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CatProfileDetailPage(catId: cat.id, profile: profile)),
                      ),
                    ),
                  )),
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
    final placeholder = Container(
      width: size,
      height: size,
      color: AppTheme.primary.withValues(alpha: 0.12),
      child: const Icon(Icons.pets, color: AppTheme.primary),
    );
    final provider = ImageUtil.providerFor(url);
    if (provider == null) {
      return ClipRRect(borderRadius: BorderRadius.circular(10), child: placeholder);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image(
        image: provider,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
      ),
    );
  }
}

class CatProfileDetailPage extends StatelessWidget {
  const CatProfileDetailPage({required this.catId, required this.profile, super.key});

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
              tooltip: 'Delete cat',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete cat profile?'),
                    content: const Text('This permanently removes the cat profile.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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
          final cat = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cat == null) {
            return const EmptyStatePanel(icon: Icons.pets_outlined, title: 'Cat not found', subtitle: 'This profile may have been removed.');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (ImageUtil.providerFor(cat.photoUrls.isNotEmpty ? cat.photoUrls.first : null) != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image(
                    image: ImageUtil.providerFor(cat.photoUrls.first)!,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 240,
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      child: const Icon(Icons.pets, size: 64, color: AppTheme.primary),
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.pets, size: 64, color: AppTheme.primary),
                ),
              const SizedBox(height: 16),
              Text(cat.name ?? 'Unnamed cat', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _StatusPill(label: cat.currentStatus.label),
                _StatusPill(label: cat.healthStatus.label),
                _StatusPill(label: cat.classification == CatClassification.domestic ? 'Domestic' : 'Stray'),
              ]),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileRow(icon: Icons.place_outlined, label: 'Location', value: cat.currentLocationName.isEmpty ? 'Unknown' : cat.currentLocationName),
                      if (cat.latitude != null && cat.longitude != null)
                        _ProfileRow(icon: Icons.my_location_outlined, label: 'Coords', value: '${cat.latitude!.toStringAsFixed(5)}, ${cat.longitude!.toStringAsFixed(5)}'),
                      _ProfileRow(icon: Icons.update, label: 'Updated', value: _formatDate(cat.lastUpdated)),
                    ],
                  ),
                ),
              ),
              if (cat.feedingHistory.isNotEmpty) _NotesCard(title: 'Feeding history', notes: cat.feedingHistory),
              if (cat.volunteerNotes.isNotEmpty) _NotesCard(title: 'Volunteer notes', notes: cat.volunteerNotes),
              if (cat.medicalNotes.isNotEmpty) _NotesCard(title: 'Medical notes', notes: cat.medicalNotes),
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
              ...notes.map((note) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [const Text('• '), Expanded(child: Text(note))],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopPage extends StatefulWidget {
  const ShopPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final Map<String, int> _cart = {};

  bool get _isAdmin => widget.profile.role == UserRole.admin;

  Future<void> _checkout(List<ShopItem> items) async {
    final cart = items.where((item) => (_cart[item.id] ?? 0) > 0).toList(growable: false);
    if (cart.isEmpty) return;
    final total = cart.fold<double>(0, (sum, item) => sum + item.price * (_cart[item.id] ?? 0));

    await FirestoreGateway.instance.addOrder({
      'userId': widget.profile.uid,
      'items': cart.map((item) => {'itemId': item.id, 'name': item.name, 'quantity': _cart[item.id] ?? 0, 'price': item.price}).toList(growable: false),
      'total': total,
      'status': 'simulated_paid',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await FirestoreGateway.instance.addDonation({
      'userId': widget.profile.uid,
      'amount': total,
      'source': 'shop_checkout',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    setState(() => _cart.clear());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout complete: RM${total.toStringAsFixed(2)}')));
  }

  Future<void> _editItem([ShopItem? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(text: existing?.price.toStringAsFixed(2) ?? '');
    final categoryController = TextEditingController(text: existing?.category ?? '');
    final descriptionController = TextEditingController(text: existing?.description ?? '');
    final imageController = TextEditingController(text: existing?.imageUrl ?? '');
    bool active = existing?.active ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add product' : 'Edit product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 8),
                TextField(controller: priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price (RM)')),
                const SizedBox(height: 8),
                TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 8),
                TextField(controller: descriptionController, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 8),
                TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active (visible in shop)'),
                  value: active,
                  onChanged: (v) => setLocal(() => active = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved != true) return;
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    if (nameController.text.trim().isEmpty || price <= 0) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a name and a valid price.')));
      return;
    }
    try {
      await FirestoreGateway.instance.upsertShopItem(ShopItem(
        id: existing?.id ?? '',
        name: nameController.text.trim(),
        price: price,
        category: categoryController.text.trim(),
        description: descriptionController.text.trim(),
        imageUrl: imageController.text.trim().isEmpty ? null : imageController.text.trim(),
        active: active,
      ));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(existing == null ? 'Product added.' : 'Product updated.')));
    } catch (error) {
      // Surface the real reason (e.g. PERMISSION_DENIED if rules aren't deployed)
      // instead of silently "succeeding".
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ShopItem>>(
      stream: _isAdmin ? FirestoreGateway.instance.watchAllShopItems() : FirestoreGateway.instance.watchShopItems(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const [];
        final cartCount = _cart.values.fold<int>(0, (sum, value) => sum + value);
        return Scaffold(
          floatingActionButton: _isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => _editItem(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add product'),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PageHeader(
                title: _isAdmin ? 'Manage shop' : 'Shop & cafe',
                subtitle: _isAdmin
                    ? 'Add, edit, activate, or remove products. Sales feed the treasury.'
                    : 'Purchase items that support cat welfare programs.',
                icon: Icons.storefront_outlined,
              ),
              const SizedBox(height: 16),
              if (snapshot.hasError)
                _ErrorPanel(error: snapshot.error!)
              else if (items.isEmpty)
                EmptyStatePanel(
                  icon: Icons.storefront_outlined,
                  title: 'No products yet',
                  subtitle: _isAdmin ? 'Tap "Add product" to create your first item.' : 'Products will appear once an admin adds them.',
                )
              else if (_isAdmin)
                ...items.map((item) => Card(
                      child: ListTile(
                        leading: CatThumb(url: item.imageUrl, size: 48),
                        title: Text('${item.name}${item.active ? '' : '  (hidden)'}'),
                        subtitle: Text('${item.category} • RM ${item.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editItem(item)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete product?'),
                                    content: Text('Remove "${item.name}" from the shop?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm == true) await FirestoreGateway.instance.deleteShopItem(item.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ))
              else ...[
                ...items.map((item) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CatThumb(url: item.imageUrl, size: 56),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                                      Text(item.category),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(item.description),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('RM ${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => setState(() => _cart[item.id] = (_cart[item.id] ?? 0) > 0 ? _cart[item.id]! - 1 : 0),
                                      icon: const Icon(Icons.remove_circle_outline),
                                    ),
                                    Text('${_cart[item.id] ?? 0}'),
                                    IconButton(
                                      onPressed: () => setState(() => _cart[item.id] = (_cart[item.id] ?? 0) + 1),
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: cartCount == 0 ? null : () => _checkout(items),
                  icon: const Icon(Icons.shopping_cart_checkout_outlined),
                  label: Text('Checkout ($cartCount items)'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: FirestoreGateway.instance.watchLeaderboard(),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(
              title: 'Volunteer rankings',
              subtitle: 'Weekly, monthly, and overall points for volunteer activity.',
              icon: Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 16),
            if (snapshot.hasError)
              _ErrorPanel(error: snapshot.error!)
            else if (entries.isEmpty)
              const EmptyStatePanel(
                icon: Icons.emoji_events_outlined,
                title: 'No ranking data yet',
                subtitle: 'Points will populate when volunteers start submitting updates and closing cases.',
              )
            else
              ...entries.asMap().entries.map((entry) => Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${entry.key + 1}')),
                      title: Text(entry.value.name),
                      subtitle: Text('${entry.value.casesClosed} cases • ${entry.value.healthUpdates} health • ${entry.value.feedingUpdates} feeding'),
                      trailing: Text('${entry.value.points} pts'),
                    ),
                  )),
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
            backgroundImage: (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                ? const Icon(Icons.person, size: 44, color: AppTheme.primary)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text(profile.fullName, style: Theme.of(context).textTheme.headlineSmall)),
        Center(child: Text(profile.role.label, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileRow(icon: Icons.email_outlined, label: 'Email', value: profile.email),
                if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
                  _ProfileRow(icon: Icons.phone_outlined, label: 'Phone', value: profile.phoneNumber!),
                if (profile.bio.isNotEmpty) _ProfileRow(icon: Icons.info_outline, label: 'Bio', value: profile.bio),
                _ProfileRow(icon: Icons.stars_outlined, label: 'Points', value: '${profile.points}'),
                if (profile.role == UserRole.volunteer)
                  _ProfileRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Volunteer',
                    value: profile.isApprovedVolunteer ? 'Approved' : 'Pending approval',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (profile.role == UserRole.volunteer)
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FundraisingManagePage(profile: profile)),
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

  Future<void> _edit(BuildContext context, [FundraisingProject? existing]) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    final goalController = TextEditingController(text: existing?.goalAmount.toStringAsFixed(0) ?? '');
    final imageController = TextEditingController(text: existing?.imageUrl ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'New fundraising project' : 'Edit project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              TextField(controller: goalController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Goal amount (RM)')),
              const SizedBox(height: 8),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true) return;
    final goal = double.tryParse(goalController.text.trim()) ?? 0;
    if (titleController.text.trim().isEmpty || goal <= 0) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a title and a valid goal.')));
      return;
    }
    try {
      await FirestoreGateway.instance.createFundraising(FundraisingProject(
        id: existing?.id ?? '',
        title: titleController.text.trim(),
        description: descController.text.trim(),
        goalAmount: goal,
        raisedAmount: existing?.raisedAmount ?? 0,
        createdBy: profile.uid,
        createdByName: profile.fullName,
        imageUrl: imageController.text.trim().isEmpty ? null : imageController.text.trim(),
        createdAt: existing?.createdAt ?? DateTime.now(),
      ));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(existing == null ? 'Project created.' : 'Project updated.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My fundraising')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
      body: StreamBuilder<List<FundraisingProject>>(
        stream: FirestoreGateway.instance.watchFundraising(createdBy: profile.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _ErrorPanel(error: snapshot.error!);
          final projects = snapshot.data ?? const <FundraisingProject>[];
          if (projects.isEmpty) {
            return const EmptyStatePanel(
              icon: Icons.savings_outlined,
              title: 'No projects yet',
              subtitle: 'Tap "New project" to start raising funds for a cat in need.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: projects
                .map((p) => FundraisingCard(
                      project: p,
                      profile: profile,
                      onManage: () => _edit(context, p),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, required this.value});

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
          SizedBox(width: 72, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<Map<String, int>> _countsFuture = FirestoreGateway.instance.computeCounts();
  bool _seeding = false;

  Future<void> _seed() async {
    setState(() => _seeding = true);
    try {
      await FirestoreGateway.instance.seedDemoData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample clinics, shop items, cats, rankings, and fundraising added.')),
      );
      setState(() => _countsFuture = FirestoreGateway.instance.computeCounts());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seeding failed: $error')));
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _countsFuture,
      builder: (context, snapshot) {
        final counts = snapshot.data ?? const <String, int>{};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(
              title: 'Admin center',
              subtitle: 'Manage users, volunteers, donations, analytics, and system monitoring.',
              icon: Icons.admin_panel_settings_outlined,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(label: 'Users', value: '${counts['users'] ?? 0}', icon: Icons.group_outlined),
                _MetricCard(label: 'Reports', value: '${counts['reports'] ?? 0}', icon: Icons.assignment_outlined),
                _MetricCard(label: 'Cats', value: '${counts['cats'] ?? 0}', icon: Icons.pets_outlined),
                _MetricCard(label: 'Donations', value: '${counts['donations'] ?? 0}', icon: Icons.volunteer_activism_outlined),
                _MetricCard(label: 'Shop items', value: '${counts['shopItems'] ?? 0}', icon: Icons.storefront_outlined),
                _MetricCard(label: 'Clinics', value: '${counts['clinics'] ?? 0}', icon: Icons.local_hospital_outlined),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: const Text('Manage users'),
                subtitle: const Text('Edit roles, suspend, or remove accounts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AdminUsersPage(profile: widget.profile)),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_outlined),
                title: const Text('Treasury'),
                subtitle: const Text('Donations, shop sales, and fund allocations'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AdminTreasuryPage(profile: widget.profile)),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Fund requests'),
                subtitle: const Text('Approve and assign money to funding cases'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AdminFundRequestsPage(profile: widget.profile)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _seeding ? null : _seed,
              icon: _seeding
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_fix_high),
              label: Text(_seeding ? 'Seeding...' : 'Seed demo data (clinics, shop, cats, rankings)'),
            ),
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
                items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
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
            TextButton(onPressed: () => Navigator.pop(ctx, 'delete'), child: const Text('Delete', style: TextStyle(color: AppTheme.error))),
            TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, 'save'), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (action == 'save') {
      await FirestoreGateway.instance.updateUser(user.uid, {
        'role': role.name,
        'isApprovedVolunteer': role == UserRole.volunteer || role == UserRole.admin,
        'isSuspended': suspended,
        'status': suspended ? 'suspended' : 'active',
      });
    } else if (action == 'delete') {
      if (!context.mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete user record?'),
          content: const Text('This removes the user profile document. (Their auth login is not removed.)'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          ],
        ),
      );
      if (confirm == true) await FirestoreGateway.instance.deleteUserDoc(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage users')),
      body: StreamBuilder<List<AppUserProfile>>(
        stream: FirestoreGateway.instance.watchAllUsers(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? const <AppUserProfile>[];
          if (users.isEmpty) {
            return const EmptyStatePanel(icon: Icons.group_outlined, title: 'No users', subtitle: 'Registered accounts will appear here.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                    child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?', style: const TextStyle(color: AppTheme.primary)),
                  ),
                  title: Text(user.fullName),
                  subtitle: Text('${user.email}\n${user.role.label}${user.isSuspended ? ' • SUSPENDED' : ''}'),
                  isThreeLine: true,
                  trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editUser(context, user)),
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

  double _sum(List<Map<String, dynamic>> items, String key) {
    return items.fold<double>(0, (total, item) => total + ((item[key] as num?)?.toDouble() ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treasury')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreGateway.instance.watchAllDonations(),
        builder: (context, donationSnapshot) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreGateway.instance.watchOrders(),
            builder: (context, orderSnapshot) {
              final donations = donationSnapshot.data ?? const [];
              final orders = orderSnapshot.data ?? const [];
              final donationTotal = _sum(donations, 'amount');
              final salesTotal = _sum(orders, 'total');

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const PageHeader(
                    title: 'Treasury',
                    subtitle: 'Income from donations and shop sales.',
                    icon: Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(label: 'Donations', value: 'RM ${donationTotal.toStringAsFixed(2)}', icon: Icons.volunteer_activism_outlined),
                      _MetricCard(label: 'Shop sales', value: 'RM ${salesTotal.toStringAsFixed(2)}', icon: Icons.storefront_outlined),
                      _MetricCard(label: 'Total', value: 'RM ${(donationTotal + salesTotal).toStringAsFixed(2)}', icon: Icons.savings_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Donations (${donations.length})', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (donations.isEmpty)
                    const Text('No donations recorded yet.')
                  else
                    ...donations.map((d) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.volunteer_activism_outlined),
                            title: Text('RM ${((d['amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}'),
                            subtitle: Text('${d['userName'] ?? d['userId'] ?? 'Anonymous'} • ${d['source'] ?? 'donation'}'),
                          ),
                        )),
                  const SizedBox(height: 20),
                  Text('Shop orders (${orders.length})', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (orders.isEmpty)
                    const Text('No shop orders yet.')
                  else
                    ...orders.map((o) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long_outlined),
                            title: Text('RM ${((o['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}'),
                            subtitle: Text('${(o['items'] as List?)?.length ?? 0} item(s) • ${o['status'] ?? ''}'),
                          ),
                        )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class AdminFundRequestsPage extends StatelessWidget {
  const AdminFundRequestsPage({required this.profile, super.key});

  final AppUserProfile profile;

  Future<void> _allocate(BuildContext context, Map<String, dynamic> request) async {
    final amount = (request['amount'] as num?)?.toDouble() ?? 0;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve & allocate funds'),
        content: Text('Allocate RM ${amount.toStringAsFixed(2)} for "${request['catName'] ?? 'cat'}"?\n\nReason: ${request['reason'] ?? ''}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
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
    try {
      await FirestoreGateway.instance.addNotification(
        title: 'Funding approved',
        body: 'RM ${amount.toStringAsFixed(2)} approved for ${request['catName'] ?? 'a cat'}.',
        targetUserId: request['requestedBy'] as String?,
        type: 'fund_approved',
      );
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funding approved and allocated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fund requests')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreGateway.instance.watchFundRequests(),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? const [];
          if (requests.isEmpty) {
            return const EmptyStatePanel(
              icon: Icons.savings_outlined,
              title: 'No fund requests',
              subtitle: 'Volunteers can request funding from their accepted cases.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
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
                          Expanded(child: Text('RM ${amount.toStringAsFixed(2)} • ${r['catName'] ?? 'Cat'}', style: Theme.of(context).textTheme.titleMedium)),
                          _StatusPill(label: status.toUpperCase()),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(r['reason']?.toString() ?? ''),
                      const SizedBox(height: 4),
                      Text('Requested by ${r['requestedByName'] ?? r['requestedBy'] ?? 'volunteer'}', style: Theme.of(context).textTheme.bodySmall),
                      if (status == 'pending') ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton(onPressed: () => _allocate(context, r), child: const Text('Approve & allocate')),
                            OutlinedButton(
                              onPressed: () => FirestoreGateway.instance.reviewFundRequest(
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

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<NotificationRecord>>(
        stream: FirestoreGateway.instance.watchNotifications(profile.uid),
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? const [];
          if (notifications.isEmpty) {
            return const EmptyStatePanel(
              icon: Icons.notifications_none,
              title: 'No notifications yet',
              subtitle: 'Alerts for reports, assignments, funding, and status updates will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.body),
                  trailing: item.read ? const Icon(Icons.check_circle, color: Colors.green) : null,
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not start a call to $rawPhone')));
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});

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
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
    );
  }
}