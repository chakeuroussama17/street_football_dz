import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../l10n/app_localizations.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = AppLocalizations.of(context);
    final phone = normalizeDzPhone(_controller.text);
    if (phone == null) {
      _snack(t.invalidPhone);
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.sendOtp(phone);
      if (!mounted) return;
      context.pushNamed('otp', extra: phone);
    } on AuthFailure catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.red));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return OnboardingScaffold(
      title: t.phoneTitle,
      subtitle: t.phoneSubtitle,
      bottom: CustomButton(
        label: t.sendCode,
        icon: Icons.sms_rounded,
        isLoading: _loading,
        onPressed: _loading ? null : _send,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed +213 prefix.
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: const Text('🇩🇿  +213',
                    style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomInput(
                label: t.phoneLabel,
                hint: t.phoneHint,
                controller: _controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
