import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/platform_image.dart';
import '../../models/car_change_request_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/back_button_handler.dart';

class AddCarScreen extends StatefulWidget {
  /// When true, shown as a required step after subscription (redirects to garage).
  final bool isPostSubscription;

  /// When true, always shows blank form for adding a new car (ignores existing cars).
  final bool isNewCar;

  const AddCarScreen({super.key, this.isPostSubscription = false, this.isNewCar = false});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();

  bool _isSaving = false;
  XFile? _carImage;
  final _picker = ImagePicker();

  late CarInfo? _originalCar;

  @override
  void initState() {
    super.initState();
    _originalCar = widget.isNewCar ? null : context.read<AuthProvider>().user?.car;
    if (_originalCar != null) {
      _makeCtrl.text = _originalCar!.make;
      _modelCtrl.text = _originalCar!.model;
      _yearCtrl.text = '${_originalCar!.year}';
      _colorCtrl.text = _originalCar!.color;
      _plateCtrl.text = _originalCar!.plateNumber;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) context.read<AppProvider>().loadCarChangeRequests(user.id);
    });
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => _originalCar != null && !widget.isPostSubscription;

  Future<void> _pickCarImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _carImage = picked);
  }

  Map<String, String> _getChangedFields() {
    if (_originalCar == null) return {};
    final changes = <String, String>{};
    if (_makeCtrl.text.trim() != _originalCar!.make) changes['make'] = _makeCtrl.text.trim();
    if (_modelCtrl.text.trim() != _originalCar!.model) changes['model'] = _modelCtrl.text.trim();
    if (_yearCtrl.text.trim() != '${_originalCar!.year}') changes['year'] = _yearCtrl.text.trim();
    if (_colorCtrl.text.trim() != _originalCar!.color) changes['color'] = _colorCtrl.text.trim();
    if (_plateCtrl.text.trim() != _originalCar!.plateNumber) changes['plateNumber'] = _plateCtrl.text.trim();
    return changes;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = context.l10n;

    if (_isEditing) {
      final changes = _getChangedFields();
      if (changes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.carNoChanges)),
        );
        return;
      }
      await _submitChangeRequest(changes);
      return;
    }

    setState(() => _isSaving = true);
    // Upload car image (if any) through the central UploadService so we
    // store a real remote URL on the car record instead of a local path.
    String? imageUrl;
    if (_carImage != null) {
      try {
        imageUrl = await UploadService().upload(
          _carImage!,
          folder: 'cars',
        );
      } catch (_) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.commonErrorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    try {
      final car = await ApiService().addCar(
        make: _makeCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        year: int.parse(_yearCtrl.text.trim()),
        color: _colorCtrl.text.trim(),
        plateNumber: _plateCtrl.text.trim(),
        imageUrl: imageUrl,
      );
      if (!mounted) return;
      context.read<AuthProvider>().addCar(car);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.commonErrorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.carSaveSuccess)),
    );
    if (widget.isPostSubscription) {
      context.go('/garage');
    } else {
      context.canPop() ? context.pop() : context.go('/garage');
    }
  }

  Future<void> _submitChangeRequest(Map<String, String> changes) async {
    setState(() => _isSaving = true);
    final user = context.read<AuthProvider>().user!;
    await context.read<AppProvider>().submitCarChangeRequest(
      userId: user.id,
      requestedChanges: changes,
    );
    setState(() => _isSaving = false);
    if (!mounted) return;
    _showRequestSentDialog(changes);
  }

  void _showRequestSentDialog(Map<String, String> changes) {
    final l = context.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 10),
            Text(l.carChangeRequestSentTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.carChangeRequestSentContent,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Text(
              l.carChangesLabel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...changes.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.arrow_left, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${CarChangeRequest.fieldLabels[e.key] ?? e.key}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Expanded(
                    child: Text(e.value,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.canPop() ? context.pop() : context.go('/garage');
            },
            child: Text(l.commonOk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequest = context.watch<AppProvider>().pendingCarChangeRequest;
    final l = context.l10n;

    return BackButtonHandler(
      fallbackRoute: '/garage',
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? l.carEditTitle : l.carAddTitle),
        leading: widget.isPostSubscription
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.canPop() ? context.pop() : context.go('/garage')),
        automaticallyImplyLeading: !widget.isPostSubscription,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.directions_car,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? l.carEditTitle : l.carAddTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isEditing
                                ? l.carEditModeNote
                                : l.carSubscriptionActivatedBanner,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF856404), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.carEditModeNote,
                          style: const TextStyle(
                              color: Color(0xFF856404), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_isEditing && pendingRequest != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pending_actions,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l.carPendingRequestWarning,
                            style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...pendingRequest.requestedChanges.entries.map((e) =>
                          Text(
                            '• ${CarChangeRequest.fieldLabels[e.key] ?? e.key}: ${e.value}',
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 12),
                          )),
                    ],
                  ),
                ),
              ],

              if (widget.isPostSubscription) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.carSubscriptionActivatedBanner,
                          style: const TextStyle(
                              color: AppColors.success, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Car photo picker (add/new mode only) ──────────────────
              if (!_isEditing) ...[
                GestureDetector(
                  onTap: _pickCarImage,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _carImage != null
                            ? AppColors.primary
                            : AppColors.divider,
                        width: _carImage != null ? 2 : 1,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: _carImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: PlatformImage(
                              _carImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.add_a_photo_outlined,
                                    color: AppColors.primary, size: 26),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l.carPhotoAddLabel,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                l.carPhotoHint,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_carImage != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: _pickCarImage,
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: Text(l.carPhotoChangeLabel,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],

              AppTextField(
                label: l.carMakeLabel,
                hint: l.carMakeHint,
                controller: _makeCtrl,
                prefixIcon: Icons.business_outlined,
                validator: Validators.required(context, fieldName: l.profileCarMake),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: l.carModelLabel,
                hint: l.carModelHint,
                controller: _modelCtrl,
                prefixIcon: Icons.directions_car_outlined,
                validator: Validators.required(context, fieldName: l.profileCarModel),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: l.carYearLabel,
                hint: l.carYearHint,
                controller: _yearCtrl,
                prefixIcon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: Validators.year(context),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: l.carColorLabel,
                hint: l.carColorHint,
                controller: _colorCtrl,
                prefixIcon: Icons.palette_outlined,
                validator: Validators.required(context, fieldName: l.profileCarColor),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: l.carPlateLabel,
                hint: l.carPlateHint,
                controller: _plateCtrl,
                prefixIcon: Icons.badge_outlined,
                validator: Validators.required(context, fieldName: l.profileCarPlate),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              AppButton(
                label: _isEditing ? l.carSendChangeButton : l.carAddButton,
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
                icon: _isEditing ? Icons.send : Icons.check,
              ),

              if (widget.isPostSubscription) ...[
                const SizedBox(height: 12),
                AppButton(
                  label: l.carSkipButton,
                  isOutlined: true,
                  onPressed: () => context.go('/garage'),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
