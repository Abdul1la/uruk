import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/accident_report_model.dart';
import '../../models/subscription_model.dart';
import '../../models/upgrade_request_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isGuest && auth.user != null) {
        context.read<AppProvider>().loadAll(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final l = context.l10n;
    final user = auth.user;
    final car = app.selectedCar ?? user?.car;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _Header(user: user, car: car, unreadCount: app.unreadCount, isGuest: auth.isGuest),
          ),

          // ── Guest banner ──────────────────────────────────────────────────
          if (auth.isGuest)
            SliverToBoxAdapter(
              child: _GuestBanner(),
            ),

          // ── Subscription card / Guest promo ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: auth.isGuest
                  ? const _GuestPromoCard()
                  : Builder(
                      builder: (_) {
                        final pending = car != null &&
                                app.pendingUpgradeRequest?.carId == car.id
                            ? app.pendingUpgradeRequest
                            : null;
                        return _SubscriptionCard(car: car, pendingForCar: pending);
                      },
                    ),
            ),
          ),

          // ── Payment alert ─────────────────────────────────────────────────
          if (user?.paymentDue == true)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _PaymentAlert(onTap: () {
                  // Navigate to the first car that has an active subscription (unpaid)
                  final unpaidCar = user!.cars.where(
                    (c) => c.subscription != SubscriptionType.none,
                  ).firstOrNull;
                  if (unpaidCar != null) {
                    context.push('/car/${unpaidCar.id}');
                  } else {
                    context.push('/my-cars');
                  }
                }),
              ),
            ),

          // ── Quick actions ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _QuickActions(isGuest: auth.isGuest),
            ),
          ),

          // ── Upcoming appointment ──────────────────────────────────────────
          if (app.upcomingAppointment != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _UpcomingAppointmentCard(appointment: app.upcomingAppointment!),
              ),
            ),

          // ── Recent accidents ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.homeRecentReports,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  TextButton(onPressed: () => context.push('/accidents'), child: Text(l.homeViewAll)),
                ],
              ),
            ),
          ),

          if (app.loadingAccidents)
            const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
            )
          else if (app.accidents.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(child: Text(l.homeNoReports, style: const TextStyle(color: AppColors.textSecondary))),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final r = app.accidents[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _RecentReportTile(report: r),
                  );
                },
                childCount: app.accidents.length > 3 ? 3 : app.accidents.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final UserModel? user;
  final CarInfo? car;
  final int unreadCount;
  final bool isGuest;
  const _Header({this.user, this.car, required this.unreadCount, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/garage'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.garage_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 5),
                      Text(l.homeGarageBack, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // ── Contact-us pill (text-only, localized) ────────────────
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push('/support'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l.supportCallUs, // "اتصل بنا" / "Call Us"
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white, size: 24),
                onPressed: () => context.push('/profile'),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Center(
                          child: Text('$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${Helpers.greetingByTime(context)}،',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            isGuest ? l.guestBannerMessage : (user?.fullName.split(' ').first ?? l.homeMemberFallback),
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          if (car != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${car!.make} ${car!.model} ${car!.year} • ${car!.plateNumber}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
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

// ── Subscription Card ─────────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  final CarInfo? car;
  final UpgradeRequest? pendingForCar;
  const _SubscriptionCard({this.car, this.pendingForCar});

  @override
  Widget build(BuildContext context) {
    final hasSub = car != null && car!.subscription != SubscriptionType.none;
    final Widget body;
    if (hasSub) {
      body = _ActiveSub(car: car!);
    } else if (pendingForCar != null) {
      body = _PendingSub();
    } else {
      body = _NoSub();
    }
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: body,
            ),
            // When the user already has an active subscription AND has submitted
            // a pending upgrade request, surface the pending state inline so
            // they don't assume nothing is happening with their new request.
            if (hasSub && pendingForCar != null)
              _PendingUpgradeStrip(request: pendingForCar!),
          ],
        ),
      ),
    );
  }
}

class _PendingUpgradeStrip extends StatelessWidget {
  final UpgradeRequest request;
  const _PendingUpgradeStrip({required this.request});

  String _planName(SubscriptionType type, AppLocalizations l) {
    switch (type) {
      case SubscriptionType.standard: return l.statusStandard;
      case SubscriptionType.shared:   return l.statusShared;
      case SubscriptionType.vip:      return l.statusVip;
      default:                        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return InkWell(
      onTap: () => context.push('/subscription'),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending_actions, color: AppColors.warning, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.subscriptionUpgradePendingTo(
                    _planName(request.requestedPlan, l)),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.warning, size: 18),
          ],
        ),
      ),
    );
  }
}

class _PendingSub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.pending_actions, color: AppColors.warning, size: 20),
        ),
        const SizedBox(width: 12),
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
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => context.push('/subscription'),
          child: Text(l.subscriptionPendingViewStatus),
        ),
      ],
    );
  }
}

class _ActiveSub extends StatelessWidget {
  final CarInfo car;
  const _ActiveSub({required this.car});

  Color get _color {
    switch (car.subscription) {
      case SubscriptionType.standard: return AppColors.primary;
      case SubscriptionType.shared:   return const Color(0xFF7C3AED);
      case SubscriptionType.vip:      return const Color(0xFFB45309);
      default:                        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final used    = car.repairsUsedThisMonth;
    final allowed = car.repairsAllowedPerMonth;
    final progress = allowed > 0 ? used / allowed : 0.0;
    final exhausted = car.repairsExhausted;

    final planName = switch (car.subscription) {
      SubscriptionType.standard => l.statusStandard,
      SubscriptionType.shared   => l.statusShared,
      SubscriptionType.vip      => l.statusVip,
      _                         => '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.verified_outlined, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.homeMySubscription,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Row(
                    children: [
                      Text(planName,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _color)),
                      const SizedBox(width: 8),
                      StatusBadge.subscriptionType(car.subscription),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _color.withValues(alpha: 0.25)),
              ),
              child: Text(
                SubscriptionPlan.periodLabel(car.paymentMonths),
                // Keep on a single line so "سنة مقدماً" never wraps to two
                // lines when the card is narrow.
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: _color,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),
        const Divider(height: 0),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.homeRepairsThisMonth,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$used',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: exhausted ? AppColors.error : _color),
                  ),
                  TextSpan(
                    text: ' / $allowed',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: _color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
                exhausted ? AppColors.error : _color),
          ),
        ),
        if (exhausted) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.error, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l.homeRepairsExhausted,
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 4),
          Text(
            l.homeRepairsRemaining(car.repairsRemaining),
            style: TextStyle(
                fontSize: 11,
                color: _color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500),
          ),
        ],

        if (car.subscriptionStart != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.play_circle_outline,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                l.homeSubscriptionStart(Helpers.formatDate(car.subscriptionStart!)),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],

        if (car.subscriptionExpiry != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                l.homeSubscriptionExpiry(Helpers.formatDate(car.subscriptionExpiry!)),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/subscription'),
                child: Text(
                  l.homeUpgradeLink,
                  style: TextStyle(
                      fontSize: 11,
                      color: _color,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Guest Banner ──────────────────────────────────────────────────────────────

class _GuestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.guestBannerMessage,
              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            child: Text(l.guestBannerAction, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Guest Promo Card ──────────────────────────────────────────────────────────

class _GuestPromoCard extends StatelessWidget {
  const _GuestPromoCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.card_membership_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.homeMySubscription,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const Text(
                        'Uruk Motors',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 0),
            const SizedBox(height: 14),
            for (final feature in const [
              (Icons.verified_outlined, 'خطط اشتراك مرنة لسيارتك'),
              (Icons.build_circle_outlined, 'صيانة دورية وتغيير زيت'),
              (Icons.car_crash_outlined, 'تقارير حوادث فورية'),
            ]) ...[
              Row(
                children: [
                  Icon(feature.$1, color: Colors.white70, size: 15),
                  const SizedBox(width: 8),
                  Text(feature.$2, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  context.go('/login');
                },
                child: Text(l.guestBannerAction, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l.homeNoSubscription,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => context.push('/subscription'),
          child: Text(l.homeSubscribeButton),
        ),
      ],
    );
  }
}

// ── Payment Alert ─────────────────────────────────────────────────────────────

class _PaymentAlert extends StatelessWidget {
  final VoidCallback onTap;
  const _PaymentAlert({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.payment, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.homePaymentDue,
                style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.error, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final bool isGuest;
  const _QuickActions({this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final actions = [
      _QuickAction(icon: Icons.car_crash_outlined,      label: l.homeReportAccident,  color: AppColors.error,   route: '/accidents/report'),
      _QuickAction(icon: Icons.build_circle_outlined,   label: l.homeOilChange,        color: const Color(0xFF065F46), route: '/oil-change'),
      _QuickAction(icon: Icons.calendar_month_outlined, label: l.homeMyAppointments,   color: AppColors.info,    route: '/appointments'),
      _QuickAction(icon: Icons.card_membership_outlined, label: l.homeMyPlan,          color: AppColors.warning, route: '/subscription'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.homeQuickActionsTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Row(
          children: actions.map((a) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _QuickActionBtn(action: a, isGuest: isGuest),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.route});
}

class _QuickActionBtn extends StatelessWidget {
  final _QuickAction action;
  final bool isGuest;
  const _QuickActionBtn({required this.action, this.isGuest = false});

  void _showGuestDialog(BuildContext context) {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(l.guestLoginRequired)),
        ]),
        content: Text(l.guestLoginRequiredMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx), child: Text(l.commonCancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            child: Text(l.guestLoginButton),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context) {
    // Guest users can't use any action
    if (context.read<AuthProvider>().isGuest) {
      _showGuestDialog(context);
      return;
    }
    // Block accident report if user has no active subscription
    if (action.route == '/accidents/report') {
      final car = context.read<AppProvider>().selectedCar ??
          context.read<AuthProvider>().user?.car;
      if (car == null || car.subscription == SubscriptionType.none) {
        final l = context.l10n;
        showDialog(
          context: context,
          builder: (dlgCtx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(children: [
              const Icon(Icons.block_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l.accidentNoSubscriptionTitle)),
            ]),
            content: Text(l.accidentNoSubscriptionContent),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dlgCtx), child: Text(l.commonOk)),
              ElevatedButton(
                onPressed: () { Navigator.pop(dlgCtx); context.push('/subscription'); },
                child: Text(l.accidentNoSubscriptionAction),
              ),
            ],
          ),
        );
        return;
      }
    }
    context.push(action.route);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Column(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: isGuest ? 0.05 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(action.icon, color: action.color.withValues(alpha: isGuest ? 0.4 : 1.0), size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isGuest ? AppColors.textSecondary : AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (isGuest)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Icon(Icons.lock_rounded, size: 10, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Upcoming Appointment ──────────────────────────────────────────────────────

class _UpcomingAppointmentCard extends StatelessWidget {
  final dynamic appointment;
  const _UpcomingAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.homeUpcomingAppointmentTitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  Helpers.formatDate(appointment.scheduledDate),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(appointment.timeSlot, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/appointments'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(l.homeViewButton, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Report Tile ────────────────────────────────────────────────────────

class _RecentReportTile extends StatelessWidget {
  final AccidentReport report;
  const _RecentReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/accidents/${report.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.car_crash_outlined, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.location,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textPrimary)),
                  Text(Helpers.formatDate(report.accidentDate),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            StatusBadge.reportStatus(report.status),
          ],
        ),
      ),
    );
  }
}
