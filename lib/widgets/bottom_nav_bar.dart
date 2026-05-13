import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class UrukBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const UrukBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isGuest = context.watch<AuthProvider>().isGuest;
    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: l.navHome, route: '/home'),
      _NavItem(icon: Icons.car_crash_outlined, activeIcon: Icons.car_crash, label: l.navAccidents, route: '/accidents'),
      _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: l.navAppointments, route: '/appointments'),
      _NavItem(icon: Icons.directions_car_outlined, activeIcon: Icons.directions_car, label: l.navMyCars, route: '/my-cars'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: l.navProfile, route: '/profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    // Guest users can only stay on /home — show login prompt for other tabs.
                    if (item.route != '/home' && context.read<AuthProvider>().isGuest) {
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
                      return;
                    }
                    // Preserve back stack when switching tabs.
                    final current = GoRouterState.of(context).uri.path;
                    if (current != item.route) {
                      context.push(item.route);
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            color: selected ? AppColors.primary : AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (isGuest && item.route != '/home')
                        Positioned(
                          right: -2,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded, size: 9, color: AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.route});
}
