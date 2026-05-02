import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/back_button_handler.dart';
import '../../widgets/common/uruk_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final l = context.l10n;
    final ok = await auth.login(_phoneCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      if (auth.isPending) {
        context.go('/pending');
      } else {
        context.go('/garage');
      }
      return;
    }

    // Login "failed" — distinguish suspended / rejected from bad credentials.
    if (auth.isSuspended) {
      _showAccountBlockedDialog(
        title: l.authSuspendedTitle,
        message: l.authSuspendedMessage,
      );
      return;
    }
    if (auth.isRejected) {
      _showAccountBlockedDialog(
        title: l.authRejectedTitle,
        message: l.authRejectedMessage,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.errorMessage ?? l.commonRetry),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showAccountBlockedDialog({
    required String title,
    required String message,
  }) {
    final l = context.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.block_outlined, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: Text(l.commonOk),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              context.push('/support');
            },
            icon: const Icon(Icons.support_agent_outlined, size: 16),
            label: Text(l.supportTitle),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().state == AuthState.loading;
    final l = context.l10n;

    return BackButtonHandler(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Center(child: UrukLogo(fontSize: 38, showTagline: true)),
                const SizedBox(height: 48),

                Text(l.loginWelcomeBack, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(l.loginSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        label: l.loginPhone,
                        hint: l.loginPhoneHint,
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: Validators.phone(context),
                        textInputAction: TextInputAction.next,
                        textDirection: TextDirection.ltr,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: l.loginPassword,
                        controller: _passCtrl,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: Validators.password(context),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: l.loginSignInButton,
                        onPressed: isLoading ? null : _login,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l.commonOr,
                          style: const TextStyle(color: AppColors.textSecondary)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                AppButton(
                  label: l.loginRegister,
                  onPressed: () => context.go('/register'),
                  isOutlined: true,
                  icon: Icons.person_add_outlined,
                ),

                const SizedBox(height: 24),

                // Privacy Policy notice + link
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.push('/privacy'),
                    icon: const Icon(Icons.shield_outlined, size: 16, color: AppColors.textSecondary),
                    label: Text(
                      l.privacyPolicyView,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
