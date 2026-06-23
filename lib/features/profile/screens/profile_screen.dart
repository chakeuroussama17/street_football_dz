import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/algeria.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/notification_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final unread = ref.watch(unreadCountProvider);
    final localeCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          user.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.green)),
            error: (_, _) => Text(t.retry),
            data: (u) {
              if (u == null) return Text(t.retry);
              final roleLabel = isAdmin
                  ? t.adminTitle
                  : (u.isCaptain ? t.captainTag : t.playerTag);
              return Column(
                children: [
                  TeamAvatar(name: u.fullName, imageUrl: u.avatarUrl, size: 88),
                  const SizedBox(height: 12),
                  Text(u.fullName,
                      style:
                          AppTextStyles.headline(AppColors.darkTextPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Text(roleLabel, style: AppTextStyles.label(AppColors.green)),
                  ),
                  const SizedBox(height: 14),
                  _infoRow(Icons.call_rounded, u.phone),
                  if ((u.city ?? '').isNotEmpty)
                    _infoRow(Icons.place_rounded,
                        Algeria.labelFor(u.city, localeCode)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _tile(
            icon: Icons.notifications_rounded,
            label: t.notificationsTitle,
            badge: unread,
            onTap: () => context.pushNamed('notifications'),
          ),
          _tile(
            icon: Icons.settings_rounded,
            label: t.settingsTitle,
            onTap: () => context.pushNamed('settings'),
          ),
          if (isAdmin)
            _tile(
              icon: Icons.admin_panel_settings_rounded,
              label: t.adminPanel,
              onTap: () => context.pushNamed('admin'),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.darkTextMuted),
            const SizedBox(width: 6),
            Text(value,
                style: AppTextStyles.body(AppColors.darkTextSecondary)),
          ],
        ),
      );

  Widget _tile({
    required IconData icon,
    required String label,
    int badge = 0,
    required VoidCallback onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.green),
          title: Text(label,
              style: AppTextStyles.body(AppColors.darkTextPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: const BoxDecoration(
                      color: AppColors.red, shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Text('$badge',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.darkTextMuted),
            ],
          ),
          onTap: onTap,
        ),
      );
}
