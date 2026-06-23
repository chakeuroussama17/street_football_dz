import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>(
  (ref) => AdminService.fetchStats(),
);

final adminUsersProvider = FutureProvider.autoDispose<List<AdminUser>>(
  (ref) => AdminService.fetchUsers(),
);

/// All ads (admin management view).
final adsProvider = FutureProvider.autoDispose<List<Ad>>(
  (ref) => AdminService.fetchAds(),
);

/// Active ads for the feed banner.
final activeAdsProvider = FutureProvider.autoDispose<List<Ad>>(
  (ref) => AdminService.fetchActiveAds(),
);
