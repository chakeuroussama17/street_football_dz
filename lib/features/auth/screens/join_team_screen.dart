import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/team_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/team_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class JoinTeamScreen extends ConsumerStatefulWidget {
  const JoinTeamScreen({super.key});

  @override
  ConsumerState<JoinTeamScreen> createState() => _JoinTeamScreenState();
}

class _JoinTeamScreenState extends ConsumerState<JoinTeamScreen> {
  final _code = TextEditingController();
  Team? _found;
  bool _loading = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final team = await TeamService.findByCode(_code.text);
      setState(() => _found = team);
    } on TeamFailure catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _join() async {
    final t = AppLocalizations.of(context);
    final draft = ref.read(onboardingDraftProvider);
    final team = _found;
    if (team == null) return;
    setState(() => _loading = true);
    try {
      // First-time onboarding: create the profile row before joining.
      if (draft != null) {
        await AuthService.upsertProfile(
          fullName: draft.fullName,
          dateOfBirth: draft.dateOfBirth,
          city: draft.city,
          phone: draft.phone,
          role: 'player',
        );
      }
      // Add the membership (a player can be in many teams) + make it active.
      await TeamService.joinTeam(team.id);
      final me = await AuthService.currentAppUser();
      if (!mounted) return;
      applySessionStateW(ref, me);
      ref.read(onboardingDraftProvider.notifier).state = null;
      ref.invalidate(myTeamProvider);
      ref.invalidate(myTeamsProvider);
      context.goNamed('home');
    } on AuthFailure catch (e) {
      _snack(e.message);
    } on TeamFailure catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(t.fieldRequired);
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
      title: t.joinTeamTitle,
      subtitle: t.joinTeamSubtitle,
      backgroundAsset: 'assets/images/onboarding_team.png',
      bottom: _found == null
          ? CustomButton(
              label: t.continueLabel,
              icon: Icons.search_rounded,
              isLoading: _loading,
              onPressed: _loading ? null : _search,
            )
          : CustomButton(
              label: t.joinTeamBtn,
              icon: Icons.check_rounded,
              isLoading: _loading,
              onPressed: _loading ? null : _join,
            ),
      children: [
        CustomInput(
          label: t.teamCodeLabel,
          hint: 'ABC123',
          controller: _code,
          maxLength: 6,
          inputFormatters: [
            UpperCaseFormatter(),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          onChanged: (_) {
            if (_found != null) setState(() => _found = null);
          },
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1),
        if (_found != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.green.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                TeamAvatar(name: _found!.name, imageUrl: _found!.logoUrl, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_found!.name,
                          style: AppTextStyles.headline(
                              AppColors.darkTextPrimary)),
                      if ((_found!.city ?? '').isNotEmpty)
                        Text(_found!.city!,
                            style: AppTextStyles.body(
                                AppColors.darkTextSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded,
                    color: AppColors.green, size: 24),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15),
        ],
      ],
    );
  }
}

/// Forces input to uppercase (team codes are stored uppercase).
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
