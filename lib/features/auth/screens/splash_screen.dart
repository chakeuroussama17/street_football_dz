import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';

/// Decides where to send the user on launch:
///  - no session            → welcome
///  - session, no profile    → sign out + welcome (restart registration)
///  - session, no team yet   → role choice
///  - session + team         → home
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      context.goNamed('welcome');
      return;
    }
    final me = await AuthService.currentAppUser();
    if (!mounted) return;
    if (me == null) {
      // Signed in but no profile (bailed mid-onboarding) → restart cleanly.
      await AuthService.signOut();
      if (mounted) context.goNamed('welcome');
      return;
    }
    applySessionStateW(ref, me);
    if (me.hasTeam) {
      context.goNamed('home');
    } else {
      ref.read(onboardingDraftProvider.notifier).state = OnboardingDraft(
        fullName: me.fullName,
        dateOfBirth: me.dateOfBirth ?? DateTime(2000),
        city: me.city ?? '',
        phone: me.phone,
      );
      context.goNamed('role-choice');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(color: AppColors.green),
        ),
      ),
    );
  }
}
