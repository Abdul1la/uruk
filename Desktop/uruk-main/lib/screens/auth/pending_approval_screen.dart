import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/back_button_handler.dart';
import '../../widgets/common/uruk_logo.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial refresh after the first frame so we don't miss an
    // already-approved user who reopened the app.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user comes back to the app, re-check their status.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _refresh(),
    );
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    await auth.refreshUser();
    if (!mounted) return;
    // React to status changes from the backend.
    if (auth.isAuthenticated) {
      context.go('/garage');
    } else if (auth.isSuspended || auth.isRejected) {
      // Blocked by admin — drop back to login where the dialog flow fires.
      auth.logout();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return BackButtonHandler(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const UrukLogo(fontSize: 28),
                const Spacer(),

                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                      color: AppColors.primarySurface, shape: BoxShape.circle),
                  child: const Icon(Icons.access_time_rounded,
                      size: 60, color: AppColors.primary),
                ),
                const SizedBox(height: 32),

                Text(
                  l.pendingTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  l.pendingSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 32),

                _StepTile(step: 1, label: l.pendingStep1, isDone: true),
                _StepTile(step: 2, label: l.pendingStep2, isDone: true),
                _StepTile(step: 3, label: l.pendingStep3, isDone: false, isCurrent: true),
                _StepTile(step: 4, label: l.pendingStep4, isDone: false),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.pendingSmsNotification,
                          style: const TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    context.go('/login');
                  },
                  child: Text(l.pendingBackToLogin),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int step;
  final String label;
  final bool isDone;
  final bool isCurrent;

  const _StepTile({
    required this.step,
    required this.label,
    required this.isDone,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppColors.success
                  : isCurrent
                      ? AppColors.primary
                      : AppColors.border,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : isCurrent
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('$step',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isDone || isCurrent
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
