import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../l10n/app_localizations.dart';

class RoleChoiceScreen extends ConsumerWidget {
  const RoleChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return OnboardingScaffold(
      title: t.roleTitle,
      subtitle: t.roleSubtitle,
      showBack: false,
      children: [
        _RoleCard(
          icon: Icons.shield_rounded,
          color: AppColors.green,
          title: t.captain,
          desc: t.captainDesc,
          onTap: () => context.goNamed('create-team'),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.sports_soccer_rounded,
          color: AppColors.red,
          title: t.player,
          desc: t.playerDesc,
          onTap: () => context.goNamed('join-team'),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final VoidCallback onTap;
  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          AppTextStyles.title(AppColors.darkTextPrimary)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style:
                          AppTextStyles.body(AppColors.darkTextSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.darkTextMuted),
          ],
        ),
      ),
    );
  }
}
