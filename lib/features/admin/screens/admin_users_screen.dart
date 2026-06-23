import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/algeria.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final users = ref.watch(adminUsersProvider);
    final localeCode = Localizations.localeOf(context).languageCode;
    final df = DateFormat('d MMM yyyy', localeCode);

    String roleLabel(String r) => switch (r) {
          'admin' => t.adminTitle,
          'captain' => t.captainTag,
          _ => t.playerTag,
        };
    Color roleColor(String r) => switch (r) {
          'admin' => AppColors.red,
          'captain' => AppColors.green,
          _ => AppColors.info,
        };

    return Scaffold(
      appBar: AppBar(title: Text(t.manageUsers)),
      body: users.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (_, _) => Center(child: Text(t.retry)),
        data: (list) {
          if (list.isEmpty) {
            return Center(
                child: Text(t.noTeamsYet,
                    style: AppTextStyles.body(AppColors.darkTextSecondary)));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final AdminUser u = list[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    TeamAvatar(name: u.fullName, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.fullName,
                              style: AppTextStyles.title(
                                  AppColors.darkTextPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            '${u.phone}'
                            '${(u.city ?? '').isNotEmpty ? ' · ${Algeria.labelFor(u.city, localeCode)}' : ''}',
                            style: AppTextStyles.label(
                                AppColors.darkTextSecondary),
                          ),
                          Text(t.joinedOn(df.format(u.createdAt)),
                              style:
                                  AppTextStyles.label(AppColors.darkTextMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor(u.role).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(roleLabel(u.role),
                          style: AppTextStyles.label(roleColor(u.role))),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
