import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/algeria.dart';
import '../../../core/providers/team_providers.dart';
import '../../../core/services/team_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class TeamDetailScreen extends ConsumerWidget {
  final String id;
  const TeamDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final team = ref.watch(teamProvider(id));
    final standing = ref.watch(teamStandingProvider(id));
    final roster = ref.watch(rosterProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text(team.valueOrNull?.name ?? '')),
      body: team.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (_, _) => Center(child: Text(t.retry)),
        data: (team) {
          if (team == null) return Center(child: Text(t.retry));
          final localeCode = Localizations.localeOf(context).languageCode;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _header(context, team, standing.valueOrNull, localeCode),
              const SizedBox(height: 20),
              _statsRow(t, standing.valueOrNull),
              if (team.ageRangeLabel.isNotEmpty) ...[
                const SizedBox(height: 20),
                _infoTile(
                    Icons.cake_rounded, t.ageRangeTitle, team.ageRangeLabel),
              ],
              if ((team.details ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(team.details!,
                    style: AppTextStyles.body(AppColors.darkTextSecondary)),
              ],
              const SizedBox(height: 24),
              Text(t.rosterTitle,
                  style: AppTextStyles.title(AppColors.darkTextPrimary)),
              const SizedBox(height: 8),
              roster.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.green)),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (members) => Column(
                  children: [for (final m in members) _memberTile(t, m)],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, Team team, TeamStanding? s,
      String localeCode) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green.withValues(alpha: 0.18),
            AppColors.red.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          TeamAvatar(name: team.name, imageUrl: team.logoUrl, size: 84),
          const SizedBox(height: 12),
          Text(team.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline(AppColors.darkTextPrimary)),
          if ((team.city ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(Algeria.labelFor(team.city, localeCode),
                style: AppTextStyles.body(AppColors.darkTextSecondary)),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bigStat('${t.rankHash}${s?.rank ?? '-'}', t.leagueTitle),
              _divider(),
              _bigStat('${s?.points ?? 0}', t.pts),
              _divider(),
              Column(
                children: [
                  if ((s?.ratingCount ?? 0) > 0)
                    StarRating(value: s!.ratingAvg, size: 16)
                  else
                    Text('—', style: AppTextStyles.title(AppColors.darkTextMuted)),
                  const SizedBox(height: 4),
                  Text(t.ratingLabel,
                      style: AppTextStyles.label(AppColors.darkTextMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigStat(String value, String label) => Column(
        children: [
          Text(value, style: AppTextStyles.headline(AppColors.darkTextPrimary)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.label(AppColors.darkTextMuted)),
        ],
      );

  Widget _divider() => Container(
      width: 1, height: 34, color: AppColors.darkBorder);

  Widget _statsRow(AppLocalizations t, TeamStanding? s) => Row(
        children: [
          _statTile(t.statPlayed, s?.played ?? 0, AppColors.darkTextPrimary),
          const SizedBox(width: 8),
          _statTile(t.statWon, s?.wins ?? 0, AppColors.win),
          const SizedBox(width: 8),
          _statTile(t.statDrawn, s?.draws ?? 0, AppColors.draw),
          const SizedBox(width: 8),
          _statTile(t.statLost, s?.losses ?? 0, AppColors.loss),
        ],
      );

  Widget _statTile(String label, int value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: [
              Text('$value', style: AppTextStyles.title(color)),
              const SizedBox(height: 2),
              Text(label,
                  style: AppTextStyles.label(AppColors.darkTextMuted)),
            ],
          ),
        ),
      );

  Widget _infoTile(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, color: AppColors.darkTextMuted, size: 18),
          const SizedBox(width: 8),
          Text('$label: ',
              style: AppTextStyles.label(AppColors.darkTextSecondary)),
          Text(value, style: AppTextStyles.body(AppColors.darkTextPrimary)),
        ],
      );

  Widget _memberTile(AppLocalizations t, TeamMember m) {
    final isCaptain = m.role == 'captain';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          TeamAvatar(name: m.fullName, imageUrl: m.avatarUrl, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(m.fullName,
                style: AppTextStyles.body(AppColors.darkTextPrimary)),
          ),
          if (m.age != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('${m.age}',
                  style: AppTextStyles.label(AppColors.darkTextMuted)),
            ),
          if (isCaptain)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(t.captainTag,
                  style: AppTextStyles.label(AppColors.green)),
            ),
        ],
      ),
    );
  }
}
