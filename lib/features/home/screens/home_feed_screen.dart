import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/providers/game_providers.dart';
import '../../../core/providers/notification_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/game_card.dart';
import '../../../core/widgets/wilaya_dropdown.dart';
import '../../../l10n/app_localizations.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  FeedFilters _filters = const FeedFilters();

  void _post() {
    final t = AppLocalizations.of(context);
    final role = ref.read(userRoleProvider);
    if (role != UserRole.captain) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.onlyCaptainsPost)));
      return;
    }
    context.pushNamed('create-game');
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _filters.day ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.green, surface: AppColors.darkSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _filters = _filters.copyWith(day: picked));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final role = ref.watch(userRoleProvider);
    final feed = ref.watch(feedProvider(_filters));
    final localeCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(t.feedTitle,
                      style:
                          AppTextStyles.headline(AppColors.darkTextPrimary)),
                ),
                const _NotificationBell(),
                if (role == UserRole.captain)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _post,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(t.postGame),
                  ),
              ],
            ),
          ),
          // Filters.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                WilayaDropdown(
                  label: t.cityWilaya,
                  value: _filters.city,
                  includeAllOption: true,
                  allLabel: t.allWilayas,
                  onChanged: (v) =>
                      setState(() => _filters = _filters.copyWith(city: v)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _formatDropdown(t)),
                    const SizedBox(width: 10),
                    Expanded(child: _dayButton(t, localeCode)),
                  ],
                ),
              ],
            ),
          ),
          const _AdBanner(),
          Expanded(
            child: feed.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.green)),
              error: (_, _) => Center(child: Text(t.retry)),
              data: (items) {
                if (items.isEmpty) return _empty(t);
                return RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: () => ref.refresh(feedProvider(_filters).future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => GameCard(
                      item: items[i],
                      onTap: () => context.pushNamed('game-detail',
                          pathParameters: {'id': items[i].game.id}),
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

  Widget _formatDropdown(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.filterFormat,
            style: AppTextStyles.label(AppColors.darkTextSecondary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String?>(
          initialValue: _filters.format,
          isExpanded: true,
          dropdownColor: AppColors.darkSurface,
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(t.anyFormat)),
            for (final f in ['5', '7', '9', '11'])
              DropdownMenuItem<String?>(
                  value: f, child: Text(t.asideLabel(f))),
          ],
          onChanged: (v) =>
              setState(() => _filters = _filters.copyWith(format: v)),
        ),
      ],
    );
  }

  Widget _dayButton(AppLocalizations t, String localeCode) {
    final hasDay = _filters.day != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.filterDay,
            style: AppTextStyles.label(AppColors.darkTextSecondary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickDay,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 50,
            padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_rounded,
                    size: 18, color: AppColors.darkTextMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasDay
                        ? DateFormat('d MMM', localeCode).format(_filters.day!)
                        : t.anyDay,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: hasDay
                            ? AppColors.darkTextPrimary
                            : AppColors.darkTextMuted),
                  ),
                ),
                if (hasDay)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(
                        () => _filters = _filters.copyWith(day: null)),
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.darkTextMuted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _empty(AppLocalizations t) => LayoutBuilder(
        builder: (_, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: c.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 56, color: AppColors.darkTextMuted),
                    const SizedBox(height: 12),
                    Text(t.noGames,
                        textAlign: TextAlign.center,
                        style:
                            AppTextStyles.body(AppColors.darkTextSecondary)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// Bell icon with an unread-count badge, routing to the notifications screen.
class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return IconButton(
      onPressed: () => context.pushNamed('notifications'),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        backgroundColor: AppColors.red,
        child: const Icon(Icons.notifications_rounded,
            color: AppColors.darkTextPrimary),
      ),
    );
  }
}

/// Shows the most recent active admin ad as a tappable banner.
class _AdBanner extends ConsumerWidget {
  const _AdBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(activeAdsProvider).valueOrNull;
    if (ads == null || ads.isEmpty) return const SizedBox.shrink();
    final Ad ad = ads.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        onTap: () async {
          final link = ad.link;
          if (link != null && link.isNotEmpty) {
            final uri = Uri.tryParse(link);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: (ad.imageUrl ?? '').isNotEmpty
            ? _imageBanner(ad)
            : _textBanner(ad),
      ),
    );
  }

  Widget _textBanner(Ad ad) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title, style: AppTextStyles.title(Colors.white)),
                  if ((ad.body ?? '').isNotEmpty)
                    Text(ad.body!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label(Colors.white)),
                ],
              ),
            ),
            if ((ad.link ?? '').isNotEmpty)
              const Icon(Icons.open_in_new_rounded,
                  color: Colors.white, size: 18),
          ],
        ),
      );

  Widget _imageBanner(Ad ad) => SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: ad.imageUrl!, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ad.title, style: AppTextStyles.title(Colors.white)),
                  if ((ad.body ?? '').isNotEmpty)
                    Text(ad.body!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label(Colors.white)),
                ],
              ),
            ),
          ],
        ),
      );
}
