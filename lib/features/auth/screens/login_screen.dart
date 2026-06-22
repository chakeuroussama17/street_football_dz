import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// Simple login: email + password. Routes to home (has a team) or the
/// captain/player choice (finished registering but never picked a team).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final t = AppLocalizations.of(context);
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      _snack(t.fieldRequired);
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signIn(
          email: _email.text.trim(), password: _password.text);
      final me = await AuthService.currentAppUser();
      if (!mounted) return;
      applySessionStateW(ref, me);
      if (me != null && me.hasTeam) {
        context.goNamed('home');
      } else if (me != null) {
        // Registered but never picked a team — resume there.
        ref.read(onboardingDraftProvider.notifier).state = OnboardingDraft(
          fullName: me.fullName,
          dateOfBirth: me.dateOfBirth ?? DateTime(2000),
          city: me.city ?? '',
          phone: me.phone,
        );
        context.goNamed('role-choice');
      } else {
        // Auth ok but no profile row yet → finish via register details.
        context.goNamed('register');
      }
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
      title: t.loginTitle,
      subtitle: t.loginSubtitle,
      bottom: CustomButton(
        label: t.login,
        icon: Icons.login_rounded,
        isLoading: _loading,
        onPressed: _loading ? null : _login,
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
        Center(
          child: TextButton(
            onPressed: () => context.pushReplacementNamed('register'),
            child: Text(t.noAccountCta,
                style: const TextStyle(color: AppColors.green)),
          ),
        ),
      ],
    );
  }
}
