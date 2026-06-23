import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/game_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import 'star_rating.dart';

/// Shows the reviews left for [teamId] — used on a team's posted games so an
/// opponent can see how the host behaves before requesting to play.
class ReviewsSection extends ConsumerWidget {
  final String teamId;
  const ReviewsSection({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final reviews = ref.watch(teamReviewsProvider(teamId));
    final localeCode = Localizations.localeOf(context).languageCode;
    final df = DateFormat('d MMM yyyy', localeCode);

    return reviews.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.reviews_rounded,
                    size: 18, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('${t.reviewsTitle} (${list.length})',
                    style: AppTextStyles.title(AppColors.darkTextPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            if (list.isEmpty)
              Text(t.noReviews,
                  style: AppTextStyles.body(AppColors.darkTextSecondary))
            else
              for (final r in list)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StarRating(value: r.stars.toDouble(), size: 14),
                          const Spacer(),
                          Text(df.format(r.createdAt),
                              style: AppTextStyles.label(
                                  AppColors.darkTextMuted)),
                        ],
                      ),
                      if ((r.comment ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(r.comment!,
                            style:
                                AppTextStyles.body(AppColors.darkTextPrimary)),
                      ],
                      const SizedBox(height: 4),
                      Text('— ${r.raterName}',
                          style:
                              AppTextStyles.label(AppColors.darkTextSecondary)),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}
