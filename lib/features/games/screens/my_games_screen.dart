import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/game_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/services/game_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class MyGamesScreen extends ConsumerWidget {
  const MyGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final teamId = ref.watch(myTeamIdProvider);

    if (teamId == null) {
      return SafeArea(
        child: Center(
          child: Text(t.noTeamYet,
              style: AppTextStyles.body(AppColors.darkTextSecondary)),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(t.myGamesTitle,
                    style: AppTextStyles.headline(AppColors.darkTextPrimary)),
              ),
            ),
            TabBar(
              indicatorColor: AppColors.green,
              labelColor: AppColors.green,
              unselectedLabelColor: AppColors.darkTextSecondary,
              tabs: [Tab(text: t.tabCreated), Tab(text: t.tabJoined)],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _GamesList(
                    provider: createdGamesProvider(teamId),
                    emptyText: t.noCreated,
                    isCreated: true,
                  ),
                  _GamesList(
                    provider: joinedGamesProvider(teamId),
                    emptyText: t.noJoined,
                    isCreated: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesList extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<MatchGame>>> provider;
  final String emptyText;
  final bool isCreated;
  const _GamesList({
    required this.provider,
    required this.emptyText,
    required this.isCreated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final games = ref.watch(provider);
    return games.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.green)),
      error: (_, _) => Center(child: Text(t.retry)),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(emptyText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(AppColors.darkTextSecondary)),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) =>
              _MatchTile(match: list[i], isCreated: isCreated),
        );
      },
    );
  }
}

class _MatchTile extends StatelessWidget {
  final MatchGame match;
  final bool isCreated;
  const _MatchTile({required this.match, required this.isCreated});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final g = match.game;
    final df = DateFormat('EEE d MMM · HH:mm', localeCode);

    void open() {
      if (isCreated && g.isOpen) {
        context.pushNamed('game-manage', pathParameters: {'id': g.id});
      } else {
        context.pushNamed('match-detail', pathParameters: {'id': g.id});
      }
    }

    return InkWell(
      onTap: open,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(df.format(g.kickoff),
                    style: AppTextStyles.label(AppColors.darkTextSecondary)),
                const SizedBox(width: 8),
                Text('· ${t.asideLabel(g.format)}',
                    style: AppTextStyles.label(AppColors.darkTextMuted)),
                const Spacer(),
                StatusChip(status: g.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _teamMini(match.host.name, match.host.logoUrl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: g.hasScore
                      ? Text('${g.hostScore} - ${g.oppScore}',
                          style:
                              AppTextStyles.headline(AppColors.darkTextPrimary))
                      : Text(t.vs,
                          style: AppTextStyles.label(AppColors.darkTextMuted)),
                ),
                match.opponent == null
                    ? Expanded(
                        child: Text(
                          isCreated ? t.waitingBids : '—',
                          style:
                              AppTextStyles.label(AppColors.darkTextSecondary),
                        ),
                      )
                    : _teamMini(match.opponent!.name, match.opponent!.logoUrl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamMini(String name, String? logo) => Expanded(
        child: Row(
          children: [
            TeamAvatar(name: name, imageUrl: logo, size: 30),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(AppColors.darkTextPrimary)),
            ),
          ],
        ),
      );
}
