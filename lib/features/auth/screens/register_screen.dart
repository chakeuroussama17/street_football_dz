import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../core/widgets/wilaya_dropdown.dart';
import '../../../l10n/app_localizations.dart';

/// Registration: email + password (the login credential) plus the profile
/// details (name, DOB, wilaya, phone). On submit it creates the account, then
/// goes to the captain/player choice. No OTP, no SMS.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _dob;
  String? _city;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 80),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.green, surface: AppColors.darkSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _snack(t.invalidEmail);
      return;
    }
    if (_password.text.length < 6) {
      _snack(t.passwordTooShort);
      return;
    }
    if (_name.text.trim().isEmpty || _dob == null || _city == null) {
      _snack(t.fieldRequired);
      return;
    }
    final phone = normalizeDzPhone(_phone.text);
    if (phone == null) {
      _snack(t.invalidPhone);
      return;
    }
    final now = DateTime.now();
    var age = now.year - _dob!.year;
    if (now.month < _dob!.month ||
        (now.month == _dob!.month && now.day < _dob!.day)) {
      age--;
    }
    if (age < 13) {
      _snack(t.ageTooYoung);
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.signUp(email: email, password: _password.text);
      if (!mounted) return;
      // Admin account: create the profile now and go straight in (no team).
      if (SupabaseService.isAdminEmail) {
        final me = await AuthService.upsertProfile(
          fullName: _name.text.trim(),
          dateOfBirth: _dob!,
          city: _city!,
          phone: phone,
          role: 'admin',
        );
        if (!mounted) return;
        applySessionStateW(ref, me);
        context.goNamed('home');
        return;
      }
      ref.read(onboardingDraftProvider.notifier).state = OnboardingDraft(
        fullName: _name.text.trim(),
        dateOfBirth: _dob!,
        city: _city!,
        phone: phone,
      );
      context.goNamed('role-choice');
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
      title: t.registerTitle,
      subtitle: t.registerSubtitle,
      bottom: CustomButton(
        label: t.createAccount,
        icon: Icons.arrow_forward_rounded,
        isLoading: _loading,
        onPressed: _loading ? null : _submit,
      ),
      children: [
        CustomInput(
          label: t.emailLabel,
          hint: t.emailHint,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: t.passwordLabel,
          controller: _password,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        CustomInput(label: t.fullName, controller: _name),
        const SizedBox(height: 16),
        _DateField(
          label: t.dateOfBirth,
          value: _dob == null
              ? t.selectDate
              : DateFormat.yMMMMd().format(_dob!),
          isPlaceholder: _dob == null,
          onTap: _pickDate,
        ),
        const SizedBox(height: 16),
        WilayaDropdown(
          label: t.cityWilaya,
          hint: t.selectCity,
          value: _city,
          onChanged: (v) => setState(() => _city = v),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => context.pushReplacementNamed('login'),
            child: Text(t.iHaveAccount,
                style: const TextStyle(color: AppColors.green)),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkTextSecondary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 18, color: AppColors.darkTextMuted),
                const SizedBox(width: 10),
                Text(value,
                    style: TextStyle(
                        color: isPlaceholder
                            ? AppColors.darkTextMuted
                            : AppColors.darkTextPrimary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
