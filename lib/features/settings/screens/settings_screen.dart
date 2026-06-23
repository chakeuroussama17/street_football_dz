import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _section(t.language),
          _radioTile(
            label: t.arabic,
            selected: locale.languageCode == 'ar',
            onTap: () => _setLanguage(ref, 'ar'),
          ),
          _radioTile(
            label: t.french,
            selected: locale.languageCode == 'fr',
            onTap: () => _setLanguage(ref, 'fr'),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout_rounded),
            label: Text(t.signOut),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('${t.appName} · ${t.appVersion} 1.0.0',
                style: AppTextStyles.label(AppColors.darkTextMuted)),
          ),
        ],
      ),
    );
  }

  /// Applies the language now and saves it to the user's profile.
  void _setLanguage(WidgetRef ref, String code) {
    ref.read(localeProvider.notifier).set(Locale(code));
    AuthService.setLanguage(code);
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title,
            style: AppTextStyles.label(AppColors.darkTextSecondary)),
      );

  Widget _radioTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.green : AppColors.darkBorder),
        ),
        child: ListTile(
          title: Text(label,
              style: AppTextStyles.body(AppColors.darkTextPrimary)),
          trailing: selected
              ? const Icon(Icons.check_circle_rounded, color: AppColors.green)
              : const Icon(Icons.radio_button_unchecked,
                  color: AppColors.darkTextMuted),
          onTap: onTap,
        ),
      );

  Future<void> _signOut(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(t.signOutConfirm,
            style: AppTextStyles.title(AppColors.darkTextPrimary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.signOut,
                  style: const TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (ok == true) {
      await AuthService.signOut(); // app-level listener routes to welcome
    }
  }
}
