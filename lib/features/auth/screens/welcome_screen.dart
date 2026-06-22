import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';

/// Gen-Z Algerian welcome/hero. Arabic-first (RTL handled by MaterialApp),
/// with a bold flag-coloured gradient backdrop. Swap in a real street-football
/// photo later by dropping it into assets/images and layering it behind.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Vivid flag gradient glow, top-trailing.
          Positioned(
            top: -120,
            right: -80,
            child: _glow(AppColors.green, 320),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: _glow(AppColors.red, 340),
          ),
          // Foreground content.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  _logoBadge()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.85, 0.85)),
                  const SizedBox(height: 28),
                  Text(
                    t.appName,
                    style: AppTextStyles.label(AppColors.gold),
                  ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.1),
                  const SizedBox(height: 8),
                  Text(
                    t.welcomeTitle,
                    style: AppTextStyles.display(AppColors.darkTextPrimary),
                  ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.15),
                  const SizedBox(height: 16),
                  Text(
                    t.welcomeSubtitle,
                    style: AppTextStyles.body(AppColors.darkTextSecondary),
                  ).animate(delay: 400.ms).fadeIn(),
                  const Spacer(flex: 3),
                  CustomButton(
                    label: t.getStarted,
                    icon: Icons.sports_soccer,
                    onPressed: () => context.pushNamed('register'),
                  ).animate(delay: 550.ms).fadeIn().slideY(begin: 0.3),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: t.iHaveAccount,
                    variant: ButtonVariant.ghost,
                    onPressed: () => context.pushNamed('register'),
                  ).animate(delay: 650.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.45), Colors.transparent],
          ),
        ),
      );

  Widget _logoBadge() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientHot,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.sports_soccer, color: Colors.white, size: 40),
      );
}
