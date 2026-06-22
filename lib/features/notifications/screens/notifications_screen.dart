import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/notification_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark everything read when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.markAllRead();
      if (mounted) {
        ref.invalidate(unreadCountProvider);
        ref.invalidate(notificationsProvider);
      }
    });
  }

  void _open(AppNotification n) {
    final gid = n.gameId;
    if (gid == null) return;
    if (n.type == 'bid_received') {
      context.pushNamed('game-manage', pathParameters: {'id': gid});
    } else {
      context.pushNamed('match-detail', pathParameters: {'id': gid});
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final notifs = ref.watch(notificationsProvider);
    final localeCode = Localizations.localeOf(context).languageCode;
    final df = DateFormat('d MMM · HH:mm', localeCode);

    return Scaffold(
      appBar: AppBar(title: Text(t.notificationsTitle)),
      body: notifs.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (_, _) => Center(child: Text(t.retry)),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_off_rounded,
                      size: 56, color: AppColors.darkTextMuted),
                  const SizedBox(height: 12),
                  Text(t.noNotifications,
                      style: AppTextStyles.body(AppColors.darkTextSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final n = list[i];
              return InkWell(
                onTap: () => _open(n),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sports_soccer_rounded,
                          color: AppColors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title,
                                style: AppTextStyles.title(
                                    AppColors.darkTextPrimary)),
                            if ((n.body ?? '').isNotEmpty)
                              Text(n.body!,
                                  style: AppTextStyles.body(
                                      AppColors.darkTextSecondary)),
                            const SizedBox(height: 4),
                            Text(df.format(n.createdAt),
                                style: AppTextStyles.label(
                                    AppColors.darkTextMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
