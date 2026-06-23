import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/game_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/services/game_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/match_rules.dart';
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

        // Split into Live now / Upcoming / Finished, each newest-first by kickoff.
        final now = DateTime.now();
        final live = <MatchGame>[];
        final upcoming = <MatchGame>[];
        final finished = <MatchGame>[];
        for (final m in list) {
          final g = m.game;
          switch (matchPhase(
              status: g.status,
              kickoff: g.kickoff,
              endTime: g.endTime,
              now: now)) {
            case MatchPhase.live:
              live.add(m);
            case MatchPhase.upcoming:
              upcoming.add(m);
            case MatchPhase.finished:
              finished.add(m);
          }
        }
        // Upcoming reads best soonest-first; the others newest-first.
        upcoming.sort((a, b) => a.game.kickoff.compareTo(b.game.kickoff));

        final children = <Widget>[];
        void section(String title, List<MatchGame> games, {bool live = false}) {
          if (games.isEmpty) return;
          children.add(_SectionHeader(title: title, count: games.length, live: live));
          for (final m in games) {
            children.add(Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MatchTile(match: m, isCreated: isCreated),
            ));
          }
        }

        section(t.sectionLive, live, live: true);
        section(t.sectionUpcoming, upcoming);
        section(t.sectionFinished, finished);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: children,
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool live;
  const _SectionHeader(
      {required this.title, required this.count, this.live = false});

  @override
  Widget build(BuildContext context) {
    final color = live ? AppColors.red : AppColors.darkTextSecondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
      child: Row(
        children: [
          if (live) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.red, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
          ],
          Text(title.toUpperCase(),
              style: AppTextStyles.label(color)
                  .copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: AppTextStyles.label(color)
                    .copyWith(fontWeight: FontWeight.w700)),
          ),
          const Expanded(
              child: Divider(
                  color: AppColors.darkBorder, indent: 12, endIndent: 0)),
        ],
      ),
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
    final isLive = matchPhase(
            status: g.status,
            kickoff: g.kickoff,
            endTime: g.endTime,
            now: DateTime.now()) ==
        MatchPhase.live;

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
          border: Border.all(
            color: isLive
                ? AppColors.red.withValues(alpha: 0.55)
                : AppColors.darkBorder,
            width: isLive ? 1.5 : 1,
          ),
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
                if (isLive) ...[
                  _LiveTag(label: t.liveTag),
                  const SizedBox(width: 6),
                ],
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

/// Small red "LIVE" pill with a dot — shown on games being played right now.
class _LiveTag extends StatelessWidget {
  final String label;
  const _LiveTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.label(AppColors.red)
                  .copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
