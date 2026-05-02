import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/back_button_handler.dart';

class OtpScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const OtpScreen({super.key, this.extra});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  int _resendSeconds = 60;
  bool _canResend = false;

  String get _phone => widget.extra?['phone'] ?? '';
  String get _flow => widget.extra?['flow'] ?? 'verify';

  @override
  void initState() {
    super.initState();
    // Send OTP immediately when this screen loads — the previous screen only
    // navigates here, it does NOT dispatch the SMS.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendCode());
    _startResendTimer();
  }

  Future<void> _sendCode() async {
    if (_phone.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendOtp(_phone);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال رمز التحقق إلى $_phone'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'تعذّر إرسال الرمز — تحقّق من الرقم وحاول مرة أخرى'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;
    _startResendTimer();
    await _sendCode();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  Future<void> _verify() async {
    final l = context.l10n;
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.otpEnterCode)),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    if (_flow == 'register') {
      final ok = await auth.verifyOtp(_phone, _otp);
      if (!mounted) return;
      if (ok) {
        final success = await auth.register(
          fullName: widget.extra?['name'] ?? '',
          phone: _phone,
          password: widget.extra?['password'] ?? '',
          email: widget.extra?['email'],
        );
        if (mounted && success) context.go('/id-upload');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.otpInvalidCode),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      final ok = await auth.verifyOtp(_phone, _otp);
      if (mounted && ok) context.go('/login');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().state == AuthState.loading;
    final l = context.l10n;

    return BackButtonHandler(
      fallbackRoute: '/register',
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.otpTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/register'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: AppColors.primarySurface, shape: BoxShape.circle),
                child: const Icon(Icons.sms_outlined, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(l.otpTitle, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                l.otpSubtitle(_phone),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (v) => _otp = v,
                onCompleted: (_) => _verify(),
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 52,
                  fieldWidth: 44,
                  activeFillColor: AppColors.surface,
                  inactiveFillColor: AppColors.surface,
                  selectedFillColor: AppColors.primarySurface,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  selectedColor: AppColors.primary,
                ),
                enableActiveFill: true,
                cursorColor: AppColors.primary,
              ),
              const SizedBox(height: 28),

              AppButton(
                label: l.commonConfirm,
                onPressed: isLoading ? null : _verify,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l.otpDidntReceive,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  if (_canResend)
                    TextButton(
                      onPressed: _resendCode,
                      child: Text(l.otpResend),
                    )
                  else
                    Text(
                      l.otpResendIn(_resendSeconds),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
