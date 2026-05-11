import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/platform_image.dart';
import '../../models/draft_report_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/draft_provider.dart';
import '../../services/api_service.dart' show ApiException;
import '../../services/upload_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/back_button_handler.dart';
import 'map_picker_screen.dart';

const int _maxPhotos = 10;

class ReportAccidentScreen extends StatefulWidget {
  final DraftReport? draft;
  const ReportAccidentScreen({super.key, this.draft});

  @override
  State<ReportAccidentScreen> createState() => _ReportAccidentScreenState();
}

class _ReportAccidentScreenState extends State<ReportAccidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final List<XFile> _photos = [];
  DateTime _accidentDate = DateTime.now();
  bool _otherPartyInvolved = false;
  bool _isSubmitting = false;
  bool _isSavingDraft = false;
  bool _isGettingLocation = false;

  double? _latitude;
  double? _longitude;

  String? _editingDraftId;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    if (d != null) {
      _editingDraftId = d.id;
      _locationCtrl.text = d.location;
      _descCtrl.text = d.description;
      _accidentDate = d.accidentDate;
      _otherPartyInvolved = d.otherPartyInvolved;
      _latitude = d.latitude;
      _longitude = d.longitude;
      // Restore photos from the draft.
      // On mobile, draft paths point at files on disk — they may have been
      // garbage-collected by the OS, so we'd normally check existence. Since
      // XFile construction is cheap and reading bytes later will surface
      // any missing files, we add them unconditionally. On web, paths are
      // blob URLs that only live for the current session; stale drafts will
      // fail to load but won't crash.
      for (final path in d.photoPaths) {
        _photos.add(XFile(path));
      }
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final l = context.l10n;
    if (_photos.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.accidentPhotosMaxReached(_maxPhotos))),
      );
      return;
    }
    // On web, image_picker only supports gallery, and showing a bottom sheet
    // first breaks the browser's "trusted user gesture" check, causing the
    // file dialog to silently fail (or reload the page in some builds).
    // Skip the sheet on web and call pickImage directly from the user tap.
    if (kIsWeb) {
      try {
        final f = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
            maxWidth: 1600,
            maxHeight: 1600);
        if (f != null && mounted) setState(() => _photos.add(f));
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.commonErrorGeneric)),
          );
        }
      }
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: Text(l.accidentPhotosTakePhoto),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final f = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                      maxWidth: 1600,
                      maxHeight: 1600);
                  if (f != null && mounted) setState(() => _photos.add(f));
                } catch (_) {}
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: Text(l.accidentPhotosFromGallery),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final f = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                  if (f != null && mounted) setState(() => _photos.add(f));
                } catch (_) {}
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _accidentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _accidentDate = picked);
  }

  Future<void> _getGpsLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.accidentLocationPermissionDenied),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            if (p.subLocality?.isNotEmpty == true) p.subLocality,
            if (p.locality?.isNotEmpty == true) p.locality,
            if (p.administrativeArea?.isNotEmpty == true)
              p.administrativeArea,
          ].whereType<String>().toList();
          final address = parts.isNotEmpty
              ? parts.join('، ')
              : '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
          if (mounted) setState(() => _locationCtrl.text = address);
        }
      } catch (_) {
        if (mounted) {
          setState(() => _locationCtrl.text =
              '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.l10n.accidentLocationGpsError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: _latitude,
          initialLng: _longitude,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
    });
    try {
      final placemarks =
          await placemarkFromCoordinates(result.latitude, result.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = [
          if (p.subLocality?.isNotEmpty == true) p.subLocality,
          if (p.locality?.isNotEmpty == true) p.locality,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea,
        ].whereType<String>().toList();
        final address = parts.isNotEmpty
            ? parts.join('، ')
            : '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
        setState(() => _locationCtrl.text = address);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _locationCtrl.text =
            '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}');
      }
    }
  }

  Future<void> _saveDraft() async {
    setState(() => _isSavingDraft = true);
    final draftProvider = context.read<DraftProvider>();
    await draftProvider.saveDraft(
      existingId: _editingDraftId,
      location: _locationCtrl.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      description: _descCtrl.text.trim(),
      accidentDate: _accidentDate,
      otherPartyInvolved: _otherPartyInvolved,
      photoPaths: _photos.map((f) => f.path).toList(),
    );
    if (mounted) {
      setState(() => _isSavingDraft = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.accidentDraftSavedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      context.canPop() ? context.pop() : context.go('/accidents');
    }
  }

  bool _checkRepairLimit() {
    final l = context.l10n;
    final car = context.read<AppProvider>().selectedCar ??
        context.read<AuthProvider>().user?.car;
    if (car == null) return true;

    // Block if no active subscription
    if (car.subscription == SubscriptionType.none) {
      showDialog(
        context: context,
        builder: (dlgCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.block_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l.accidentNoSubscriptionTitle)),
            ],
          ),
          content: Text(l.accidentNoSubscriptionContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: Text(l.commonOk),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dlgCtx);
                context.push('/subscription');
              },
              child: Text(l.accidentNoSubscriptionAction),
            ),
          ],
        ),
      );
      return false;
    }

    // Block if monthly repair quota exhausted
    if (!car.repairsExhausted) return true;

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.block_outlined, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text(l.accidentRepairLimitTitle),
          ],
        ),
        content: Text(
          l.accidentRepairLimitContent(
            car.repairsUsedThisMonth,
            car.repairsAllowedPerMonth,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text(l.commonOk),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              context.push('/subscription');
            },
            child: Text(l.accidentRepairLimitUpgrade),
          ),
        ],
      ),
    );
    return false;
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.accidentPhotosRequiredError),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (!_checkRepairLimit()) return;

    setState(() => _isSubmitting = true);
    final authProvider = context.read<AuthProvider>();
    final appProvider = context.read<AppProvider>();
    final draftProvider = context.read<DraftProvider>();
    final user = authProvider.user!;
    final carId =
        (appProvider.selectedCar ?? authProvider.user?.car)?.id;

    // Upload all accident photos via the central upload service first,
    // then persist the remote URLs on the report.
    List<String> photoUrls;
    try {
      photoUrls = await UploadService().uploadMany(
        _photos,
        folder: 'accidents',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      // Show the actual backend error (e.g. "File too large",
      // "Unsupported file type") so the user can fix the input.
      final msg = e is ApiException ? e.message : l.commonErrorGeneric;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await appProvider.submitAccidentReport(
      userId: user.id,
      carId: carId,
      accidentDate: _accidentDate,
      location: _locationCtrl.text.trim(),
      lat: _latitude,
      lng: _longitude,
      description: _descCtrl.text.trim(),
      otherPartyInvolved: _otherPartyInvolved,
      photoUrls: photoUrls,
    );
    if (carId != null && mounted) {
      authProvider.incrementCarRepairs(carId);
    }
    if (_editingDraftId != null && mounted) {
      await draftProvider.deleteDraft(_editingDraftId!);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.accidentSubmittedSuccess)),
      );
      context.canPop() ? context.pop() : context.go('/accidents');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return BackButtonHandler(
      fallbackRoute: '/accidents',
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_editingDraftId != null
            ? l.accidentEditDraftTitle
            : l.accidentReportTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.canPop() ? context.pop() : context.go('/accidents'),
        ),
        actions: [
          if (!_isSubmitting)
            TextButton.icon(
              onPressed: _isSavingDraft ? null : _saveDraft,
              icon: _isSavingDraft
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.bookmark_outline,
                      color: Colors.white, size: 18),
              label: Text(l.accidentDraftButton,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Draft indicator
              if (_editingDraftId != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCA28)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note,
                          color: Color(0xFF856404), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.accidentDraftEditingNote,
                          style: const TextStyle(
                              color: Color(0xFF856404),
                              fontSize: 12,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.accidentInfoBanner,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Photos ────────────────────────────────────────────────
              Row(
                children: [
                  Text(l.accidentPhotosTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Text(
                    l.accidentPhotosCountLabel(
                        _photos.length, _maxPhotos),
                    style: TextStyle(
                        fontSize: 12,
                        color: _photos.length >= _maxPhotos
                            ? AppColors.error
                            : AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l.accidentPhotosSubtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              _PhotoGrid(
                photos: _photos,
                onAdd: _pickPhoto,
                onRemove: (i) => setState(() => _photos.removeAt(i)),
              ),
              const SizedBox(height: 24),

              // ── Accident date ────────────────────────────────────────
              Text(l.accidentDateTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(Helpers.formatDate(_accidentDate),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary)),
                      const Spacer(),
                      const Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Location ────────────────────────────────────────────
              Text(l.accidentLocationTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.validatorRequired(
                        l.accidentDetailLocationLabel)
                    : null,
                decoration: InputDecoration(
                  hintText: l.accidentLocationHint,
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.primary),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isGettingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.my_location,
                                  color: AppColors.primary, size: 20),
                              tooltip: l.accidentLocationGpsTooltip,
                              onPressed: _getGpsLocation,
                            ),
                      IconButton(
                        icon: const Icon(Icons.map_outlined,
                            color: AppColors.primary, size: 20),
                        tooltip: l.accidentLocationMapTooltip,
                        onPressed: _openMapPicker,
                      ),
                    ],
                  ),
                ),
              ),
              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pin_drop_outlined,
                          color: AppColors.primary, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontFamily: 'monospace'),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(
                            () {
                              _latitude = null;
                              _longitude = null;
                            }),
                        child: const Icon(Icons.close,
                            color: AppColors.primary, size: 13),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────────
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.validatorRequired(
                        l.accidentDetailDescSection)
                    : null,
                decoration: InputDecoration(
                  labelText: l.accidentDescriptionLabel,
                  hintText: l.accidentDescriptionHint,
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description_outlined,
                        color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Other party ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.accidentOtherPartyTitle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(l.accidentOtherPartySubtitle,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _otherPartyInvolved,
                      onChanged: (v) =>
                          setState(() => _otherPartyInvolved = v),
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primaryLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Action buttons ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: (_isSavingDraft || _isSubmitting)
                          ? null
                          : _saveDraft,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isSavingDraft
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary))
                          : const Icon(Icons.bookmark_border,
                              color: AppColors.primary, size: 18),
                      label: Text(l.accidentSaveDraftButton,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: l.accidentSubmitButton,
                      onPressed: (_isSubmitting || _isSavingDraft)
                          ? null
                          : _submit,
                      isLoading: _isSubmitting,
                      icon: Icons.send_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// ── Photo Grid ────────────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  final List<XFile> photos;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  const _PhotoGrid(
      {required this.photos, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...List.generate(
            photos.length,
            (i) =>
                _PhotoThumb(file: photos[i], onRemove: () => onRemove(i))),
        if (photos.length < _maxPhotos) _AddPhotoBtn(onTap: onAdd),
      ],
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;
  const _PhotoThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: PlatformImage(file, width: 90, height: 90, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                  color: AppColors.error, shape: BoxShape.circle),
              child:
                  const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppColors.primary, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined,
                color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(context.l10n.commonAddPhoto,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
