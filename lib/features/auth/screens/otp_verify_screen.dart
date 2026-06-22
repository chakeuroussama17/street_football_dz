import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../l10n/app_localizations.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String phone; // E.164
  const OtpVerifyScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  int _resendIn = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendIn = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (tm) {
      if (_resendIn <= 0) {
        tm.cancel();
      } else {
        setState(() => _resendIn--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controller.text.trim();
    if (code.length < 6) return;
    setState(() => _loading = true);
    try {
      final res = await AuthService.verifyOtp(widget.phone, code);
      if (!mounted) return;
      if (res.isNew) {
        // Brand new → collect profile basics.
        context.goNamed('profile-setup');
        return;
      }
      // Returning user: load session state and route by completeness.
      final profile = res.profile!;
      applySessionStateW(ref, profile);
      if (profile.hasTeam) {
        context.goNamed('home');
      } else {
        // Profile exists but onboarding wasn't finished — resume at role choice.
        ref.read(onboardingDraftProvider.notifier).state = OnboardingDraft(
          fullName: profile.fullName,
          dateOfBirth: profile.dateOfBirth ?? DateTime(2000),
          city: profile.city ?? '',
        );
        context.goNamed('role-choice');
      }
    } on AuthFailure catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_resendIn > 0) return;
    try {
      await AuthService.sendOtp(widget.phone);
      _startCountdown();
    } on AuthFailure catch (e) {
      _snack(e.message);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.red));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return OnboardingScaffold(
      title: t.otpTitle,
      subtitle: t.otpSubtitle(prettyDzPhone(widget.phone)),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            label: t.verify,
            icon: Icons.check_rounded,
            isLoading: _loading,
            onPressed: _loading ? null : _verify,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _resendIn > 0 ? null : _resend,
            child: Text(
              _resendIn > 0 ? t.resendIn(_resendIn) : t.resendCode,
              style: TextStyle(
                color: _resendIn > 0
                    ? AppColors.darkTextMuted
                    : AppColors.green,
              ),
            ),
          ),
        ],
      ),
      children: [
        CustomInput(
          label: t.codeLabel,
          hint: '••••••',
          controller: _controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            if (v.length == 6 && !_loading) _verify();
          },
        ),
      ],
    );
  }
}
