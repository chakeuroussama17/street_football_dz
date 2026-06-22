import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../core/widgets/wilaya_dropdown.dart';
import '../../../l10n/app_localizations.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _name = TextEditingController();
  DateTime? _dob;
  String? _city;

  @override
  void dispose() {
    _name.dispose();
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
            primary: AppColors.green,
            surface: AppColors.darkSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _continue() {
    final t = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty || _dob == null || _city == null) {
      _snack(t.fieldRequired);
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
    ref.read(onboardingDraftProvider.notifier).state = OnboardingDraft(
      fullName: _name.text.trim(),
      dateOfBirth: _dob!,
      city: _city!,
    );
    context.goNamed('role-choice');
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.red));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return OnboardingScaffold(
      title: t.profileTitle,
      subtitle: t.profileSubtitle,
      showBack: false,
      bottom: CustomButton(
        label: t.continueLabel,
        icon: Icons.arrow_forward_rounded,
        onPressed: _continue,
      ),
      children: [
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
