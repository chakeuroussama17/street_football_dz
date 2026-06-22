import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    // Legacy anon keys are accepted here; the param was renamed from anonKey.
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final prefs = await SharedPreferences.getInstance();
  final initialTheme = ThemeModeNotifier.decode(prefs.getString('theme_mode'));
  final initialLocale = LocaleNotifier.decode(prefs.getString('app_locale'));

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider
            .overrideWith((ref) => ThemeModeNotifier(initialTheme)),
        localeProvider.overrideWith((ref) => LocaleNotifier(initialLocale)),
      ],
      child: const StreetFootballApp(),
    ),
  );
}
