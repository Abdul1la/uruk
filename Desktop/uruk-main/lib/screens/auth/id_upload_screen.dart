import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/platform_image.dart';
import '../../providers/auth_provider.dart';
import '../../services/upload_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/back_button_handler.dart';

/// Per-card upload state — drives the card's visual feedback so the user
/// always knows whether the image is sitting on their device vs. actually
/// stored on the server.
enum _UploadState { empty, uploading, uploaded, failed }

class _SideState {
  XFile? file;
  String? remoteUrl;
  _UploadState status = _UploadState.empty;
  String? errorMessage;
}

class IdUploadScreen extends StatefulWidget {
  const IdUploadScreen({super.key});

  @override
  State<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends State<IdUploadScreen> {
  final _front = _SideState();
  final _back = _SideState();
  bool _isSubmitting = false;

  final _picker = ImagePicker();

  bool get _bothUploaded =>
      _front.status == _UploadState.uploaded &&
      _back.status == _UploadState.uploaded;

  bool get _anyUploading =>
      _front.status == _UploadState.uploading ||
      _back.status == _UploadState.uploading;

  Future<void> _pickAndUpload(_SideState side) async {
    // Pick source — gallery only on web (for user-gesture reasons), bottom
    // sheet on native.
    final ImageSource? source;
    if (kIsWeb) {
      source = ImageSource.gallery;
    } else {
      final l = context.l10n;
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l.oilChangeTakePhoto),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l.oilChangeFromGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    }
    if (source == null) return;

    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.commonErrorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (picked == null || !mounted) return;

    // Switch card into "uploading" state immediately so the user sees a
    // spinner on the card and cannot mistake a locally-picked file for one
    // that's already on the server.
    setState(() {
      side.file = picked;
      side.remoteUrl = null;
      side.status = _UploadState.uploading;
      side.errorMessage = null;
    });

    await _uploadSide(side);
  }

  Future<void> _uploadSide(_SideState side) async {
    final file = side.file;
    if (file == null) return;
    try {
      final url = await UploadService().upload(file, folder: 'ids');
      if (!mounted) return;
      setState(() {
        side.remoteUrl = url;
        side.status = _UploadState.uploaded;
        side.errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        side.status = _UploadState.failed;
        side.errorMessage = e.toString();
      });
    }
  }

  Future<void> _retryUpload(_SideState side) async {
    if (side.file == null) return;
    setState(() {
      side.status = _UploadState.uploading;
      side.errorMessage = null;
    });
    await _uploadSide(side);
  }

  Future<void> _submit() async {
    final l = context.l10n;

    // Nothing picked yet — same guard as before.
    if (_front.file == null || _back.file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.idUploadBothSidesRequired),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Still uploading — block submit with a clear message.
    if (_anyUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يُرجى الانتظار حتى اكتمال رفع الصور'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // One of the uploads failed — ask the user to retry that specific card.
    if (!_bothUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يكتمل رفع الصور. يرجى إعادة المحاولة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    try {
      final ok = await auth.submitIdImages(
        frontUrl: _front.remoteUrl!,
        backUrl: _back.remoteUrl!,
      );
      if (!mounted) return;
      if (ok) {
        context.go('/pending');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.commonErrorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.commonErrorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return BackButtonHandler(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(l.idUploadTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.info, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.idUploadInstructions,
                          style: const TextStyle(
                              color: AppColors.info, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                _IdUploadCard(
                  title: l.idFrontLabel,
                  subtitle: l.idUploadFrontSubtitle,
                  side: _front,
                  onTap: () => _pickAndUpload(_front),
                  onRetry: () => _retryUpload(_front),
                ),
                const SizedBox(height: 20),
                _IdUploadCard(
                  title: l.idBackLabel,
                  subtitle: l.idUploadBackSubtitle,
                  side: _back,
                  onTap: () => _pickAndUpload(_back),
                  onRetry: () => _retryUpload(_back),
                ),
                const SizedBox(height: 32),

                AppButton(
                  label: _anyUploading
                      ? 'جاري رفع الصور...'
                      : l.idUploadSubmit,
                  onPressed:
                      (_isSubmitting || _anyUploading) ? null : _submit,
                  isLoading: _isSubmitting,
                  icon: Icons.send_outlined,
                ),
                const SizedBox(height: 12),

                Center(
                  child: Text(
                    l.idUploadDisclaimer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
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

class _IdUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final _SideState side;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  const _IdUploadCard({
    required this.title,
    required this.subtitle,
    required this.side,
    required this.onTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hasFile = side.file != null;
    final isUploading = side.status == _UploadState.uploading;
    final isUploaded = side.status == _UploadState.uploaded;
    final isFailed = side.status == _UploadState.failed;

    // Border color reflects the true state of the upload.
    final Color borderColor = isUploaded
        ? AppColors.success
        : isFailed
            ? AppColors.error
            : hasFile
                ? AppColors.primary
                : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 10),
        GestureDetector(
          // While uploading we ignore taps so the user can't double-trigger.
          onTap: isUploading ? null : onTap,
          child: DottedBorder(
            color: borderColor,
            strokeWidth: 1.5,
            dashPattern: const [8, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: hasFile
                    ? AppColors.primarySurface
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: hasFile
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: PlatformImage(
                            side.file!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        // Uploading overlay — dims the preview and shows a
                        // spinner so it's crystal clear the file is being
                        // sent to the server right now.
                        if (isUploading)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'جاري رفع الصورة...',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Failed overlay — makes it obvious the image is NOT
                        // on the server yet and offers a one-tap retry.
                        if (isFailed)
                          Container(
                            color: Colors.black.withValues(alpha: 0.55),
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.white, size: 28),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'فشل رفع الصورة',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: onRetry,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('إعادة المحاولة'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      textStyle:
                                          const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined,
                            size: 36, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Text(l.idUploadTapHint,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
            ),
          ),
        ),

        // Status line under the card — tells the user exactly where the
        // image stands: locally-picked only, on server, or failed.
        if (hasFile) ...[
          const SizedBox(height: 8),
          if (isUploading)
            Row(
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
                SizedBox(width: 6),
                Text('جاري الرفع إلى الخادم...',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            )
          else if (isUploaded)
            Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Text(l.idUploadSuccess,
                    style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero),
                  child: Text(l.commonRetake,
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            )
          else if (isFailed)
            Row(
              children: [
                const Icon(Icons.cancel,
                    color: AppColors.error, size: 16),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'لم تُرفع الصورة — اضغط "إعادة المحاولة"',
                    style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero),
                  child: Text(l.commonRetake,
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
