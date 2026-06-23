import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/algeria.dart';
import '../../../core/providers/game_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/team_providers.dart';
import '../../../core/services/game_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/match_rules.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const MatchDetailScreen({super.key, required this.id});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  final _host = TextEditingController();
  final _opp = TextEditingController();
  bool _savingScore = false;
  bool _filledScore = false;
  bool _ratePromptShown = false;

  @override
  void dispose() {
    _host.dispose();
    _opp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final match = ref.watch(matchProvider(widget.id));
    final myTeamId = ref.watch(myTeamIdProvider);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(t.statusMatched)),
      body: match.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (_, _) => Center(child: Text(t.retry)),
        data: (m) {
          if (m == null) return Center(child: Text(t.retry));
          final g = m.game;
          final isHost = myTeamId != null && myTeamId == g.hostTeamId;
          final isOpponent = myTeamId != null && myTeamId == g.opponentTeamId;
          final df = DateFormat('EEEE d MMMM · HH:mm', localeCode);

          // Prefill score fields once.
          if (!_filledScore && g.hasScore) {
            _host.text = '${g.hostScore}';
            _opp.text = '${g.oppScore}';
            _filledScore = true;
          }

          // Auto-prompt the visitor to rate once, when eligible.
          if (isOpponent) _maybePromptRating(m, myTeamId);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _vsHeader(t, m),
              const SizedBox(height: 20),
              _infoTile(Icons.event_rounded, t.whenLabel, df.format(g.kickoff)),
              _infoTile(Icons.place_rounded, t.whereLabel,
                  '${Algeria.labelFor(g.city, localeCode)}'
                  '${(g.fieldAddress ?? '').isNotEmpty ? ' · ${g.fieldAddress}' : ''}'),
              _infoTile(
                  Icons.groups_rounded, t.gameFormat, t.asideLabel(g.format)),
              if ((g.details ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                _box(Text(g.details!,
                    style: AppTextStyles.body(AppColors.darkTextPrimary))),
              ],

              // Contact the other side.
              if (isHost || isOpponent) ...[
                const SizedBox(height: 12),
                _contactTile(t, isHost),
              ],

              const SizedBox(height: 20),
              // Result entry (host) / pending (visitor).
              if (isHost) _hostResultSection(t, m),
              if (isOpponent && !g.hasScore)
                _box(Row(children: [
                  const Icon(Icons.hourglass_empty_rounded,
                      color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(t.resultPending,
                          style: AppTextStyles.body(
                              AppColors.darkTextSecondary))),
                ])),

              // Rating (visitor).
              if (isOpponent) ...[
                const SizedBox(height: 16),
                _ratingSection(t, m, myTeamId),
              ],

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.pushNamed('team-detail',
                          pathParameters: {'id': g.hostTeamId}),
                      icon: const Icon(Icons.shield_rounded, size: 18),
                      label:
                          Text(m.host.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  if (m.opponent != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.pushNamed('team-detail',
                            pathParameters: {'id': m.opponent!.id}),
                        icon: const Icon(Icons.shield_outlined, size: 18),
                        label: Text(m.opponent!.name,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _vsHeader(AppLocalizations t, MatchGame m) {
    final g = m.game;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green.withValues(alpha: 0.16),
            AppColors.red.withValues(alpha: 0.12),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          _side(m.host.name, m.host.logoUrl),
          Column(
            children: [
              g.hasScore
                  ? Text('${g.hostScore} - ${g.oppScore}',
                      style: AppTextStyles.display(AppColors.darkTextPrimary))
                  : Text(t.vs,
                      style:
                          AppTextStyles.headline(AppColors.darkTextMuted)),
              const SizedBox(height: 6),
              StatusChip(status: g.status),
            ],
          ),
          _side(m.opponent?.name ?? '—', m.opponent?.logoUrl),
        ],
      ),
    );
  }

  Widget _hostResultSection(AppLocalizations t, MatchGame m) {
    final g = m.game;
    final eligible = canEnterScore(g.status);
    if (!eligible && !g.hasScore) {
      return _box(Row(children: [
        const Icon(Icons.schedule_rounded,
            color: AppColors.darkTextMuted, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(t.afterGameEnds,
                style: AppTextStyles.body(AppColors.darkTextSecondary))),
      ]));
    }
    return _box(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(g.hasScore ? t.editResult : t.enterResult,
            style: AppTextStyles.title(AppColors.darkTextPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _scoreField(m.host.name, _host)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('-',
                  style: TextStyle(
                      color: AppColors.darkTextMuted, fontSize: 22)),
            ),
            Expanded(child: _scoreField(m.opponent?.name ?? '', _opp)),
          ],
        ),
        const SizedBox(height: 14),
        CustomButton(
          label: t.saveResult,
          icon: Icons.scoreboard_rounded,
          isLoading: _savingScore,
          onPressed: _savingScore ? null : () => _saveScore(t, m),
        ),
      ],
    ));
  }

  Widget _scoreField(String teamName, TextEditingController c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(teamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label(AppColors.darkTextSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: AppTextStyles.headline(AppColors.darkTextPrimary),
            decoration: InputDecoration(
              hintText: '0',
              filled: true,
              fillColor: AppColors.darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.darkBorder),
              ),
            ),
          ),
        ],
      );

  Future<void> _saveScore(AppLocalizations t, MatchGame m) async {
    final h = int.tryParse(_host.text);
    final o = int.tryParse(_opp.text);
    if (h == null || o == null) {
      _snack(t.fieldRequired);
      return;
    }
    setState(() => _savingScore = true);
    try {
      await GameService.enterScore(
        gameId: m.game.id,
        hostScore: h,
        oppScore: o,
        opponentCaptainId: m.opponent?.captainId,
      );
      ref.invalidate(matchProvider(widget.id));
      ref.invalidate(standingsProvider(null));
      final myTeamId = ref.read(myTeamIdProvider);
      if (myTeamId != null) ref.invalidate(createdGamesProvider(myTeamId));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.resultSaved)));
    } finally {
      if (mounted) setState(() => _savingScore = false);
    }
  }

  Widget _ratingSection(AppLocalizations t, MatchGame m, String myTeamId) {
    final ratingAsync = ref.watch(myRatingProvider((m.game.id, myTeamId)));
    return ratingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (stars) {
        if (stars != null) {
          return _box(Row(children: [
            const Icon(Icons.star_rounded, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(t.youRated(stars),
                style: AppTextStyles.body(AppColors.darkTextPrimary)),
          ]));
        }
        final eligible =
            canRate(status: m.game.status, alreadyRated: false);
        if (!eligible) return const SizedBox.shrink();
        return _box(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.rateHostCta,
                style: AppTextStyles.title(AppColors.darkTextPrimary)),
            const SizedBox(height: 12),
            Center(
              child: CustomButton(
                label: t.rateHostCta,
                icon: Icons.star_rounded,
                onPressed: () => _openRateDialog(t, m, myTeamId),
              ),
            ),
          ],
        ));
      },
    );
  }

  void _maybePromptRating(MatchGame m, String? myTeamId) {
    if (_ratePromptShown || myTeamId == null) return;
    final ratingAsync = ref.read(myRatingProvider((m.game.id, myTeamId)));
    final stars = ratingAsync.valueOrNull;
    final loaded = ratingAsync.hasValue;
    if (!loaded) return;
    final eligible = canRate(status: m.game.status, alreadyRated: stars != null);
    if (!eligible) return;
    _ratePromptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        _openRateDialog(t, m, myTeamId);
      }
    });
  }

  Future<void> _openRateDialog(
      AppLocalizations t, MatchGame m, String myTeamId) async {
    var stars = 0;
    final submitted = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: Text(t.rateHostTitle(m.host.name),
              style: AppTextStyles.title(AppColors.darkTextPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.rateHostBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(AppColors.darkTextSecondary)),
              const SizedBox(height: 16),
              StarPicker(
                  value: stars,
                  onChanged: (v) => setLocal(() => stars = v)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(t.cancel)),
            TextButton(
              onPressed:
                  stars == 0 ? null : () => Navigator.pop(ctx, stars),
              child: Text(t.submitRating,
                  style: TextStyle(
                      color: stars == 0
                          ? AppColors.darkTextMuted
                          : AppColors.green)),
            ),
          ],
        ),
      ),
    );
    if (submitted == null || submitted == 0) return;
    await GameService.rateHost(
      gameId: m.game.id,
      raterTeamId: myTeamId,
      ratedTeamId: m.game.hostTeamId,
      stars: submitted,
    );
    ref.invalidate(myRatingProvider((m.game.id, myTeamId)));
    ref.invalidate(teamStandingProvider(m.game.hostTeamId));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.ratingSaved)));
  }

  Widget _contactTile(AppLocalizations t, bool isHost) {
    final phoneAsync = ref.watch(contactPhoneProvider((widget.id, isHost)));
    return _box(Row(children: [
      const Icon(Icons.call_rounded, color: AppColors.green, size: 18),
      const SizedBox(width: 10),
      Text('${t.contactLabel}: ',
          style: AppTextStyles.label(AppColors.darkTextSecondary)),
      Expanded(
        child: phoneAsync.when(
          loading: () => Text('…',
              style: AppTextStyles.body(AppColors.darkTextMuted)),
          error: (_, _) => Text(t.noContact,
              style: AppTextStyles.body(AppColors.darkTextMuted)),
          data: (phone) => Text(phone ?? t.noContact,
              style: AppTextStyles.body(AppColors.darkTextPrimary)),
        ),
      ),
      if (phoneAsync.valueOrNull != null)
        IconButton(
          onPressed: () => _call(phoneAsync.value),
          icon: const Icon(Icons.phone_forwarded_rounded,
              color: AppColors.green),
        ),
    ]));
  }

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Widget _side(String name, String? logo) => Expanded(
        child: Column(
          children: [
            TeamAvatar(name: name, imageUrl: logo, size: 64),
            const SizedBox(height: 8),
            Text(name,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: AppTextStyles.title(AppColors.darkTextPrimary)),
          ],
        ),
      );

  Widget _box(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: child,
      );

  Widget _infoTile(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.green),
            const SizedBox(width: 10),
            Text('$label: ',
                style: AppTextStyles.label(AppColors.darkTextSecondary)),
            Expanded(
              child: Text(value,
                  style: AppTextStyles.body(AppColors.darkTextPrimary)),
            ),
          ],
        ),
      );

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.red));
}
