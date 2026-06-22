import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => NotificationService.fetch(),
);

final unreadCountProvider = FutureProvider.autoDispose<int>(
  (ref) => NotificationService.unreadCount(),
);
