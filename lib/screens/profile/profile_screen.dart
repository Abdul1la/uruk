import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/car_change_request_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/dev_credit_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l = context.l10n;
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.profileEditButton,
            onPressed: () => _showEditProfileSheet(context, user),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ProfileHeader(user: user),
            const SizedBox(height: 20),

            _InfoSection(
              title: l.profilePersonalInfo,
              icon: Icons.person_outline,
              items: [
                _InfoItem(label: l.profileFullName, value: user?.fullName ?? '—'),
                _InfoItem(label: l.profileMobile, value: user?.phone ?? '—'),
                _InfoItem(label: l.profileEmail, value: user?.email ?? l.profileNotProvided),
                _InfoItem(label: l.profileMemberSince, value: user != null ? _formatMemberDate(user.createdAt, l) : '—'),
              ],
            ),
            const SizedBox(height: 16),

            _InfoSection(
              title: l.profileNationalId,
              icon: Icons.badge_outlined,
              items: [
                _InfoItem(label: l.idFrontLabel, value: user?.idFrontUrl != null ? l.profileIdUploaded : l.profileIdNotUploaded),
                _InfoItem(label: l.idBackLabel, value: user?.idBackUrl != null ? l.profileIdUploaded : l.profileIdNotUploaded),
              ],
            ),
            const SizedBox(height: 24),

            // ── Privacy policy link ─────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () => context.push('/privacy'),
              icon: const Icon(Icons.shield_outlined, color: AppColors.primary),
              label: Text(
                l.privacyPolicyTitle,
                style: const TextStyle(color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, auth),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(l.profileLogout, style: const TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 12),

            // ── Delete account (App Store guideline 5.1.1(v)) ───────────
            TextButton.icon(
              onPressed: () => _confirmDeleteAccount(context, auth),
              icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error, size: 20),
              label: Text(
                l.profileDeleteAccount,
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
            ),
            const SizedBox(height: 8),
            Text(l.appVersion, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatMemberDate(DateTime dt, AppLocalizations l) {
    final months = [
      l.oilChangeMonthJan, l.oilChangeMonthFeb, l.oilChangeMonthMar,
      l.oilChangeMonthApr, l.oilChangeMonthMay, l.oilChangeMonthJun,
      l.oilChangeMonthJul, l.oilChangeMonthAug, l.oilChangeMonthSep,
      l.oilChangeMonthOct, l.oilChangeMonthNov, l.oilChangeMonthDec,
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _showEditProfileSheet(BuildContext context, UserModel? user) {
    if (user == null) return;
    final l = context.l10n;
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email ?? '');
    final phoneController = TextEditingController(text: user.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
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
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.profileEditTitle,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(l.profileEditDesc,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              // Name field
              Text(l.profileEditName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: l.profileEditName,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),

              // Phone field
              Text(l.profileEditPhone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: phoneController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: l.profileEditPhone,
                  hintTextDirection: TextDirection.ltr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Email field
              Text(l.profileEditEmail, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: l.profileEditEmail,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l.profileEditDesc,
                          style: const TextStyle(fontSize: 11, color: AppColors.warning)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: () async {
                  final changes = <String, String>{};
                  if (nameController.text.trim() != user.fullName) {
                    changes['fullName'] = nameController.text.trim();
                  }
                  if (phoneController.text.trim() != user.phone) {
                    changes['phone'] = phoneController.text.trim();
                  }
                  final newEmail = emailController.text.trim();
                  if (newEmail != (user.email ?? '') && newEmail.isNotEmpty) {
                    changes['email'] = newEmail;
                  }

                  if (changes.isEmpty) {
                    Navigator.pop(sheetCtx);
                    Helpers.showSnackBar(context, l.profileEditNoChanges);
                    return;
                  }

                  final app = context.read<AppProvider>();
                  await app.submitCarChangeRequest(
                    userId: user.id,
                    requestedChanges: changes,
                    type: CarChangeRequestType.profileEdit,
                  );
                  if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  if (context.mounted) {
                    Helpers.showSnackBar(context, l.profileEditSuccess);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(l.profileEditSubmit),
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
    );
  }

  void _confirmDeleteAccount(BuildContext context, AuthProvider auth) {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error, size: 32),
        title: Text(l.profileDeleteAccountConfirmTitle),
        content: Text(l.profileDeleteAccountConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              // Block the UI while the request is in flight.
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              final ok = await auth.deleteAccount();
              if (!context.mounted) return;
              Navigator.pop(context); // dismiss the spinner
              if (ok) {
                context.go('/login');
                Helpers.showSnackBar(context, l.profileDeleteAccountSuccess);
              } else {
                Helpers.showSnackBar(
                  context,
                  auth.errorMessage ?? l.profileDeleteAccountError,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l.profileDeleteAccountButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.profileLogoutConfirmTitle),
        content: Text(l.profileLogoutConfirmContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
              Future.microtask(() => auth.logout());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l.profileLogout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
            child: Center(
              child: Text(
                (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(user?.fullName ?? l.profileMemberFallback,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(user?.phone ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          if (user != null) StatusBadge.subscriptionType(user!.subscription),
        ],
      ),
    );
  }
}


class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoItem> items;

  const _InfoSection({required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
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
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 10),
          const Divider(height: 0, indent: 16, endIndent: 16),
          ...items.map((item) => _InfoRow(item: item)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final _InfoItem item;
  const _InfoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(item.label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(item.value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}

