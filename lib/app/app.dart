import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/providers/app_settings.dart';
import '../core/providers/notification_providers.dart';
import '../core/providers/session_provider.dart';
import '../core/services/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

export '../core/providers/app_settings.dart';

class StreetFootballApp extends ConsumerStatefulWidget {
  const StreetFootballApp({super.key});

  @override
  ConsumerState<StreetFootballApp> createState() => _StreetFootballAppState();
}

class _StreetFootballAppState extends ConsumerState<StreetFootballApp> {
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // When the session ends (logout / expiry / revoked), reset local session
    // state and bounce to welcome so no screen shows stale "logged-in" data.
    _authSub = AuthService.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedOut) {
        ref.read(userRoleProvider.notifier).state = UserRole.player;
        ref.read(isAdminProvider.notifier).state = false;
        ref.read(myTeamIdProvider.notifier).state = null;
        // Drop the realtime notification stream so the next account doesn't
        // inherit this user's subscription/badge.
        ref.invalidate(notificationStreamProvider);
        // Back to the Arabic default for the next person on this device.
        ref.read(localeProvider.notifier).set(LocaleNotifier.fallback);
        ref.read(routerProvider).goNamed('welcome');
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Street Football DZ',
      debugShowCheckedModeBanner: false,
      // The app is a dark Gen-Z design; lock it to dark for now (light mode
      // would need every screen re-themed).
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
