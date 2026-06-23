import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final stats = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.adminTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          stats.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.green)),
            error: (_, _) => Text(t.retry),
            data: (s) => Row(
              children: [
                _stat(t.statsTeams, s.teams, Icons.groups_rounded,
                    AppColors.green),
                const SizedBox(width: 10),
                _stat(t.statsGames, s.games, Icons.sports_soccer_rounded,
                    AppColors.gold),
                const SizedBox(width: 10),
                _stat(t.statsPlayers, s.players, Icons.person_rounded,
                    AppColors.info),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _navTile(context, Icons.people_alt_rounded, t.manageUsers,
              'admin-users'),
          const SizedBox(height: 10),
          _navTile(context, Icons.campaign_rounded, t.manageAds, 'admin-ads'),
        ],
      ),
    );
  }

  Widget _navTile(
          BuildContext context, IconData icon, String label, String route) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.green),
          title: Text(label,
              style: AppTextStyles.body(AppColors.darkTextPrimary)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.darkTextMuted),
          onTap: () => context.pushNamed(route),
        ),
      );

  Widget _stat(String label, int value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text('$value',
                  style: AppTextStyles.headline(AppColors.darkTextPrimary)),
              Text(label,
                  style: AppTextStyles.label(AppColors.darkTextMuted)),
            ],
          ),
        ),
      );
}
