import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/algeria.dart';
import '../services/game_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import 'star_rating.dart';
import 'team_avatar.dart';

/// Feed card for a posted game: host team (with league rank + rating), format,
/// city, field and kick-off.
class GameCard extends StatelessWidget {
  final GameFeedItem item;
  final VoidCallback onTap;
  const GameCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final g = item.game;
    final df = DateFormat('EEE d MMM · HH:mm', localeCode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner.
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if ((g.photoUrl ?? '').isNotEmpty)
                    CachedNetworkImage(imageUrl: g.photoUrl!, fit: BoxFit.cover)
                  else
                    const DecoratedBox(
                        decoration:
                            BoxDecoration(gradient: AppColors.brandGradientHot)),
                  // Darken for legibility.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xAA000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _chip(t.asideLabel(g.format),
                        Icons.groups_rounded, AppColors.green),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Text(
                      df.format(g.kickoff),
                      style: AppTextStyles.title(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Body.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TeamAvatar(
                      name: item.host.name,
                      imageUrl: item.host.logoUrl,
                      size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.host.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title(
                                AppColors.darkTextPrimary)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (item.hostRank != null) ...[
                              Text('${t.rankHash}${item.hostRank}',
                                  style:
                                      AppTextStyles.label(AppColors.gold)),
                              const SizedBox(width: 8),
                            ],
                            if (item.hostRatingCount > 0)
                              StarRating(value: item.hostRating, size: 13),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.place_rounded,
                              size: 14, color: AppColors.darkTextMuted),
                          const SizedBox(width: 2),
                          Text(Algeria.labelFor(g.city, localeCode),
                              style: AppTextStyles.label(
                                  AppColors.darkTextSecondary)),
                        ],
                      ),
                      if ((g.fieldAddress ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 120,
                          child: Text(g.fieldAddress!,
                              maxLines: 1,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.label(
                                  AppColors.darkTextMuted)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, IconData icon, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(text,
                style: AppTextStyles.label(Colors.white)
                    .copyWith(fontSize: 11)),
          ],
        ),
      );
}
