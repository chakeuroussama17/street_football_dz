import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared layout for the onboarding steps: dark background with a subtle brand
/// glow, a title + subtitle, and scrollable content.
class OnboardingScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottom;
  final bool showBack;

  const OnboardingScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.bottom,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: showBack,
      ),
      body: Stack(
        children: [
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
