import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Live notifications for the current user (realtime). Kept alive (not
/// autoDispose) so the bell badge stays subscribed across tab switches.
final notificationStreamProvider =
    StreamProvider<List<AppNotification>>((ref) => NotificationService.watch());

/// Live unread count, derived from the realtime stream.
final unreadCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationStreamProvider).valueOrNull;
  if (list == null) return 0;
  return list.where((n) => !n.read).length;
});

/// One-shot fetch fallback (used if realtime is unavailable).
final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => NotificationService.fetch(),
);
