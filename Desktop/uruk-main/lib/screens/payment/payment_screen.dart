import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/platform_image.dart';
import '../../models/payment_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/upload_service.dart';
import '../../widgets/common/back_button_handler.dart';
import '../../widgets/common/status_badge.dart';

class PaymentScreen extends StatefulWidget {
  /// When set, the screen scopes to payments for this car only.
  final String? carId;
  const PaymentScreen({super.key, this.carId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.zaincash;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      final app = context.read<AppProvider>();
      if (user != null) app.loadPayments(user.id);
      // Refetch admin-managed payment accounts every time the screen opens.
      // Otherwise the customer keeps showing the snapshot taken at login,
      // missing newly uploaded QR codes / numbers.
      app.loadPaymentAccounts();
    });
  }

  Future<XFile?> _pickImage(ImageSource source) =>
      _picker.pickImage(source: source, maxWidth: 1200, imageQuality: 85);

  void _showPayProofSheet(
      BuildContext context, AppProvider app, PaymentRecord payment) {
    final l = context.l10n;
    final methodLabel = switch (_selectedMethod) {
      PaymentMethod.zaincash => l.paymentMethodZainCash,
      PaymentMethod.superQi => l.paymentMethodSuperQi,
      PaymentMethod.other => l.paymentMethodOther,
    };

    XFile? sheetProof;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          Future<void> pickFrom(ImageSource src) async {
            Navigator.pop(sheetCtx);
            final picked = await _pickImage(src);
            if (picked != null) {
              setSheetState(() => sheetProof = picked);
            }
          }

          Future<void> showSourcePicker() async {
            // On web, image_picker only supports gallery and the bottom sheet
            // breaks the browser's user-gesture context, so skip it.
            if (kIsWeb) {
              try {
                final picked = await _pickImage(ImageSource.gallery);
                if (picked != null) setSheetState(() => sheetProof = picked);
              } catch (_) {}
              return;
            }
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              builder: (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined),
                      title: Text(l.oilChangeTakePhoto),
                      onTap: () => pickFrom(ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: Text(l.oilChangeFromGallery),
                      onTap: () => pickFrom(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    l.paymentConfirmTitle,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.paymentConfirmContent(
                      Helpers.formatCurrency(payment.amountIQD),
                      methodLabel,
                      payment.month,
                    ),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Proof upload area
                  Text(
                    l.paymentProofUploadLabel,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: showSourcePicker,
                    child: Container(
                      width: double.infinity,
                      height: sheetProof != null ? 180 : 100,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sheetProof != null
                              ? AppColors.primary
                              : AppColors.divider,
                          width: sheetProof != null ? 2 : 1,
                        ),
                      ),
                      child: sheetProof != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: PlatformImage(
                                    sheetProof!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.edit_outlined,
                                            color: Colors.white, size: 13),
                                        const SizedBox(width: 4),
                                        Text(l.paymentProofChangeLabel,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload_file_outlined,
                                    color: AppColors.primary, size: 30),
                                const SizedBox(height: 6),
                                Text(l.paymentProofUploadLabel,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary)),
                                Text(l.paymentProofUploadHint,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                    ),
                  ),

                  if (sheetProof == null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(l.paymentProofUploadHint,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.warning)),
                    ]),
                  ],

                  const SizedBox(height: 24),

                  // Confirm button
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      // Upload proof image first (if one was selected).
                      String? proofUrl;
                      if (sheetProof != null) {
                        try {
                          proofUrl = await UploadService().upload(
                            sheetProof!,
                            folder: 'payments',
                          );
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l.commonErrorGeneric),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                          return;
                        }
                      }
                      await app.markPaymentMade(
                        payment.id,
                        _selectedMethod,
                        proofImageUrl: proofUrl,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.paymentSnackbarSuccess)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(l.paymentIvePaid(
                        Helpers.formatCurrency(payment.amountIQD))),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44)),
                    child: Text(l.commonCancel,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final l = context.l10n;

    // Scope to a specific car when carId is provided.
    final due = widget.carId != null
        ? app.duePaymentForCar(widget.carId!)
        : app.currentDuePayment;
    final history = widget.carId != null
        ? app.paymentsForCar(widget.carId!)
        : app.payments;

    return BackButtonHandler(
      fallbackRoute: '/my-cars',
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l.paymentTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (due != null) ...[
              _DuePaymentCard(
                payment: due,
                selectedMethod: _selectedMethod,
                zainCashAccount: app.paymentAccounts?.zainCash ??
                    l.paymentZainCashAccount,
                superQiAccount: app.paymentAccounts?.superQi ??
                    l.paymentSuperQiAccount,
                zainCashQrUrl: app.paymentAccounts?.zainCashQrUrl,
                superQiQrUrl: app.paymentAccounts?.superQiQrUrl,
                onMethodChanged: (m) => setState(() => _selectedMethod = m),
                onPay: () => _showPayProofSheet(context, app, due),
              ),
              const SizedBox(height: 24),
              // Transfer instructions only make sense when there's a due payment.
              _PaymentInstructionsCard(method: _selectedMethod),
              const SizedBox(height: 24),
            ] else ...[
              _AllPaidBanner(),
              const SizedBox(height: 24),
            ],

            Text(l.paymentHistoryTitle,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (app.loadingPayments)
              const Center(child: CircularProgressIndicator())
            else
              ...history.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PaymentHistoryTile(payment: p),
                  )),
          ],
        ),
      ),
      ),
    );
  }

}

// ── Due Payment Card ──────────────────────────────────────────────────────────

class _DuePaymentCard extends StatelessWidget {
  final PaymentRecord payment;
  final PaymentMethod selectedMethod;
  final String zainCashAccount;
  final String superQiAccount;
  final String? zainCashQrUrl;
  final String? superQiQrUrl;
  final void Function(PaymentMethod) onMethodChanged;
  final VoidCallback onPay;

  const _DuePaymentCard({
    required this.payment,
    required this.selectedMethod,
    required this.zainCashAccount,
    required this.superQiAccount,
    required this.zainCashQrUrl,
    required this.superQiQrUrl,
    required this.onMethodChanged,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(l.paymentDueLabel,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(l.statusUnpaid,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(Helpers.formatCurrency(payment.amountIQD),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700)),
                Text(payment.month,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                    l.paymentDueDateLabel(
                        Helpers.formatDate(payment.dueDate)),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.paymentMethodTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),

                // ZainCash
                _MethodTile(
                  method: PaymentMethod.zaincash,
                  selected: selectedMethod == PaymentMethod.zaincash,
                  onTap: () => onMethodChanged(PaymentMethod.zaincash),
                  icon: Icons.phone_android,
                  label: l.paymentZainCash,
                  subtitle: l.paymentZainCashDesc,
                  accountNumber: zainCashAccount,
                  qrUrl: zainCashQrUrl,
                ),
                const SizedBox(height: 8),

                // Super QI
                _MethodTile(
                  method: PaymentMethod.superQi,
                  selected: selectedMethod == PaymentMethod.superQi,
                  onTap: () => onMethodChanged(PaymentMethod.superQi),
                  icon: Icons.account_balance_wallet_outlined,
                  label: l.paymentSuperQi,
                  subtitle: l.paymentSuperQiDesc,
                  accountNumber: superQiAccount,
                  qrUrl: superQiQrUrl,
                ),
                const SizedBox(height: 8),

                // Other
                _MethodTile(
                  method: PaymentMethod.other,
                  selected: selectedMethod == PaymentMethod.other,
                  onTap: () => onMethodChanged(PaymentMethod.other),
                  icon: Icons.more_horiz_outlined,
                  label: l.paymentOther,
                  subtitle: l.paymentOtherDesc,
                  accountNumber: null,
                  qrUrl: null,
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(l.paymentIvePaid(
                      Helpers.formatCurrency(payment.amountIQD))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Method Tile ───────────────────────────────────────────────────────────────

class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final String subtitle;
  final String? accountNumber;
  final String? qrUrl;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accountNumber,
    required this.qrUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? AppColors.primary : AppColors.border,
                  size: 22,
                ),
              ],
            ),
            // When the method is selected: prefer a QR uploaded by the admin
            // (so each Uruk install can show its own scan-to-pay barcode);
            // otherwise show the account number inline.
            if (selected && qrUrl != null && qrUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: qrUrl!,
                  fit: BoxFit.contain,
                  height: 260,
                  width: double.infinity,
                  placeholder: (_, __) => const SizedBox(
                    height: 260,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const SizedBox(
                    height: 260,
                    child: Center(
                      child: Icon(Icons.broken_image,
                          size: 48, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              if (accountNumber != null && accountNumber!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '$accountNumber',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ] else if (selected && accountNumber != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.content_copy_outlined,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.paymentAccountNumberLabel,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                          Text(
                            accountNumber!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Instructions Card ─────────────────────────────────────────────────────────

class _PaymentInstructionsCard extends StatelessWidget {
  final PaymentMethod method;
  const _PaymentInstructionsCard({required this.method});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final accounts = context.watch<AppProvider>().paymentAccounts;

    // If admin uploaded a QR code for this method, show QR image instead of steps.
    final qrUrl = switch (method) {
      PaymentMethod.zaincash => accounts?.zainCashQrUrl,
      PaymentMethod.superQi => accounts?.superQiQrUrl,
      PaymentMethod.other => null,
    };
    final hasQr = qrUrl != null && qrUrl.isNotEmpty;

    final title = switch (method) {
      PaymentMethod.zaincash => l.paymentZainCashInstructionsTitle,
      PaymentMethod.superQi => l.paymentSuperQiInstructionsTitle,
      PaymentMethod.other => l.paymentOtherInstructionsTitle,
    };

    final steps = switch (method) {
      PaymentMethod.zaincash => [
          l.paymentZainCashStep1,
          l.paymentZainCashStep2,
          l.paymentZainCashStep3,
          l.paymentZainCashStep4,
        ],
      PaymentMethod.superQi => [
          l.paymentSuperQiStep1,
          l.paymentSuperQiStep2,
          l.paymentSuperQiStep3,
          l.paymentSuperQiStep4,
        ],
      PaymentMethod.other => [
          l.paymentOtherStep1,
          l.paymentOtherStep2,
          l.paymentOtherStep3,
          l.paymentOtherStep4,
        ],
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.info_outline,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          if (hasQr) ...[
            // QR mode: show the admin-uploaded barcode instead of the
            // text steps. The customer scans it from their wallet app.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260, maxHeight: 260),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: qrUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 48, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            ...steps.asMap().entries.map((e) =>
                _InstructionStep(step: '${e.key + 1}', text: e.value)),
            const SizedBox(height: 8),
          ],
          Text(
            l.paymentVerificationNote,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String step;
  final String text;
  const _InstructionStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: Center(
                child: Text(step,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.4))),
        ],
      ),
    );
  }
}

// ── All Paid Banner ───────────────────────────────────────────────────────────

class _AllPaidBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.paymentAllPaid,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.success)),
                Text(l.paymentNoPending,
                    style: const TextStyle(
                        color: AppColors.success, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment History Tile ──────────────────────────────────────────────────────

class _PaymentHistoryTile extends StatelessWidget {
  final PaymentRecord payment;
  const _PaymentHistoryTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: payment.status == PaymentStatus.paid
                  ? AppColors.successLight
                  : AppColors.errorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              payment.status == PaymentStatus.paid
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              color: payment.status == PaymentStatus.paid
                  ? AppColors.success
                  : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.month,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppColors.textPrimary)),
                if (payment.paidDate != null)
                  Text(
                      l.paymentPaidOn(
                          Helpers.formatDate(payment.paidDate!)),
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Helpers.formatCurrency(payment.amountIQD),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              StatusBadge.paymentStatus(payment.status),
            ],
          ),
        ],
      ),
    );
  }
}
