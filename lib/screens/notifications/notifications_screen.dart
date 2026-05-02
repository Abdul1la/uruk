import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/notification_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/back_button_handler.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) context.read<AppProvider>().loadNotifications(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final auth = context.watch<AuthProvider>();
    final userId = auth.user?.id;
    final l = context.l10n;

    return BackButtonHandler(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l.notificationsTitle),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/home')),
          actions: [
            if (app.unreadCount > 0 && userId != null)
              TextButton(
                onPressed: () => app.markAllNotificationsRead(userId),
                child: Text(l.notificationsMarkAllRead, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
        body: app.loadingNotifications
            ? const Center(child: CircularProgressIndicator())
            : app.notifications.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: app.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _NotifTile(
                      notif: app.notifications[i],
                      onTap: () {
                        if (userId != null) {
                          app.markNotificationRead(
                            userId,
                            app.notifications[i].id,
                          );
                        }
                        final route = app.notifications[i].actionRoute;
                        if (route == null) return;
                        // Routes inside the ShellRoute (/home, /accidents list,
                        // /appointments, /my-cars, /profile) must use go() so
                        // the bottom-nav Scaffold mounts properly. Using push()
                        // on a shell route from outside the shell leaves the
                        // child screen stranded with no MainShell wrapper,
                        // which is why opening an appointment notification
                        // used to render a blank white page.
                        const shellRoutes = {
                          '/home',
                          '/appointments',
                          '/my-cars',
                          '/profile',
                        };
                        final isShellRoute = shellRoutes.contains(route) ||
                            route == '/accidents';
                        if (isShellRoute) {
                          context.go(route);
                        } else {
                          context.push(route);
                        }
                      },
                    ),
                  ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  IconData get _icon {
    switch (notif.type) {
      case NotificationType.payment: return Icons.payment;
      case NotificationType.appointment: return Icons.calendar_month;
      case NotificationType.report: return Icons.car_crash_outlined;
      case NotificationType.subscription: return Icons.card_membership_outlined;
      case NotificationType.general: return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (notif.type) {
      case NotificationType.payment: return AppColors.error;
      case NotificationType.appointment: return AppColors.primary;
      case NotificationType.report: return AppColors.info;
      case NotificationType.subscription: return AppColors.warning;
      case NotificationType.general: return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime dt, AppLocalizations l) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return l.notificationsTimeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l.notificationsTimeAgoHours(diff.inHours);
    return Helpers.formatDate(dt);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead ? AppColors.divider : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            )),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.body,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(_timeAgo(notif.createdAt, l),
                      style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                ],
              ),
            ),
            if (notif.actionRoute != null)
              const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(l.notificationsEmpty, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
