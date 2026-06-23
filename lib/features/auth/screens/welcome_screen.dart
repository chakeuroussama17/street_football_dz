import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';

/// 3-page swipeable intro (Gen-Z Algerian). Each page is a full-bleed street
/// football photo with a short pitch; the last page holds the auth buttons.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLast() => _controller.animateToPage(
        2,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );

  void _next() => _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pages = <_PageData>[
      _PageData(
        image: 'assets/images/onboarding_welcome.png',
        title: t.welcomeTitle,
        body: t.welcomeSubtitle,
      ),
      _PageData(
        image: 'assets/images/onboarding_role.png',
        title: t.onboard2Title,
        body: t.onboard2Body,
      ),
      _PageData(
        image: 'assets/images/onboarding_team.png',
        title: t.onboard3Title,
        body: t.onboard3Body,
      ),
    ];
    final isLast = _page == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Swipeable photo pages.
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _IntroPage(data: pages[i]),
          ),

          // Skip (hidden on the last page).
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: AnimatedOpacity(
                opacity: isLast ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: isLast ? null : _goToLast,
                  child: Text(t.skip,
                      style: AppTextStyles.label(AppColors.darkTextSecondary)),
                ),
              ),
            ),
          ),

          // Bottom controls: dots + Next, or the auth buttons on the last page.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dots(count: pages.length, active: _page),
                    const SizedBox(height: 20),
                    if (isLast)
                      _AuthButtons(t: t)
                    else
                      CustomButton(
                        label: t.next,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _next,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthButtons extends StatelessWidget {
  final AppLocalizations t;
  const _AuthButtons({required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          label: t.getStarted,
          icon: Icons.sports_soccer,
          onPressed: () => context.pushNamed('register'),
        ),
        const SizedBox(height: 12),
        CustomButton(
          label: t.iHaveAccount,
          variant: ButtonVariant.ghost,
          onPressed: () => context.pushNamed('login'),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2);
  }
}

class _PageData {
  final String image;
  final String title;
  final String body;
  const _PageData({required this.image, required this.title, required this.body});
}

class _IntroPage extends StatelessWidget {
  final _PageData data;
  const _IntroPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(data.image, fit: BoxFit.cover),
        // Readability scrim — darkest at the bottom behind the controls.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBg.withValues(alpha: 0.40),
                AppColors.darkBg.withValues(alpha: 0.78),
                AppColors.darkBg.withValues(alpha: 0.98),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 60, 28, 180),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _logoBadge()
                    .animate(key: ValueKey(data.image))
                    .fadeIn(duration: 500.ms)
                    .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1, 1)),
                const SizedBox(height: 28),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display(AppColors.darkTextPrimary),
                )
                    .animate(key: ValueKey('t${data.image}'), delay: 120.ms)
                    .fadeIn()
                    .slideY(begin: 0.2),
                const SizedBox(height: 14),
                Text(
                  data.body,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(AppColors.darkTextSecondary),
                )
                    .animate(key: ValueKey('b${data.image}'), delay: 240.ms)
                    .fadeIn()
                    .slideY(begin: 0.15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _logoBadge() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: 0.45),
              blurRadius: 34,
              spreadRadius: 1,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset('assets/images/logo.png',
              width: 76, height: 76, fit: BoxFit.cover),
        ),
      );
}

/// Page indicator: the active dot stretches and turns green.
class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == active ? 26 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.green
                  : AppColors.darkTextMuted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
