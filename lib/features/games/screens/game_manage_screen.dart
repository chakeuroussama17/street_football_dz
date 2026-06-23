import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/algeria.dart';
import '../../../core/providers/game_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/services/game_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class GameManageScreen extends ConsumerWidget {
  final String id;
  const GameManageScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final match = ref.watch(matchProvider(id));
    final bids = ref.watch(gameBidsProvider(id));
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.manageGame),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _cancelGame(context, ref, t),
          ),
        ],
      ),
      body: match.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (_, _) => Center(child: Text(t.retry)),
        data: (m) {
          if (m == null) return Center(child: Text(t.retry));
          final g = m.game;
          final df = DateFormat('EEEE d MMMM · HH:mm', localeCode);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // Summary.
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TeamAvatar(
                            name: m.host.name,
                            imageUrl: m.host.logoUrl,
                            size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(m.host.name,
                              style: AppTextStyles.title(
                                  AppColors.darkTextPrimary)),
                        ),
                        Text(t.asideLabel(g.format),
                            style: AppTextStyles.label(AppColors.green)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _line(Icons.event_rounded, df.format(g.kickoff)),
                    _line(
                        Icons.place_rounded,
                        '${Algeria.labelFor(g.city, localeCode)}'
                        '${(g.fieldAddress ?? '').isNotEmpty ? ' · ${g.fieldAddress}' : ''}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(t.requestsTitle,
                  style: AppTextStyles.title(AppColors.darkTextPrimary)),
              const SizedBox(height: 8),
              bids.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.green)),
                ),
                error: (_, _) => Text(t.retry),
                data: (list) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(t.noBids,
                            style: AppTextStyles.body(
                                AppColors.darkTextSecondary)),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final b in list)
                        _BidCard(
                          bid: b,
                          onPick: () => _pick(context, ref, t, b),
                          onDecline: () => _decline(ref, b),
                          onCall: () => _call(b.bid.phone),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _line(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.darkTextMuted),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: AppTextStyles.label(AppColors.darkTextSecondary))),
          ],
        ),
      );

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _pick(BuildContext context, WidgetRef ref, AppLocalizations t,
      BidView b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(t.pickConfirm(b.team.name),
            style: AppTextStyles.title(AppColors.darkTextPrimary)),
        content: Text(t.pickConfirmBody,
            style: AppTextStyles.body(AppColors.darkTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.pickTeam,
                  style: const TextStyle(color: AppColors.green))),
        ],
      ),
    );
    if (ok != true) return;
    await GameService.acceptBid(b);
    final teamId = ref.read(myTeamIdProvider);
    if (teamId != null) ref.invalidate(createdGamesProvider(teamId));
    ref.invalidate(matchProvider(id));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.opponentPicked)));
    context.pushReplacementNamed('match-detail', pathParameters: {'id': id});
  }

  Future<void> _decline(WidgetRef ref, BidView b) async {
    await GameService.rejectBid(b.bid.id,
        bidderUserId: b.bid.bidderUserId, gameId: b.bid.gameId);
    ref.invalidate(gameBidsProvider(id));
  }

  Future<void> _cancelGame(
      BuildContext context, WidgetRef ref, AppLocalizations t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(t.cancelGameConfirm,
            style: AppTextStyles.title(AppColors.darkTextPrimary)),
        content: Text(t.cancelGameBody,
            style: AppTextStyles.body(AppColors.darkTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.deleteLabel,
                  style: const TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (ok != true) return;
    await GameService.deleteGame(id);
    final teamId = ref.read(myTeamIdProvider);
    if (teamId != null) ref.invalidate(createdGamesProvider(teamId));
    ref.invalidate(feedProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.gameCancelled)));
    context.pop();
  }
}

class _BidCard extends StatelessWidget {
  final BidView bid;
  final VoidCallback onPick;
  final VoidCallback onDecline;
  final VoidCallback onCall;
  const _BidCard({
    required this.bid,
    required this.onPick,
    required this.onDecline,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TeamAvatar(
                  name: bid.team.name, imageUrl: bid.team.logoUrl, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bid.team.name,
                        style: AppTextStyles.title(AppColors.darkTextPrimary)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (bid.rank != null) ...[
                          Text('${t.rankHash}${bid.rank}',
                              style: AppTextStyles.label(AppColors.gold)),
                          const SizedBox(width: 8),
                        ],
                        if (bid.ratingCount > 0)
                          StarRating(value: bid.rating, size: 13),
                      ],
                    ),
                  ],
                ),
              ),
              if (bid.bid.isAccepted)
                Text(t.picked,
                    style: AppTextStyles.label(AppColors.green)),
            ],
          ),
          if ((bid.bid.message ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(bid.bid.message!,
                style: AppTextStyles.body(AppColors.darkTextPrimary)),
          ],
          const SizedBox(height: 6),
          Text('${bid.bidderName} · ${bid.bid.phone ?? ''}',
              style: AppTextStyles.label(AppColors.darkTextMuted)),
          const SizedBox(height: 12),
          if (bid.bid.isPending)
            Row(
              children: [
                IconButton(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_rounded, color: AppColors.green),
                  tooltip: t.call,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                    ),
                    child: Text(t.decline),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: CustomButton(label: t.pickTeam, onPressed: onPick),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
