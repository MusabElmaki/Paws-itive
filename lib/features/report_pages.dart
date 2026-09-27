part of 'feature_pages.dart';

class ReportCatPage extends StatefulWidget {
  const ReportCatPage({required this.profile, super.key});

  final AppUserProfile profile;

  @override
  State<ReportCatPage> createState() => _ReportCatPageState();
}

class _ReportCatPageState extends State<ReportCatPage> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _bytes;
  bool _loading = false;
  bool _showPhotoError = false;
  bool _showLocationError = false;
  bool _showConditionError = false;
  bool _showDescriptionError = false;

  /// Selectable condition the reporter sees. "Other" lets them type free details.
  static const _conditions = [
    'Critical',
    'Injured',
    'Sick',
    'Needs feeding',
    'Healthy',
    'Other',
  ];
  String? _condition;

  LatLng? _coordinates;
  Timer? _draftTimer;
  late String _requestId;
  bool _restoring = true;
  late final _drafts = ReportDraftStore(widget.profile.uid);
  @override
  void initState() {
    super.initState();
    _requestId = Workflows.instance.newId();
    for (final c in [
      _nameController,
      _locationController,
      _descriptionController,
    ]) {
      c.addListener(_changed);
    }
    _restore();
  }

  Future<void> _restore() async {
    final d = await _drafts.load();
    if (!mounted) return;
    if (d != null) {
      _nameController.text = d['name'] as String? ?? '';
      _locationController.text = d['location'] as String? ?? '';
      _descriptionController.text = d['description'] as String? ?? '';
      _condition = d['condition'] as String?;
      _requestId = d['requestId'] as String? ?? _requestId;
      try {
        if (d['photo'] != null) _bytes = base64Decode(d['photo'] as String);
      } catch (_) {}
      if (d['latitude'] is num && d['longitude'] is num) {
        _coordinates = LatLng(
          (d['latitude'] as num).toDouble(),
          (d['longitude'] as num).toDouble(),
        );
      }
    }
    setState(() => _restoring = false);
  }

  void _changed() {
    if (_restoring || _loading) return;
    _requestId = Workflows.instance.newId();
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 400), _saveDraft);
  }

  Future<void> _saveDraft() => _drafts.save({
    'name': _nameController.text,
    'location': _locationController.text,
    'description': _descriptionController.text,
    'condition': _condition,
    'requestId': _requestId,
    'latitude': _coordinates?.latitude,
    'longitude': _coordinates?.longitude,
    'photo': _bytes == null ? null : base64Encode(_bytes!),
  });
  Future<void> _chooseLocation() async {
    final point = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initial: _coordinates),
      ),
    );
    if (point != null && mounted) {
      setState(() => _coordinates = point);
      _changed();
    }
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    if (!_restoring && !_loading) {
      unawaited(_saveDraft());
    }
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final photo = ImageUtil.encodeThumbnail(bytes, maxWidth: 800);
    if (!mounted || photo == null) return;
    setState(() {
      _bytes = base64Decode(photo.split(',').last);
      _showPhotoError = false;
    });
    _changed();
  }

  void _clearForm() {
    _restoring = true;
    _nameController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _draftTimer?.cancel();
    _drafts.clear();
    setState(() {
      _bytes = null;
      _condition = null;
      _coordinates = null;
      _requestId = Workflows.instance.newId();
      _restoring = false;
    });
  }

  Future<void> _submit() async {
    if (_loading || _restoring) return;
    final description = _descriptionController.text.trim();
    bool valid = true;
    final photoError = _bytes == null;
    final locationError = _locationController.text.trim().isEmpty;
    final conditionError = _condition == null;
    // When "Other" is chosen, the details field is where they explain it.
    final descriptionError = _condition == 'Other' && description.isEmpty;
    if (photoError || locationError || conditionError || descriptionError) {
      setState(() {
        _showPhotoError = photoError;
        _showLocationError = locationError;
        _showConditionError = conditionError;
        _showDescriptionError = descriptionError;
      });
      valid = false;
    }
    if (!valid) return;

    setState(() => _loading = true);
    try {
      _draftTimer?.cancel();
      await _saveDraft();
      final match = await CatMatchingService.instance.match(_bytes!);
      final photoPath = 'reports/${widget.profile.uid}/$_requestId/photo.jpg';
      await Workflows.instance.upload(photoPath, _bytes!, 'image/jpeg');
      await Workflows.instance.call('submitReport', {
        'requestId': _requestId,
        'photoPath': photoPath,
        'catName': _nameController.text.trim(),
        'locationName': _locationController.text.trim(),
        'description': description,
        'reportedCondition': _condition,
        'latitude': _coordinates?.latitude,
        'longitude': _coordinates?.longitude,
        'imageSignature': match.signature,
        'candidateCatId': match.existingCatId,
      });
      if (!mounted) return;
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report saved. Any suggested match awaits review.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report not confirmed. Your draft is saved; retry when connected. $error',
          ),
        ),
      );
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
        if (_restoring) const LinearProgressIndicator(),
        OutlinedButton.icon(
          onPressed: _loading || _restoring ? null : _chooseLocation,
          icon: const Icon(Icons.location_on),
          label: Text(
            _coordinates == null
                ? 'Choose location on map / GPS'
                : 'Pin: ${_coordinates!.latitude.toStringAsFixed(5)}, ${_coordinates!.longitude.toStringAsFixed(5)}',
          ),
        ),
        const Text(
          'Draft saved on this device. A written location is required; a map pin helps volunteers find the cat.',
        ),

        // Header row
        Row(
          children: [
            Expanded(
              child: Text(
                'Report Animal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: _loading || _restoring ? null : _clearForm,
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Animal Photo
        _FieldLabel(label: 'Animal Photo', required: true),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _loading || _restoring ? null : _pickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showPhotoError
                    ? errorColor
                    : AppTheme.primary.withValues(alpha: 0.45),
                width: 2,
              ),
              color: _showPhotoError
                  ? errorColor.withValues(alpha: 0.04)
                  : AppTheme.primary.withValues(alpha: 0.04),
            ),
            clipBehavior: Clip.antiAlias,
            child: _bytes != null
                ? Image.memory(
                    _bytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 44,
                        color: _showPhotoError
                            ? errorColor
                            : AppTheme.primary.withValues(alpha: 0.65),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to upload photo',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _showPhotoError
                              ? errorColor
                              : AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'image · JPG, PNG · max 5MB',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_showPhotoError)
          _InlineError('Animal photo is required before submitting'),
        const SizedBox(height: 20),

        // Cat name (optional)
        _FieldLabel(label: 'Cat name', required: false),
        const SizedBox(height: 8),
        TextField(
          enabled: !_loading && !_restoring,
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "e.g. Oyen, Tompok — or leave blank if unknown",
            prefixIcon: const Icon(Icons.pets_outlined),
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
        const SizedBox(height: 20),

        // Location Found
        _FieldLabel(label: 'Location Found', required: true),
        const SizedBox(height: 8),
        TextField(
          enabled: !_loading && !_restoring,
          controller: _locationController,
          onChanged: (_) {
            if (_showLocationError) setState(() => _showLocationError = false);
          },
          decoration: InputDecoration(
            hintText: 'e.g. N28 Engineering Block, UTM',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _showLocationError ? errorColor : Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _showLocationError
                    ? errorColor
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _showLocationError ? errorColor : AppTheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (_showLocationError)
          _InlineError('Please enter the location where the animal was found'),
        const SizedBox(height: 20),

        // Animal condition / status
        _FieldLabel(label: 'Animal status', required: true),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _conditions.map((c) {
            final selected = _condition == c;
            return ChoiceChip(
              label: Text(c),
              selected: selected,
              onSelected: _loading || _restoring ? null : (_) => setState(() {
                _condition = c;
                _changed();
                _showConditionError = false;
              }),
            );
          }).toList(),
        ),
        if (_showConditionError)
          _InlineError('Please select the animal\'s status'),
        const SizedBox(height: 20),

        // Description / details
        _FieldLabel(
          label: _condition == 'Other' ? 'Details' : 'Description',
          required: _condition == 'Other',
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: !_loading && !_restoring,
          controller: _descriptionController,
          maxLines: 4,
          minLines: 3,
          maxLength: 300,
          onChanged: (_) {
            if (_showDescriptionError) {
              setState(() => _showDescriptionError = false);
            }
          },
          decoration: InputDecoration(
            hintText: _condition == 'Other'
                ? 'Describe the situation and what the animal needs...'
                : "Describe the animal's condition, appearance, and behaviour...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _showDescriptionError
                    ? errorColor
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _showDescriptionError ? errorColor : AppTheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (_showDescriptionError)
          _InlineError('Please enter the details for "Other"'),
        const SizedBox(height: 24),

        // Submit
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _loading || _restoring ? null : _submit,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
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
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({
    required this.initialMessage,
    required this.confidence,
    super.key,
  });

  final String initialMessage;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).round();
    // Colour the meter by how likely it's a duplicate.
    final Color meterColor = confidence >= 0.82
        ? AppTheme.error
        : confidence >= 0.60
        ? Colors.orange
        : AppTheme.success;
    final String band = confidence >= 0.82
        ? 'Similar photo; review required'
        : confidence >= 0.60
        ? 'Possible visual match'
        : 'Likely a new cat';

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
                  Text(
                    initialMessage,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Visual similarity (not an identity probability)',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: confidence.clamp(0.0, 1.0),
                          minHeight: 26,
                          backgroundColor: meterColor.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(meterColor),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    band,
                    style: TextStyle(
                      color: meterColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
