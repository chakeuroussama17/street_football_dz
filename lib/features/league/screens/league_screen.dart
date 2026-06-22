import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/team_providers.dart';
import '../../../core/services/team_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../core/widgets/wilaya_dropdown.dart';
import '../../../l10n/app_localizations.dart';

class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> {
  String? _city; // null = all wilayas

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final standings = ref.watch(standingsProvider(_city));

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.gold, size: 26),
                const SizedBox(width: 8),
                Text(t.leagueTitle, style: AppTextStyles.headline(textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: WilayaDropdown(
              label: t.leagueSubtitle,
              value: _city,
              includeAllOption: true,
              allLabel: t.allWilayas,
              onChanged: (v) => setState(() => _city = v),
            ),
          ),
          Expanded(
            child: standings.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.green)),
              error: (e, _) => Center(
                  child: Text('${t.retry}…',
                      style: AppTextStyles.body(AppColors.darkTextSecondary))),
              data: (rows) {
                if (rows.isEmpty) {
                  return _empty(t);
                }
                return RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: () => ref.refresh(standingsProvider(_city).future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _StandingRow(
                      standing: rows[i],
                      onTap: () => context.pushNamed('team-detail',
                          pathParameters: {'id': rows[i].id}),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppLocalizations t) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.groups_outlined,
                  size: 56, color: AppColors.darkTextMuted),
              const SizedBox(height: 12),
              Text(t.noTeamsYet,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(AppColors.darkTextSecondary)),
            ],
          ),
        ),
      );
}

class _StandingRow extends StatelessWidget {
  final TeamStanding standing;
  final VoidCallback onTap;
  const _StandingRow({required this.standing, required this.onTap});

  Color get _rankColor => switch (standing.rank) {
        1 => AppColors.gold,
        2 => const Color(0xFFB0BEC5),
        3 => const Color(0xFFBC8F4F),
        _ => AppColors.darkTextMuted,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${standing.rank}',
                textAlign: TextAlign.center,
                style: AppTextStyles.title(_rankColor),
              ),
            ),
            const SizedBox(width: 6),
            TeamAvatar(
                name: standing.name, imageUrl: standing.logoUrl, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(standing.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title(AppColors.darkTextPrimary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (standing.ratingCount > 0) ...[
                        StarRating(value: standing.ratingAvg, size: 13),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '${t.statPlayed} ${standing.played}',
                        style: AppTextStyles.label(AppColors.darkTextMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Text('${standing.points}',
                    style: AppTextStyles.headline(AppColors.green)),
                Text(t.pts,
                    style: AppTextStyles.label(AppColors.darkTextMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
