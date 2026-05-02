import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/subscription_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/status_badge.dart';

class MyCarsScreen extends StatelessWidget {
  const MyCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l = context.l10n;
    final user = auth.user;
    final cars = user?.cars ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.myCarsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l.myCarsAddCar,
            onPressed: () => context.push('/add-car/new'),
          ),
        ],
      ),
      body: cars.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _CarCard(car: cars[i], index: i),
            ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.directions_car_outlined,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              l.myCarsNoCars,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.myCarsNoCarsDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-car/new'),
              icon: const Icon(Icons.add, size: 20),
              label: Text(l.myCarsAddCar),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Car Card ─────────────────────────────────────────────────────────────────

class _CarCard extends StatelessWidget {
  final CarInfo car;
  final int index;

  const _CarCard({required this.car, required this.index});

  @override
  Widget build(BuildContext context) {
    final hasSub = car.subscription != SubscriptionType.none;
    final pendingForThisCar =
        context.watch<AppProvider>().pendingUpgradeRequest?.carId == car.id;

    return GestureDetector(
      onTap: () => context.push('/car/${car.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            // Car header
            _CarHeader(
              car: car,
              index: index,
              isPending: !hasSub && pendingForThisCar,
            ),
            const Divider(height: 0),
            // Subscription section
            if (hasSub)
              _SubscriptionInfo(car: car)
            else if (pendingForThisCar)
              const _PendingSubscription()
            else
              _NoSubscription(car: car),
          ],
        ),
      ),
    );
  }
}

// ── Car Header ───────────────────────────────────────────────────────────────

class _CarHeader extends StatelessWidget {
  final CarInfo car;
  final int index;
  final bool isPending;

  const _CarHeader({
    required this.car,
    required this.index,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _CarThumb(imageUrl: car.imageUrl, size: 48, radius: 12, iconSize: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.make} ${car.model}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${car.year} · ${car.plateNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isPending)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l.subscriptionPendingBadge,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            )
          else
            StatusBadge.subscriptionType(car.subscription),
        ],
      ),
    );
  }
}

// ── Subscription Info (has active plan) ──────────────────────────────────────

class _SubscriptionInfo extends StatelessWidget {
  final CarInfo car;

  const _SubscriptionInfo({required this.car});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final planName = switch (car.subscription) {
      SubscriptionType.standard => l.statusStandard,
      SubscriptionType.shared   => l.statusShared,
      SubscriptionType.vip      => l.statusVip,
      _                         => '',
    };

    // Find the plan to get the price
    SubscriptionPlan? plan;
    for (final p in SubscriptionPlan.plans) {
      if (p.type == car.subscription) {
        plan = p;
        break;
      }
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

    return Column(
      children: [
        // Plan name + price banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: subBgColor,
          child: Row(
            children: [
              Icon(Icons.verified_outlined, color: subColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.profileActivePlan(planName),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                ),
              ),
              if (plan != null)
                Text(
                  l.myCarsPerMonth(Helpers.formatCurrency(plan.priceIQD)),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                ),
            ],
          ),
        ),

        // Details rows
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Expiry
              if (car.subscriptionExpiry != null)
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: l.myCarsExpires(Helpers.formatDate(car.subscriptionExpiry!)),
                ),

              // Repairs remaining
              if (car.repairsAllowedPerMonth > 0) ...[
                const SizedBox(height: 10),
                _RepairsProgress(car: car),
              ],

              const SizedBox(height: 14),

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
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
    );
  }
}

// ── Repairs Progress Bar ─────────────────────────────────────────────────────

class _RepairsProgress extends StatelessWidget {
  final CarInfo car;

  const _RepairsProgress({required this.car});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final remaining = car.repairsRemaining;
    final total = car.repairsAllowedPerMonth;
    final ratio = total > 0 ? remaining / total : 0.0;

    final progressColor = ratio > 0.5
        ? AppColors.success
        : ratio > 0.2
            ? AppColors.warning
            : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.build_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              l.myCarsRepairsLeft(remaining),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text(
              '$remaining / $total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
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
      ],
    );
  }
}

// ── Pending Subscription ─────────────────────────────────────────────────────

class _PendingSubscription extends StatelessWidget {
  const _PendingSubscription();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
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
                const Icon(Icons.pending_actions,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.subscriptionPendingShort,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.subscriptionPendingDesc,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.push('/subscription'),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: Text(l.subscriptionPendingViewStatus),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              foregroundColor: AppColors.warning,
              side: const BorderSide(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

// ── No Subscription ──────────────────────────────────────────────────────────

class _NoSubscription extends StatelessWidget {
  final CarInfo car;

  const _NoSubscription({required this.car});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
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
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.myCarsNoSubscription,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warning,
                    ),
                  ),
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
    );
  }
}

// ── Detail Row ───────────────────────────────────────────────────────────────

// ── Car thumbnail ────────────────────────────────────────────────────────────
// Renders the uploaded car photo when available; falls back to a car icon on
// missing / failed loads so the tile always has something to show.

class _CarThumb extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double radius;
  final double iconSize;

  const _CarThumb({
    required this.imageUrl,
    required this.size,
    required this.radius,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.directions_car,
          color: AppColors.primary, size: iconSize),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : placeholder,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
