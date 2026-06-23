import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';

/// Enhanced Gen-Z Algerian welcome screen (Picture 1: street football action).
/// Dark overlay + brand gradient accent with animated buttons.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Full-bleed hero photo (street-football action).
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_welcome.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark gradient scrim so the logo, title and buttons stay readable.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.darkBg.withValues(alpha: 0.45),
                    AppColors.darkBg.withValues(alpha: 0.75),
                    AppColors.darkBg.withValues(alpha: 0.97),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Animated accent glows (brand colors)
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

          // Foreground content (centered, bold)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Logo badge
                  _logoBadge()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1)),

                  const SizedBox(height: 40),

                  // Title + subtitle
                  Text(
                    t.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display(AppColors.darkTextPrimary),
                  )
                      .animate(delay: 200.ms)
                      .fadeIn()
                      .slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  Text(
                    t.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(AppColors.darkTextSecondary),
                  )
                      .animate(delay: 350.ms)
                      .fadeIn()
                      .slideY(begin: 0.15),

                  const Spacer(flex: 2),

                  // CTA buttons with staggered animation
                  CustomButton(
                    label: t.getStarted,
                    icon: Icons.sports_soccer,
                    onPressed: () => context.pushNamed('register'),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn()
                      .slideY(begin: 0.3),

                  const SizedBox(height: 12),

                  CustomButton(
                    label: t.iHaveAccount,
                    variant: ButtonVariant.ghost,
                    onPressed: () => context.pushNamed('login'),
                  )
                      .animate(delay: 600.ms)
                      .fadeIn()
                      .slideY(begin: 0.3),

                  const SizedBox(height: 32),
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
            colors: [color.withValues(alpha: 0.5), Colors.transparent],
          ),
        ),
      );

  Widget _logoBadge() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientHot,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 2,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: AppColors.red.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.sports_soccer,
            color: Colors.white, size: 48),
      );
}
