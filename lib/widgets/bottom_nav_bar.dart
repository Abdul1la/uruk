import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';

class UrukBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const UrukBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
                    // Preserve back stack when switching tabs: push unless we're
                    // already on this tab (avoid stacking duplicates of same tab).
                    final current = GoRouterState.of(context).uri.path;
                    if (current != item.route) {
                      context.push(item.route);
                    }
                  },
                  child: Column(
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
