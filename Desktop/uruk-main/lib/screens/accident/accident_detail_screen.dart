import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/accident_report_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/back_button_handler.dart';
import '../../widgets/common/status_badge.dart';

class AccidentDetailScreen extends StatefulWidget {
  final String reportId;
  const AccidentDetailScreen({super.key, required this.reportId});

  @override
  State<AccidentDetailScreen> createState() => _AccidentDetailScreenState();
}

class _AccidentDetailScreenState extends State<AccidentDetailScreen> {
  final List<String> _pendingRepairPhotos = [];
  bool _isSubmitting = false;

  void _addPhoto() {
    setState(() {
      _pendingRepairPhotos
          .add('repair_new_${_pendingRepairPhotos.length + 1}');
    });
  }

  void _removePhoto(int index) {
    setState(() => _pendingRepairPhotos.removeAt(index));
  }

  Future<void> _submitRepairPhotos(AccidentReport report) async {
    if (_pendingRepairPhotos.isEmpty) return;
    setState(() => _isSubmitting = true);
    final ok = await context.read<AppProvider>().submitRepairPhotos(
      report.id,
      List.from(_pendingRepairPhotos),
    );
    setState(() {
      _isSubmitting = false;
      if (ok) _pendingRepairPhotos.clear();
    });
    if (!mounted) return;
    final l = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? l.accidentDetailUploadSuccess
            : l.accidentDetailUploadError),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final l = context.l10n;
    final report =
        app.accidents.where((r) => r.id == widget.reportId).firstOrNull;

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.accidentDetailTitle)),
        body: Center(child: Text(l.accidentDetailNotFound)),
      );
    }

    // Customer app: customers can NEVER upload repair photos.
    // Only the admin / maintenance team does that (from the dashboard).
    // Customer is read-only for repair photos.
    const canUploadRepairPhotos = false;

    return BackButtonHandler(
      fallbackRoute: '/accidents',
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.accidentDetailTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/accidents'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: l.accidentDetailPrintTooltip,
            onPressed: () => _showPrintDialog(context, report),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusHeader(report: report),
            const SizedBox(height: 20),

            _SectionCard(
              title: l.accidentDetailInfoSection,
              icon: Icons.info_outline,
              children: [
                _InfoRow(
                    label: l.accidentDetailDateLabel,
                    value: Helpers.formatDate(report.accidentDate)),
                _InfoRow(
                    label: l.accidentDetailLocationLabel,
                    value: report.location),
                _InfoRow(
                    label: l.accidentDetailSubmittedLabel,
                    value: Helpers.formatDateTime(report.submittedAt)),
                _InfoRow(
                    label: l.accidentDetailOtherPartyLabel,
                    value: report.otherPartyInvolved
                        ? l.accidentDetailYes
                        : l.accidentDetailNo),
              ],
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: l.accidentDetailDescSection,
              icon: Icons.description_outlined,
              children: [
                Text(report.description,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6)),
              ],
            ),
            const SizedBox(height: 16),

            if (report.photoUrls.isNotEmpty) ...[
              _SectionCard(
                title: l.accidentDetailPhotosSection(
                    report.photoUrls.length),
                icon: Icons.photo_library_outlined,
                children: [
                  _PhotoGrid(
                      photoUrls: report.photoUrls,
                      accentColor: AppColors.primary),
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (report.maintenanceNotes != null) ...[
              _SectionCard(
                title: l.accidentDetailMaintenanceSection,
                icon: Icons.build_outlined,
                accentColor: AppColors.success,
                children: [
                  Text(report.maintenanceNotes!,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6)),
                  if (report.completedAt != null) ...[
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        l.accidentDetailCompletedAt(
                            Helpers.formatDate(report.completedAt!)),
                        style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (report.repairPhotoUrls != null &&
                report.repairPhotoUrls!.isNotEmpty) ...[
              _SectionCard(
                title: l.accidentDetailRepairPhotosSection(
                    report.repairPhotoUrls!.length),
                icon: Icons.photo_camera_outlined,
                accentColor: AppColors.success,
                children: [
                  _PhotoGrid(
                      photoUrls: report.repairPhotoUrls!,
                      accentColor: AppColors.success),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Repair archive (from maintenance team)
            if (report.repairArchive.isNotEmpty) ...[
              ...report.repairArchive.asMap().entries.map((entry) {
                final e = entry.value;
                final idx = entry.key;
                return _SectionCard(
                  title: '${l.accidentDetailRepairEntry} #${idx + 1}${e.isFinal ? ' (${l.accidentDetailFinalRepair})' : ''}',
                  icon: e.isFinal ? Icons.check_circle_outline : Icons.build_circle_outlined,
                  accentColor: AppColors.success,
                  children: [
                    _InfoRow(label: l.accidentDetailRepairDate, value: Helpers.formatDate(e.date)),
                    _InfoRow(label: l.accidentDetailTechnician, value: e.technician),
                    const SizedBox(height: 6),
                    Text(e.description,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
                    if (e.partsReplaced.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(l.accidentDetailPartsReplaced,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: e.partsReplaced.map((p) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(p, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                        )).toList(),
                      ),
                    ],
                    if (e.photos.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _PhotoGrid(photoUrls: e.photos, accentColor: AppColors.success),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 16),
            ],

            if (canUploadRepairPhotos) ...[
              _UploadRepairPhotosSection(
                pendingPhotos: _pendingRepairPhotos,
                isSubmitting: _isSubmitting,
                onAddPhoto: _addPhoto,
                onRemovePhoto: _removePhoto,
                onSubmit: () => _submitRepairPhotos(report),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
      ),
    );
  }

  void _showPrintDialog(BuildContext context, AccidentReport report) {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.accidentDetailPrintTitle),
        content: Text(l.accidentDetailPrintContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.commonCancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l.accidentDetailPrintPlaceholder)),
              );
            },
            child: Text(l.accidentDetailPrintButton),
          ),
        ],
      ),
    );
  }
}

// ── Upload Repair Photos Section ──────────────────────────────────────────────

class _UploadRepairPhotosSection extends StatelessWidget {
  final List<String> pendingPhotos;
  final bool isSubmitting;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemovePhoto;
  final VoidCallback onSubmit;

  const _UploadRepairPhotosSection({
    required this.pendingPhotos,
    required this.isSubmitting,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF065F46).withValues(alpha: 0.3),
            width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_photo_alternate_outlined,
                  color: Color(0xFF065F46), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.accidentDetailUploadSection,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF065F46)),
                ),
              ),
              if (pendingPhotos.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF065F46).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l.accidentDetailUploadPendingCount(
                        pendingPhotos.length),
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF065F46),
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 0),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.warning, size: 15),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    l.accidentDetailUploadHint,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...pendingPhotos.asMap().entries.map((e) => _PendingPhotoTile(
                    index: e.key,
                    onRemove: () => onRemovePhoto(e.key),
                  )),
              GestureDetector(
                onTap: onAddPhoto,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF065F46).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Color(0xFF065F46), size: 28),
                      const SizedBox(height: 4),
                      Text(l.accidentDetailUploadAddButton,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF065F46))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (pendingPhotos.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF065F46),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined,
                        color: Colors.white, size: 18),
                label: Text(
                  isSubmitting
                      ? l.accidentDetailUploadSubmitting
                      : l.accidentDetailUploadSubmitButton(
                          pendingPhotos.length),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PendingPhotoTile extends StatelessWidget {
  final int index;
  final VoidCallback onRemove;
  const _PendingPhotoTile({required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF065F46).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFF065F46).withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_outlined,
                  color: Color(0xFF065F46), size: 26),
              const SizedBox(height: 4),
              Text('${index + 1}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF065F46))),
            ],
          ),
        ),
        Positioned(
          top: -6,
          left: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                  color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 13),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Photo Grid ────────────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  final List<String> photoUrls;
  final Color accentColor;
  const _PhotoGrid({required this.photoUrls, required this.accentColor});

  void _openLightbox(BuildContext context, int startIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        pageBuilder: (_, __, ___) => _PhotoLightbox(
          photoUrls: photoUrls,
          initialIndex: startIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: photoUrls.asMap().entries.map((entry) {
        final i = entry.key;
        final url = entry.value;
        return GestureDetector(
          onTap: () => _openLightbox(context, i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                border: Border.all(color: accentColor.withValues(alpha: 0.2)),
              ),
              child: CachedNetworkImage(
                imageUrl: url,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(accentColor),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined, color: accentColor, size: 26),
                    const SizedBox(height: 2),
                    Text('${i + 1}',
                        style: TextStyle(fontSize: 10, color: accentColor)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Fullscreen image viewer — tap anywhere to dismiss, swipe between photos.
class _PhotoLightbox extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;
  const _PhotoLightbox({required this.photoUrls, required this.initialIndex});

  @override
  State<_PhotoLightbox> createState() => _PhotoLightboxState();
}

class _PhotoLightboxState extends State<_PhotoLightbox> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _currentIndex = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.photoUrls.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.photoUrls[i],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Page counter
            if (widget.photoUrls.length > 1)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.photoUrls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Status Header ─────────────────────────────────────────────────────────────

class _StatusHeader extends StatelessWidget {
  final AccidentReport report;
  const _StatusHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.car_crash_outlined,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.location,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('# ${report.id.toUpperCase()}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          StatusBadge.reportStatus(report.status),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? accentColor;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 0),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
