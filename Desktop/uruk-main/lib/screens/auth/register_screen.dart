import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/back_button_handler.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  /// Set by the privacy-policy checkbox; required before sending the OTP.
  bool _agreedToPrivacy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.privacyPolicyAgreePrefix + context.l10n.privacyPolicyLink),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    context.push('/otp', extra: {
      'phone': _phoneCtrl.text.trim(),
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text,
      'flow': 'register',
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return BackButtonHandler(
      fallbackRoute: '/login',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l.registerTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.registerTitle, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(l.registerSubtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 28),

                  AppTextField(
                    label: l.registerFullName,
                    hint: l.registerFullNameHint,
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.name(context),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: l.registerPhone,
                    hint: l.registerPhoneHint,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: Validators.phone(context),
                    textInputAction: TextInputAction.next,
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: l.registerEmailOptional,
                    hint: l.registerEmailHint,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.email(context),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: l.registerPassword,
                    controller: _passCtrl,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: Validators.password(context),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: l.registerConfirmPassword,
                    controller: _confirmCtrl,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: Validators.confirmPassword(context, _passCtrl),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),

                  // ── Privacy-policy consent ─────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _agreedToPrivacy,
                        onChanged: (v) => setState(() => _agreedToPrivacy = v ?? false),
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _agreedToPrivacy = !_agreedToPrivacy),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(text: l.privacyPolicyAgreePrefix),
                                  TextSpan(
                                    text: l.privacyPolicyLink,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/privacy'),
                        child: Text(l.privacyPolicyView),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  AppButton(
                    label: l.registerNextVerify,
                    onPressed: _next,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.registerAlreadyHaveAccount,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(l.registerSignIn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
