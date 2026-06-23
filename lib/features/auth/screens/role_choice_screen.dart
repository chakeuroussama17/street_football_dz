import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// Role choice (Picture 2: captain pointing vs player running).
/// Bold, polarized cards with animation. Captain = green/leader, Player = red/action.
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
        Text(
          t.roleTitle,
          style: AppTextStyles.headline(AppColors.darkTextPrimary),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1),
        const SizedBox(height: 8),
        Text(
          t.roleSubtitle,
          style: AppTextStyles.body(AppColors.darkTextSecondary),
        )
            .animate(delay: 100.ms)
            .fadeIn(),
        const SizedBox(height: 32),
        _RoleCard(
          icon: Icons.shield_rounded,
          color: AppColors.green,
          title: t.captain,
          desc: t.captainDesc,
          onTap: () => context.goNamed('create-team'),
          isLeft: true,
        )
            .animate(delay: 200.ms)
            .fadeIn()
            .slideX(begin: -0.3),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.sports_soccer_rounded,
          color: AppColors.red,
          title: t.player,
          desc: t.playerDesc,
          onTap: () => context.goNamed('join-team'),
          isLeft: false,
        )
            .animate(delay: 300.ms)
            .fadeIn()
            .slideX(begin: 0.3),
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
  final bool isLeft; // captain (left/green) vs player (right/red)
  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.25),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTextStyles.headline(
                              AppColors.darkTextPrimary)),
                      const SizedBox(height: 6),
                      Text(desc,
                          style: AppTextStyles.body(
                              AppColors.darkTextSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Get started',
                    style: AppTextStyles.label(color)),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded,
                    color: color, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
