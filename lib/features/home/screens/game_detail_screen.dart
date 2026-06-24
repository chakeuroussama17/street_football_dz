import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/algeria.dart';
import '../../../core/providers/game_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/game_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/reviews_section.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class GameDetailScreen extends ConsumerWidget {
  final String id;
  const GameDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final gameAsync = ref.watch(gameProvider(id));
    final myTeamId = ref.watch(myTeamIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text(gameAsync.valueOrNull?.host.name ?? '')),
      body: gameAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (_, _) => Center(child: Text(t.retry)),
        data: (item) {
          if (item == null) return Center(child: Text(t.retry));
          return _Body(item: item, myTeamId: myTeamId);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final GameFeedItem item;
  final String? myTeamId;
  const _Body({required this.item, required this.myTeamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final g = item.game;
    final df = DateFormat('EEEE d MMMM · HH:mm', localeCode);
    final isMine = myTeamId != null && myTeamId == g.hostTeamId;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              if ((g.photoUrl ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                      imageUrl: g.photoUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),

              // Host team card.
              InkWell(
                onTap: () => context.pushNamed('team-detail',
                    pathParameters: {'id': g.hostTeamId}),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    children: [
                      TeamAvatar(
                          name: item.host.name,
                          imageUrl: item.host.logoUrl,
                          size: 50),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.hostTeamLabel,
                                style: AppTextStyles.label(
                                    AppColors.darkTextMuted)),
                            Text(item.host.name,
                                style: AppTextStyles.title(
                                    AppColors.darkTextPrimary)),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                if (item.hostRank != null) ...[
                                  Text('${t.rankHash}${item.hostRank}',
                                      style: AppTextStyles.label(
                                          AppColors.gold)),
                                  const SizedBox(width: 8),
                                ],
                                if (item.hostRatingCount > 0)
                                  StarRating(
                                      value: item.hostRating, size: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.darkTextMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _infoTile(Icons.groups_rounded, t.gameFormat,
                  t.asideLabel(g.format)),
              _infoTile(Icons.event_rounded, t.whenLabel, df.format(g.kickoff)),
              _whereTile(
                t,
                '${Algeria.labelFor(g.city, localeCode)}'
                '${(g.fieldAddress ?? '').isNotEmpty ? ' · ${g.fieldAddress}' : ''}',
                g.lat,
                g.lng,
              ),

              if ((g.details ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Text(g.details!,
                      style: AppTextStyles.body(AppColors.darkTextPrimary)),
                ),
              ],
              const SizedBox(height: 20),
              // The host team's reviews, so you know who you'd be playing.
              ReviewsSection(teamId: g.hostTeamId),
            ],
          ),
        ),
        _bottomAction(context, ref, t, isMine),
      ],
    );
  }

  Widget _bottomAction(
      BuildContext context, WidgetRef ref, AppLocalizations t, bool isMine) {
    if (isMine) {
      return _banner(t.thisIsYourGame, AppColors.gold);
    }
    if (myTeamId == null) {
      return _banner(t.needTeamToBid, AppColors.darkTextSecondary);
    }
    final myBid = ref.watch(myBidProvider((item.game.id, myTeamId!)));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: myBid.when(
        loading: () => const SizedBox(
            height: 52,
            child: Center(
                child: CircularProgressIndicator(color: AppColors.green))),
        error: (_, _) => _bidButton(context, ref, t),
        data: (bid) {
          if (bid != null && bid.isPending) {
            return _pendingBanner(t);
          }
          return _bidButton(context, ref, t);
        },
      ),
    );
  }

  Widget _bidButton(BuildContext context, WidgetRef ref, AppLocalizations t) =>
      CustomButton(
        label: t.placeBid,
        icon: Icons.handshake_rounded,
        onPressed: () => _openBidSheet(context, ref),
      );

  Widget _pendingBanner(AppLocalizations t) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_top_rounded, color: AppColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.alreadyBidTitle,
                      style: AppTextStyles.title(AppColors.darkTextPrimary)),
                  Text(t.alreadyBidBody,
                      style: AppTextStyles.label(AppColors.darkTextSecondary)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _banner(String text, Color color) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(AppColors.darkTextPrimary)),
      );

  Future<void> _openBidSheet(BuildContext context, WidgetRef ref) async {
    // Prefill the bidder's contact with their registered phone.
    final me = await AuthService.currentAppUser();
    final defaultPhone = me?.phone ?? '';
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _PlaceBidSheet(
        gameId: item.game.id,
        teamId: myTeamId!,
        defaultPhone: defaultPhone,
        onSent: () {
          ref.invalidate(myBidProvider((item.game.id, myTeamId!)));
        },
      ),
    );
  }

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

  /// Location row — tappable when the game has map coordinates, opening the
  /// exact spot in the maps app so a bidding team can scout it.
  Widget _whereTile(
      AppLocalizations t, String value, double? lat, double? lng) {
    final hasCoords = lat != null && lng != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: hasCoords ? () => _openMaps(lat, lng) : null,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.place_rounded, size: 18, color: AppColors.green),
            const SizedBox(width: 10),
            Text('${t.whereLabel}: ',
                style: AppTextStyles.label(AppColors.darkTextSecondary)),
            Expanded(
              child: Text(value,
                  style: AppTextStyles.body(AppColors.darkTextPrimary)),
            ),
            if (hasCoords) ...[
              const SizedBox(width: 8),
              const Icon(Icons.map_rounded, size: 18, color: AppColors.green),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _PlaceBidSheet extends StatefulWidget {
  final String gameId;
  final String teamId;
  final String defaultPhone;
  final VoidCallback onSent;
  const _PlaceBidSheet({
    required this.gameId,
    required this.teamId,
    required this.defaultPhone,
    required this.onSent,
  });

  @override
  State<_PlaceBidSheet> createState() => _PlaceBidSheetState();
}

class _PlaceBidSheetState extends State<_PlaceBidSheet> {
  final _message = TextEditingController();
  late final _phone = TextEditingController(text: widget.defaultPhone);
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = AppLocalizations.of(context);
    if (_message.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t.fieldRequired), backgroundColor: AppColors.red));
      return;
    }
    setState(() => _sending = true);
    try {
      await GameService.placeBid(
        gameId: widget.gameId,
        bidderTeamId: widget.teamId,
        message: _message.text.trim(),
        phone: _phone.text.trim(),
      );
      widget.onSent();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.bidSent)));
    } on GameFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.red));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, 18 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(t.placeBid,
              style: AppTextStyles.headline(AppColors.darkTextPrimary)),
          const SizedBox(height: 16),
          CustomInput(
            label: t.bidMessage,
            hint: t.bidMessageHint,
            controller: _message,
            maxLines: 3,
            maxLength: 220,
          ),
          const SizedBox(height: 12),
          CustomInput(
            label: t.bidPhone,
            controller: _phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          CustomButton(
            label: t.sendBid,
            icon: Icons.send_rounded,
            isLoading: _sending,
            onPressed: _sending ? null : _send,
          ),
        ],
      ),
    );
  }
}
