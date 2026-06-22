import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/providers/session_provider.dart';
import '../core/services/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

/// Holds the chosen theme mode and persists it app-wide. Defaults to dark
/// (the Gen-Z look). The initial value is loaded in main() (no flash).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(super.initial);

  static const _key = 'theme_mode';

  static ThemeMode decode(String? saved) => switch (saved) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark, // default
      };

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ThemeMode.dark),
);

/// Holds the chosen UI language and persists it app-wide. Defaults to **Arabic**
/// (this is an Algerian app); the user can switch to French in Settings.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.initial);

  static const _key = 'app_locale';
  static const fallback = Locale('ar'); // Arabic by default

  /// Languages offered in the picker, in order.
  static const supported = [Locale('ar'), Locale('fr')];

  static Locale decode(String? code) =>
      (code == null || code.isEmpty) ? fallback : Locale(code);

  Future<void> set(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(LocaleNotifier.fallback),
);

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
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Street Football DZ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
