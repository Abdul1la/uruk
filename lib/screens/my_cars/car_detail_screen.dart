import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/subscription_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/back_button_handler.dart';
import '../../widgets/common/status_badge.dart';

class CarDetailScreen extends StatelessWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l = context.l10n;
    final user = auth.user;
    final car = user?.cars.where((c) => c.id == carId).firstOrNull;

    if (car == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Icon(Icons.error_outline, size: 48, color: AppColors.textHint)),
      );
    }

    final hasSub = car.subscription != SubscriptionType.none;

    return BackButtonHandler(
      fallbackRoute: '/my-cars',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l.carDetailTitle),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Car icon + name header
              _CarHeaderCard(car: car),
              const SizedBox(height: 16),

              // Car info section
              _CarInfoSection(car: car),
              const SizedBox(height: 16),

              // Subscription section
              if (hasSub)
                _ActiveSubscriptionCard(car: car)
              else
                _NoSubscriptionCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Car Header Card ──────────────────────────────────────────────────────────

class _CarHeaderCard extends StatelessWidget {
  final CarInfo car;
  const _CarHeaderCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _carThumb(car.imageUrl),
          const SizedBox(height: 12),
          Text(
            '${car.make} ${car.model}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${car.year} · ${car.color} · ${car.plateNumber}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          StatusBadge.subscriptionType(car.subscription),
        ],
      ),
    );
  }
}

// ── Car Info Section ─────────────────────────────────────────────────────────

class _CarInfoSection extends StatelessWidget {
  final CarInfo car;
  const _CarInfoSection({required this.car});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              const Icon(Icons.directions_car_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(l.carDetailCarInfo,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 10),
          const Divider(height: 0, indent: 16, endIndent: 16),
          _InfoRow(label: l.carDetailMake, value: car.make),
          _InfoRow(label: l.carDetailModel, value: car.model),
          _InfoRow(label: l.carDetailYear, value: '${car.year}'),
          _InfoRow(label: l.carDetailColor, value: car.color),
          _InfoRow(label: l.carDetailPlate, value: car.plateNumber),
        ],
      ),
    );
  }
}

// ── Active Subscription Card ─────────────────────────────────────────────────

class _ActiveSubscriptionCard extends StatelessWidget {
  final CarInfo car;
  const _ActiveSubscriptionCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final planName = switch (car.subscription) {
      SubscriptionType.standard => l.statusStandard,
      SubscriptionType.shared   => l.statusShared,
      SubscriptionType.vip      => l.statusVip,
      _                         => '',
    };

    SubscriptionPlan? plan;
    for (final p in SubscriptionPlan.plans) {
      if (p.type == car.subscription) { plan = p; break; }
    }

    final subColor = switch (car.subscription) {
      SubscriptionType.standard => AppColors.primary,
      SubscriptionType.shared   => AppColors.shared,
      SubscriptionType.vip      => AppColors.vip,
      _                         => AppColors.primary,
    };

    final subBgColor = switch (car.subscription) {
      SubscriptionType.standard => AppColors.primarySurface,
      SubscriptionType.shared   => const Color(0xFFF3E8FF),
      SubscriptionType.vip      => AppColors.warningLight,
      _                         => AppColors.primarySurface,
    };

    final remaining = car.repairsRemaining;
    final total = car.repairsAllowedPerMonth;
    final ratio = total > 0 ? remaining / total : 0.0;
    final progressColor = ratio > 0.5 ? AppColors.success : ratio > 0.2 ? AppColors.warning : AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              const Icon(Icons.verified_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(l.carDetailSubscription,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 10),
          const Divider(height: 0, indent: 16, endIndent: 16),

          // Plan banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: subBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_outlined, color: subColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.profileActivePlan(planName),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subColor),
                  ),
                ),
                if (plan != null)
                  Text(
                    l.myCarsPerMonth(Helpers.formatCurrency(plan.priceIQD)),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subColor),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Expiry
                if (car.subscriptionExpiry != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(l.myCarsExpires(Helpers.formatDate(car.subscriptionExpiry!)),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ]),
                  ),

                // Repairs progress
                if (total > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.build_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(l.myCarsRepairsLeft(remaining),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Spacer(),
                      Text('$remaining / $total',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: progressColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/subscription'),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: Text(l.myCarsPlanDetails),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/payment?carId=${car.id}'),
                        icon: const Icon(Icons.payment, size: 16),
                        label: Text(l.myCarsPayNow),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── No Subscription Card ─────────────────────────────────────────────────────

class _NoSubscriptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l.myCarsNoSubscription,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.warning)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => context.push('/subscription'),
              icon: const Icon(Icons.star_outline, size: 18),
              label: Text(l.myCarsSubscribNow),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

// ── Car thumbnail ────────────────────────────────────────────────────────────
// Renders the uploaded car photo when available; falls back to a car icon on
// missing / failed loads so the header always has something to show.

Widget _carThumb(String? imageUrl) {
  const size = 64.0;
  const radius = 16.0;
  const placeholder = _CarThumbPlaceholder(size: size, radius: radius);

  if (imageUrl == null || imageUrl.isEmpty) return placeholder;

  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : placeholder,
    ),
  );
}

class _CarThumbPlaceholder extends StatelessWidget {
  final double size;
  final double radius;
  const _CarThumbPlaceholder({required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Icon(Icons.directions_car, color: AppColors.primary, size: 34),
    );
  }
}
