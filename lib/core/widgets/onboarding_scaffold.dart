import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared layout for the onboarding steps: a full-bleed brand photo darkened by
/// a gradient (so text stays readable), a title + subtitle, and scrollable
/// content. Pass [backgroundAsset] to set the step's hero image.
class OnboardingScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottom;
  final bool showBack;

  /// Asset path of the full-screen background photo (e.g. the street-football
  /// pictures). Falls back to a plain dark background + brand glow when null.
  final String? backgroundAsset;

  const OnboardingScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.bottom,
    this.showBack = true,
    this.backgroundAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: showBack,
      ),
      body: Stack(
        children: [
          // Hero photo or plain dark base.
          if (backgroundAsset != null)
            Positioned.fill(
              child: Image.asset(backgroundAsset!, fit: BoxFit.cover),
            ),
          // Readability scrim: darker at the bottom where the text/buttons sit.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: backgroundAsset != null
                      ? [
                          AppColors.darkBg.withValues(alpha: 0.55),
                          AppColors.darkBg.withValues(alpha: 0.80),
                          AppColors.darkBg.withValues(alpha: 0.97),
                        ]
                      : [AppColors.darkBg, AppColors.darkBg],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Brand glow accent (only when there's no photo, to avoid clutter).
          if (backgroundAsset == null)
            Positioned(
              top: -110,
              right: -70,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x5500C75A), Colors.transparent],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTextStyles.display(
                                AppColors.darkTextPrimary)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 10),
                          Text(subtitle!,
                              style: AppTextStyles.body(
                                  AppColors.darkTextSecondary)),
                        ],
                        const SizedBox(height: 28),
                        ...children,
                      ],
                    ),
                  ),
                ),
                if (bottom != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: bottom,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
