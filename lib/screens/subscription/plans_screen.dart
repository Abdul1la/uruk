import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/platform_image.dart';
import '../../models/subscription_model.dart';
import '../../models/upgrade_request_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/upload_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/back_button_handler.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  String? _selectedPlanId;
  int _selectedMonths = 1;

  static const _periods = [1, 3, 6, 12];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null && user.subscription != SubscriptionType.none) {
      _selectedPlanId = user.subscription.name;
      _selectedMonths = user.car?.paymentMonths ?? 1;
    }
  }

  SubscriptionPlan? get _selectedPlan =>
      _selectedPlanId == null
          ? null
          : SubscriptionPlan.plans.where((p) => p.id == _selectedPlanId).firstOrNull;

  RepairTier? get _selectedTier =>
      _selectedPlan?.repairTiers
          .where((t) => t.months == _selectedMonths)
          .firstOrNull;

  int get _totalPrice => (_selectedPlan?.priceIQD ?? 0) * _selectedMonths;

  // ── Upgrade logic ─────────────────────────────────────────────────────────

  CarInfo? get _activeCar {
    final appCar = context.read<AppProvider>().selectedCar;
    if (appCar != null) return appCar;
    return context.read<AuthProvider>().user?.car;
  }

  String _planName(SubscriptionType type, AppLocalizations l) {
    switch (type) {
      case SubscriptionType.standard: return l.statusStandard;
      case SubscriptionType.shared:   return l.statusShared;
      case SubscriptionType.vip:      return l.statusVip;
      default:                        return type.name.toUpperCase();
    }
  }

  String _periodLabel(int months, AppLocalizations l) {
    switch (months) {
      case 3:  return l.subscriptionPeriod3Months;
      case 6:  return l.subscriptionPeriod6Months;
      case 12: return l.subscriptionPeriod12Months;
      default: return l.subscriptionPeriodMonthly;
    }
  }

  bool get _hasActiveSub {
    final car = _activeCar;
    return car != null &&
        car.subscription != SubscriptionType.none &&
        car.subscriptionExpiry != null &&
        car.subscriptionExpiry!.isAfter(DateTime.now());
  }

  int _planTier(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.standard: return 1;
      case SubscriptionType.shared:   return 2;
      case SubscriptionType.vip:      return 3;
      default:                        return 0;
    }
  }

  bool get _isSamePlan =>
      _hasActiveSub &&
      _selectedPlan != null &&
      _selectedPlan!.type == _activeCar!.subscription;

  bool get _isUpgrade =>
      _hasActiveSub &&
      _selectedPlan != null &&
      _planTier(_selectedPlan!.type) > _planTier(_activeCar!.subscription);

  bool get _isDowngrade =>
      _hasActiveSub &&
      _selectedPlan != null &&
      _planTier(_selectedPlan!.type) < _planTier(_activeCar!.subscription);

  /// Months remaining on the current subscription (rounded up).
  int get _remainingMonths {
    final expiry = _activeCar?.subscriptionExpiry;
    if (expiry == null || !expiry.isAfter(DateTime.now())) return 0;
    return (expiry.difference(DateTime.now()).inDays / 30).ceil();
  }

  int get _currentPlanPrice {
    final car = _activeCar;
    if (car == null) return 0;
    return SubscriptionPlan.plans
        .firstWhere((p) => p.type == car.subscription,
            orElse: () => SubscriptionPlan.plans.first)
        .priceIQD;
  }

  /// Credit = remaining months × current monthly price
  int get _remainingCredit => _remainingMonths * _currentPlanPrice;

  /// How much the user actually owes after applying their credit
  int get _amountDue => max(0, _totalPrice - _remainingCredit);

  // ── Action handlers ───────────────────────────────────────────────────────

  void _onAction() {
    if (_isUpgrade)   _showUpgradeDialog();
    else if (_isSamePlan) _showRenewDialog();
    else if (_isDowngrade) _showDowngradeInfo();
    else _showSubscribeDialog();       // no existing sub
  }

  /// Called when the user taps a plan card. Selects the plan, then opens a
  /// months-picker dialog so the user can pick their payment period and move
  /// straight into the payment flow — one tap away from paying.
  Future<void> _handlePlanTap(SubscriptionPlan plan) async {
    setState(() {
      _selectedPlanId = plan.id;
      // If the user had a different previous selection, reset to a sensible
      // default (1 month) unless the existing selection is still valid.
      if (!_periods.contains(_selectedMonths)) {
        _selectedMonths = 1;
      }
    });
    // Downgrade path short-circuits to the info dialog — no point asking for
    // months if the user can't actually switch to this plan.
    if (_isDowngrade) {
      _showDowngradeInfo();
      return;
    }
    await _showMonthsPicker(plan);
  }

  /// Months selection dialog — pops right after tapping a plan card. Shows
  /// every payment period with its repair count and total price so the user
  /// sees exactly what they'll get before continuing to the payment screen.
  Future<void> _showMonthsPicker(SubscriptionPlan plan) async {
    final l = context.l10n;
    int tempMonths = _selectedMonths;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          titlePadding:
              const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 8),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_planName(plan.type, l),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary)),
              const SizedBox(height: 4),
              const Text('اختر مدة الدفع',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _periods.map((months) {
                final repairs = SubscriptionPlan.repairsForPeriod(
                    plan.type, months);
                final price = plan.priceIQD * months;
                final isSelected = tempMonths == months;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () =>
                        setDialogState(() => tempMonths = months),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Radio indicator
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          // Period label + repairs
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _periodLabel(months, l),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l.subscriptionRepairsPerMonth(repairs),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          // Price
                          Text(
                            _formatIQD(price),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actionsPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(l.commonCancel),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogCtx, true),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('متابعة الدفع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _selectedMonths = tempMonths);
    // Jump straight into the appropriate flow so the user doesn't need to
    // scroll down and hit a second button.
    _onAction();
  }

  // ── New subscribe (no existing sub) ──────────────────────────────────────

  void _showSubscribeDialog() {
    final l = context.l10n;
    final plan = _selectedPlan!;
    final tier = _selectedTier;
    final repairs = tier?.repairsPerMonth ?? plan.repairTiers.first.repairsPerMonth;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l.subscriptionConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConfirmRow(label: l.subscriptionPlanLabel, value: _planName(plan.type, l)),
            _ConfirmRow(label: l.subscriptionPaymentMethodLabel, value: _periodLabel(_selectedMonths, l)),
            _ConfirmRow(label: l.subscriptionRepairsLabel, value: l.subscriptionRepairsPerMonth(repairs)),
            _ConfirmRow(label: l.subscriptionTotalLabel, value: _formatIQD(_totalPrice), highlight: true),
            const SizedBox(height: 10),
            Text(l.subscriptionConfirmNote,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applySubscription(plan, repairs);
            },
            child: Text(l.commonConfirm),
          ),
        ],
      ),
    );
  }

  // ── Upgrade dialog (with proration) ──────────────────────────────────────

  void _showUpgradeDialog() {
    final l = context.l10n;
    final car = _activeCar!;
    final newPlan = _selectedPlan!;
    final tier = _selectedTier;
    final repairs = tier?.repairsPerMonth ?? newPlan.repairTiers.first.repairsPerMonth;

    final currentPlanName = switch (car.subscription) {
      SubscriptionType.standard => l.statusStandard,
      SubscriptionType.shared   => l.statusShared,
      SubscriptionType.vip      => l.statusVip,
      _                         => '',
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l.upgradeTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Current plan credit breakdown ─────────────────────────
              _SectionHeader(l.upgradeCurrentPlanSection),
              _ConfirmRow(label: l.subscriptionPlanLabel, value: currentPlanName),
              _ConfirmRow(
                label: l.upgradeRemainingMonths(_remainingMonths),
                value: '${_remainingMonths}×${_formatIQD(_currentPlanPrice)}',
              ),
              _ConfirmRow(
                label: l.upgradeCreditLabel,
                value: _formatIQD(_remainingCredit),
                color: AppColors.success,
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),

              // ── New plan cost breakdown ───────────────────────────────
              _SectionHeader(l.upgradeNewPlanSection),
              _ConfirmRow(label: l.subscriptionPlanLabel, value: _planName(newPlan.type, l)),
              _ConfirmRow(
                label: l.subscriptionPaymentMethodLabel,
                value: _periodLabel(_selectedMonths, l),
              ),
              _ConfirmRow(
                label: l.subscriptionRepairsLabel,
                value: l.subscriptionRepairsPerMonth(repairs),
              ),
              _ConfirmRow(
                label: l.upgradeNewCostLabel,
                value: _formatIQD(_totalPrice),
              ),

              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _amountDue == 0
                      ? AppColors.successLight
                      : AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _amountDue == 0
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.upgradeAmountDueLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text(
                      _amountDue == 0
                          ? l.upgradeAmountFree
                          : _formatIQD(_amountDue),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: _amountDue == 0 ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.upgradeNote,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.5)),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // If money is due, require a payment proof image. If the
              // upgrade is covered entirely by remaining credit, skip it.
              String? proofUrl;
              if (_amountDue > 0) {
                proofUrl = await _pickUpgradeProof();
                if (proofUrl == null) return; // user cancelled
              }
              await _submitUpgrade(newPlan, repairs, currentPlanName, proofUrl);
            },
            child: Text(l.upgradeSubmitButton),
          ),
        ],
      ),
    );
  }

  /// Shows a bottom sheet that asks the user to pick a payment-proof image,
  /// uploads it, and returns the remote URL (or null if cancelled / failed).
  Future<String?> _pickUpgradeProof() async {
    XFile? picked;
    final picker = ImagePicker();
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إيصال الدفع',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'ارفع صورة إيصال التحويل ليتمكن فريق المالية من التحقق من دفعتك وتفعيل الترقية',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final result = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (result != null) setSheetState(() => picked = result);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: picked != null ? 180 : 90,
                  decoration: BoxDecoration(
                    color: picked != null ? AppColors.primarySurface : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: picked != null ? AppColors.primary : AppColors.divider,
                      width: picked != null ? 2 : 1,
                    ),
                  ),
                  child: picked != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: PlatformImage(picked!,
                              width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 30, color: AppColors.primary),
                            SizedBox(height: 6),
                            Text('اختر صورة الإيصال',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: picked == null
                    ? null
                    : () async {
                        try {
                          final url = await UploadService().upload(
                            picked!,
                            folder: 'payments',
                          );
                          if (sheetCtx.mounted) Navigator.pop(sheetCtx, url);
                        } catch (_) {
                          if (sheetCtx.mounted) {
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              const SnackBar(
                                content: Text('فشل رفع الصورة، حاول مرة أخرى'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('تأكيد الإرسال'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(sheetCtx, null),
                child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitUpgrade(
    SubscriptionPlan newPlan,
    int repairs,
    String currentPlanName,
    String? proofImageUrl,
  ) async {
    final l = context.l10n;
    final user = context.read<AuthProvider>().user!;
    final car = _activeCar!;

    await context.read<AppProvider>().submitUpgradeRequest(
      userId: user.id,
      carId: car.id,
      currentPlan: car.subscription,
      currentPlanPriceIQD: _currentPlanPrice,
      remainingMonths: _remainingMonths,
      creditIQD: _remainingCredit,
      requestedPlan: newPlan.type,
      requestedPlanPriceIQD: newPlan.priceIQD,
      requestedMonths: _selectedMonths,
      newCostIQD: _totalPrice,
      amountDueIQD: _amountDue,
      proofImageUrl: proofImageUrl,
    );

    if (!mounted) return;

    final newPlanName = _planName(newPlan.type, l);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 22),
            const SizedBox(width: 10),
            Text(l.upgradeSentTitle),
          ],
        ),
        content: Text(
          l.upgradeSentContent(currentPlanName, newPlanName),
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/home');
            },
            child: Text(l.commonOk),
          ),
        ],
      ),
    );
  }

  // ── Renew same plan ───────────────────────────────────────────────────────

  void _showRenewDialog() {
    final l = context.l10n;
    final plan = _selectedPlan!;
    final tier = _selectedTier;
    final repairs = tier?.repairsPerMonth ?? plan.repairTiers.first.repairsPerMonth;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l.upgradeRenewButton),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConfirmRow(label: l.subscriptionPlanLabel, value: _planName(plan.type, l)),
            _ConfirmRow(label: l.subscriptionPaymentMethodLabel, value: _periodLabel(_selectedMonths, l)),
            _ConfirmRow(label: l.subscriptionRepairsLabel, value: l.subscriptionRepairsPerMonth(repairs)),
            _ConfirmRow(label: l.subscriptionTotalLabel, value: _formatIQD(_totalPrice), highlight: true),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l.upgradeRenewNote,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applySubscription(plan, repairs);
            },
            child: Text(l.commonConfirm),
          ),
        ],
      ),
    );
  }

  // ── Downgrade info ────────────────────────────────────────────────────────

  void _showDowngradeInfo() {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.warning, size: 22),
            const SizedBox(width: 10),
            Text(l.upgradeTitle),
          ],
        ),
        content: Text(l.upgradeDowngradeNote,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.commonOk),
          ),
        ],
      ),
    );
  }

  // ── Apply subscription (new / renew) — shows payment proof flow ──────────

  void _applySubscription(SubscriptionPlan plan, int repairs) {
    final car = _activeCar;
    if (car == null) return;
    _showPaymentProofFlow(plan, repairs, car);
  }

  void _showPaymentProofFlow(SubscriptionPlan plan, int repairs, CarInfo car) {
    final l = context.l10n;
    final app = context.read<AppProvider>();
    final accounts = app.paymentAccounts;
    final zainCash = accounts?.zainCash ?? l.paymentZainCashAccount;
    final superQi = accounts?.superQi ?? '';
    final zainQr = accounts?.zainCashQrUrl;
    final superQr = accounts?.superQiQrUrl;
    // Refresh from server in case admin changed payment accounts since login.
    app.loadPaymentAccounts();

    XFile? proofImage;
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l.subscriptionPayTitle,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(l.subscriptionPayDesc,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 16),

                // Amount
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(_formatIQD(_totalPrice),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('${_planName(plan.type, l)} · ${_periodLabel(_selectedMonths, l)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment accounts
                Text(l.subscriptionPayAccountsTitle,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (zainQr != null && zainQr.isNotEmpty) ...[
                  _ZainCashQrTile(qrUrl: zainQr, accountNumber: zainCash),
                ] else
                  _AccountTile(label: 'ZainCash', number: zainCash, icon: Icons.phone_android),
                const SizedBox(height: 6),
                _SuperQiQrTile(qrUrl: superQr, accountNumber: superQi),
                const SizedBox(height: 16),

                // Payment proof upload
                Text(l.paymentProofUploadLabel,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
                    if (picked != null) setSheetState(() => proofImage = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    height: proofImage != null ? 160 : 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: proofImage != null ? AppColors.primary : AppColors.divider,
                        width: proofImage != null ? 2 : 1,
                      ),
                    ),
                    child: proofImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: PlatformImage(proofImage!,
                                    width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                              ),
                              Positioned(
                                bottom: 8, right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit_outlined, color: Colors.white, size: 13),
                                      const SizedBox(width: 4),
                                      Text(l.paymentProofChangeLabel,
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file_outlined, color: AppColors.primary, size: 28),
                              const SizedBox(height: 6),
                              Text(l.paymentProofUploadLabel,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l.subscriptionPayNote,
                            style: const TextStyle(fontSize: 11, color: AppColors.warning, height: 1.4)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm button — submits a request, does NOT activate instantly
                ElevatedButton(
                  onPressed: () async {
                    // Require a payment proof so finance has something to review.
                    if (proofImage == null) {
                      ScaffoldMessenger.of(sheetCtx).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى رفع صورة إيصال الدفع أولاً'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(sheetCtx);
                    try {
                      // Upload the receipt first; the backend stores the URL
                      // on the upgrade request so the admin panel can display it.
                      final proofUrl = await UploadService().upload(
                        proofImage!,
                        folder: 'payments',
                      );
                      await context.read<AppProvider>().submitUpgradeRequest(
                        userId: context.read<AuthProvider>().user!.id,
                        carId: car.id,
                        currentPlan: car.subscription,
                        currentPlanPriceIQD: 0,
                        remainingMonths: 0,
                        creditIQD: 0,
                        requestedPlan: plan.type,
                        requestedPlanPriceIQD: plan.priceIQD,
                        requestedMonths: _selectedMonths,
                        newCostIQD: _totalPrice,
                        amountDueIQD: _totalPrice,
                        proofImageUrl: proofUrl,
                      );
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.commonErrorGeneric),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.subscriptionPaySuccess)),
                    );
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(l.subscriptionPayConfirmButton),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                  child: Text(l.commonCancel, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatIQD(int amount) {
    if (amount == 0) return '—';
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} د.ع';
  }

  // ── Bottom bar label ──────────────────────────────────────────────────────

  String _actionButtonLabel(AppLocalizations l) {
    if (_selectedPlanId == null) return l.subscriptionSelectPlan;
    if (_isUpgrade)   return l.upgradeSubmitButton;
    if (_isSamePlan)  return l.upgradeRenewButton;
    if (_isDowngrade) return l.subscriptionSelectPlan; // disabled effectively
    return l.subscriptionSubscribeButton;
  }

  bool get _actionEnabled => _selectedPlanId != null && !_isDowngrade;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = context.watch<AuthProvider>().user;
    final app = context.watch<AppProvider>();
    final plans = SubscriptionPlan.plans;
    final pendingUpgrade = app.pendingUpgradeRequest;
    final rejectedUpgrade = app.mostRecentRejectedUpgradeRequest;

    return BackButtonHandler(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_hasActiveSub ? l.upgradeTitle : l.subscriptionTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
        body: Column(
          children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Subscription request status card ─────────────────────
                  if (pendingUpgrade != null) ...[
                    _UpgradeStatusCard(
                      request: pendingUpgrade,
                      planName: _planName(pendingUpgrade.requestedPlan, l),
                    ),
                    const SizedBox(height: 14),
                  ] else if (rejectedUpgrade != null) ...[
                    _UpgradeStatusCard(
                      request: rejectedUpgrade,
                      planName: _planName(rejectedUpgrade.requestedPlan, l),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Downgrade hint ─────────────────────────���──────────────
                  if (_isDowngrade) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(l.upgradeDowngradeNote,
                                style: const TextStyle(fontSize: 12, color: AppColors.warning, height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Text(
                    l.subscriptionSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 14),

                  // ── Available cities banner ──────────────────────────────
                  if (app.availableCities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: AppColors.info, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  l.availableCitiesTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: app.availableCities.map((city) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.info.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_city, color: AppColors.info, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      city,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Plan cards ────────────────────────────────────────────
                  ...plans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PlanCard(
                          plan: plan,
                          isSelected: _selectedPlanId == plan.id,
                          isCurrent: user?.subscription.name == plan.id && _hasActiveSub,
                          selectedMonths: _selectedMonths,
                          onTap: () => _handlePlanTap(plan),
                        ),
                      )),

                  const SizedBox(height: 6),

                  // ── Payment period selector ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_repeat_outlined, color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(l.subscriptionPaymentPeriodTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(l.subscriptionPaymentPeriodHint,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 14),
                        ...List.generate(_periods.length, (i) {
                          final months = _periods[i];
                          final repairs = _selectedPlan == null
                              ? null
                              : SubscriptionPlan.repairsForPeriod(_selectedPlan!.type, months);
                          final isSelected = _selectedMonths == months;
                          final price = (_selectedPlan?.priceIQD ?? 0) * months;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedMonths = months),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: EdgeInsets.only(bottom: i < _periods.length - 1 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.06)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18, height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 8, height: 8,
                                              decoration: const BoxDecoration(
                                                  color: AppColors.primary, shape: BoxShape.circle),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _periodLabel(months, l),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (repairs != null)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l.subscriptionRepairsPerMonth(repairs),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  if (price > 0) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatIQD(price),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Proration preview (upgrade only) ──────────────────────
                  if (_isUpgrade && _selectedPlan != null) ...[
                    _UpgradeProrationCard(
                      remainingMonths: _remainingMonths,
                      currentPlanPrice: _currentPlanPrice,
                      remainingCredit: _remainingCredit,
                      newCost: _totalPrice,
                      amountDue: _amountDue,
                    ),
                    const SizedBox(height: 16),
                  ],

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(l.subscriptionDisclaimer,
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Bottom bar ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedPlan != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_planName(_selectedPlan!.type, l)} · ${_periodLabel(_selectedMonths, l)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      // For upgrade: show amount due (not full cost)
                      Text(
                        _isUpgrade
                            ? _formatIQD(_amountDue)
                            : _formatIQD(_totalPrice),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (_isUpgrade && _remainingCredit > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.remove_circle_outline, size: 12, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          '${l.upgradeCreditLabel}: ${_formatIQD(_remainingCredit)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  if (_selectedTier != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.build_outlined, size: 12, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          l.subscriptionRepairsPerMonth(_selectedTier!.repairsPerMonth),
                          style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
                AppButton(
                  label: _actionButtonLabel(l),
                  onPressed: _actionEnabled ? _onAction : null,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ── Subscription request status card ─────────────────────────────────────────
// Shows the lifecycle of the user's most recent subscription request so they
// can see where their payment stands without needing to contact support.

class _UpgradeStatusCard extends StatelessWidget {
  final UpgradeRequest request;
  final String planName;

  const _UpgradeStatusCard({
    required this.request,
    required this.planName,
  });

  String _fmtIQD(int n) {
    if (n == 0) return '—';
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} د.ع';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isPending = request.isPending;
    final isRejected = request.isRejected;
    final accent = isRejected ? AppColors.error : AppColors.warning;
    final accentLight = isRejected ? AppColors.errorLight : AppColors.warningLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isRejected ? Icons.cancel_outlined : Icons.pending_actions,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.upgradeStatusCardTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.upgradeStatusSubmittedAt(
                        Helpers.formatDate(request.submittedAt),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: isRejected
                    ? l.upgradeStatusRejectedLabel
                    : l.upgradeStatusStepReview,
                color: accent,
                background: accentLight,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Step indicator: Submitted → Under review → Decision
          _StatusSteps(isPending: isPending, isRejected: isRejected),
          const SizedBox(height: 14),

          // Request details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: l.upgradeStatusRequestedPlanLabel,
                  value: planName,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: l.upgradeStatusAmountLabel,
                  value: _fmtIQD(request.amountDueIQD),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            isRejected
                ? l.upgradeStatusRejectedDesc
                : l.upgradeStatusPendingDesc,
            style: TextStyle(
              fontSize: 12,
              color: accent,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Admin note (when present, typically for rejected requests)
          if (request.adminNote != null && request.adminNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.upgradeStatusAdminNote,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.adminNote!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StatusSteps extends StatelessWidget {
  final bool isPending;
  final bool isRejected;

  const _StatusSteps({required this.isPending, required this.isRejected});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    // Step states:
    //   submitted  → always complete (request exists)
    //   review     → active while pending, complete once a decision exists
    //   decision   → active when rejected (final state); idle when pending
    final submittedState = _StepState.complete;
    final reviewState =
        isPending ? _StepState.active : _StepState.complete;
    final decisionState = isRejected
        ? _StepState.rejected
        : (isPending ? _StepState.idle : _StepState.complete);

    return Row(
      children: [
        _Step(
          label: l.upgradeStatusStepSubmitted,
          state: submittedState,
        ),
        _StepConnector(active: reviewState != _StepState.idle),
        _Step(
          label: l.upgradeStatusStepReview,
          state: reviewState,
        ),
        _StepConnector(active: decisionState != _StepState.idle),
        _Step(
          label: l.upgradeStatusStepDecision,
          state: decisionState,
        ),
      ],
    );
  }
}

enum _StepState { idle, active, complete, rejected }

class _Step extends StatelessWidget {
  final String label;
  final _StepState state;

  const _Step({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData? icon;
    switch (state) {
      case _StepState.complete:
        color = AppColors.success;
        icon = Icons.check;
        break;
      case _StepState.active:
        color = AppColors.warning;
        icon = null;
        break;
      case _StepState.rejected:
        color = AppColors.error;
        icon = Icons.close;
        break;
      case _StepState.idle:
        color = AppColors.border;
        icon = null;
        break;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: state == _StepState.idle ? AppColors.surface : color,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: icon != null
                ? Icon(icon, size: 14, color: Colors.white)
                : (state == _StepState.active
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: state == _StepState.idle
                  ? AppColors.textHint
                  : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool active;
  const _StepConnector({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: active ? AppColors.success : AppColors.border,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Proration Preview Card ─────────────────────────────────────────────────────

class _UpgradeProrationCard extends StatelessWidget {
  final int remainingMonths;
  final int currentPlanPrice;
  final int remainingCredit;
  final int newCost;
  final int amountDue;

  const _UpgradeProrationCard({
    required this.remainingMonths,
    required this.currentPlanPrice,
    required this.remainingCredit,
    required this.newCost,
    required this.amountDue,
  });

  String _fmt(int n) {
    if (n == 0) return '—';
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} د.ع';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(l.upgradeAmountDueLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),

          // Equation display: NewCost − Credit = Due
          Row(
            children: [
              _CalcBox(label: l.upgradeNewCostLabel, value: _fmt(newCost), color: AppColors.textPrimary),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('−', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ),
              _CalcBox(label: l.upgradeCreditLabel, value: _fmt(remainingCredit), color: AppColors.success),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('=', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ),
              _CalcBox(
                label: l.upgradeAmountDueLabel,
                value: amountDue == 0 ? l.upgradeAmountFree : _fmt(amountDue),
                color: amountDue == 0 ? AppColors.success : AppColors.primary,
                highlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalcBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool highlight;
  const _CalcBox({required this.label, required this.value, required this.color, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: highlight ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(8),
          border: highlight ? Border.all(color: color.withValues(alpha: 0.3)) : null,
        ),
        child: Column(
          children: [
            Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5)),
    );
  }
}

// ── Confirm Row ────────────────────────────────────────────────────────────────

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? color;
  const _ConfirmRow({required this.label, required this.value, this.highlight = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: color ?? (highlight ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan Card ──────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final bool isCurrent;
  final int selectedMonths;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.isCurrent,
    required this.selectedMonths,
    required this.onTap,
  });

  Color get _accent {
    switch (plan.type) {
      case SubscriptionType.standard: return AppColors.primary;
      case SubscriptionType.shared:   return const Color(0xFF7C3AED);
      case SubscriptionType.vip:      return const Color(0xFFB45309);
      default:                        return AppColors.primary;
    }
  }

  Color get _accentLight {
    switch (plan.type) {
      case SubscriptionType.standard: return const Color(0xFFEFF6FF);
      case SubscriptionType.shared:   return const Color(0xFFF5F3FF);
      case SubscriptionType.vip:      return const Color(0xFFFFFBEB);
      default:                        return const Color(0xFFEFF6FF);
    }
  }

  IconData get _icon {
    switch (plan.type) {
      case SubscriptionType.standard: return Icons.shield_outlined;
      case SubscriptionType.shared:   return Icons.people_outline;
      case SubscriptionType.vip:      return Icons.workspace_premium_outlined;
      default:                        return Icons.shield_outlined;
    }
  }

  String _formatIQD(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} د.ع';
  }

  String _planName(AppLocalizations l) {
    switch (plan.type) {
      case SubscriptionType.standard: return l.statusStandard;
      case SubscriptionType.shared:   return l.statusShared;
      case SubscriptionType.vip:      return l.statusVip;
      default:                        return plan.type.name.toUpperCase();
    }
  }

  String _tierLabel(int months, AppLocalizations l) {
    switch (months) {
      case 3:  return l.subscriptionPeriod3Months;
      case 6:  return l.subscriptionPeriod6Months;
      case 12: return l.subscriptionPeriod12Months;
      default: return l.subscriptionPeriodMonthly;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final highlightedTier = plan.repairTiers
        .where((t) => t.months == selectedMonths)
        .firstOrNull;

    // When this is the user's current plan, override selection styling with a
    // green success outline so it's obvious they're already subscribed — and
    // stack a ribbon banner on top of the card.
    final Color borderColor;
    final double borderWidth;
    final List<BoxShadow>? boxShadow;
    if (isCurrent) {
      borderColor = AppColors.success;
      borderWidth = 2;
      boxShadow = [
        BoxShadow(
          color: AppColors.success.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];
    } else if (isSelected) {
      borderColor = _accent;
      borderWidth = 2;
      boxShadow = [
        BoxShadow(color: _accent.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 6)),
      ];
    } else {
      borderColor = AppColors.divider;
      borderWidth = 1;
      boxShadow = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: boxShadow,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _accentLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon, color: _accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_planName(l),
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _accent)),
                        const SizedBox(height: 2),
                        Text(plan.coverageNote,
                            style: TextStyle(fontSize: 11, color: _accent.withValues(alpha: 0.8), height: 1.3)),
                        if (plan.isPopular) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(20)),
                            child: Text(l.subscriptionMostPopular,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatIQD(plan.priceIQD),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _accent)),
                      Text(l.subscriptionPerMonth,
                          style: TextStyle(fontSize: 12, color: _accent.withValues(alpha: 0.7))),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: "الخدمة تشمل التصليحات التالية :"
                  Text(
                    'الخدمة تشمل التصليحات التالية :',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...plan.coveredParts.map((part) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: _accent, size: 14),
                            const SizedBox(width: 8),
                            Text(part, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                          ],
                        ),
                      )),

                  const SizedBox(height: 12),
                  Divider(color: _accent.withValues(alpha: 0.15)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: _accent, size: 13),
                      const SizedBox(width: 6),
                      Text(l.subscriptionRepairsByPeriod,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _accent)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...plan.repairTiers.map((tier) {
                    final isHighlighted =
                        highlightedTier != null && tier.months == highlightedTier.months;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(_tierLabel(tier.months, l),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: isHighlighted
                                  ? _accent.withValues(alpha: 0.12)
                                  : _accent.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: isHighlighted
                                  ? Border.all(color: _accent.withValues(alpha: 0.4))
                                  : null,
                            ),
                            child: Text(
                              l.subscriptionRepairsPerMonth(tier.repairsPerMonth),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isHighlighted ? _accent : _accent.withValues(alpha: 0.6)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (isCurrent) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 13),
                          const SizedBox(width: 5),
                          Text(l.subscriptionCurrentPlan,
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      // Prominent ribbon in the top-start corner so the user's current plan
      // is unmistakable at a glance, even before they read the card body.
      if (isCurrent)
        Positioned(
          top: -10,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 13),
                const SizedBox(width: 5),
                Text(
                  l.subscriptionCurrentPlanBanner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  ),
);
  }
}

// ── Account Tile (shows payment account number) ──────────────────────────────

class _SuperQiQrTile extends StatelessWidget {
  /// Admin-uploaded Super QI QR url (from app_config.payment_accounts).
  /// When null/empty, falls back to displaying just the account number rather
  /// than a stale bundled image, since each Uruk install has its own QR.
  final String? qrUrl;
  final String? accountNumber;
  const _SuperQiQrTile({this.qrUrl, this.accountNumber});

  @override
  Widget build(BuildContext context) {
    final hasQr = qrUrl != null && qrUrl!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: hasQr
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: qrUrl!,
                fit: BoxFit.contain,
                height: 260,
                placeholder: (_, __) => const SizedBox(
                  height: 260,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => SizedBox(
                  height: 80,
                  child: Center(
                    child: Text(
                      accountNumber ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Super QI',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        Text(accountNumber ?? '',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ZainCashQrTile extends StatelessWidget {
  final String qrUrl;
  final String accountNumber;
  const _ZainCashQrTile({required this.qrUrl, required this.accountNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: qrUrl,
              fit: BoxFit.contain,
              height: 240,
              placeholder: (_, __) => const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => const SizedBox(
                height: 60,
                child: Center(
                  child: Icon(Icons.broken_image, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('ZainCash · $accountNumber',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 1,
              )),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String label;
  final String number;
  final IconData icon;
  const _AccountTile({required this.label, required this.number, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                Text(number, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
