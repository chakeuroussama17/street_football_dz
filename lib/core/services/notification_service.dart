import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String? body;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.data,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromRow(Map<String, dynamic> r) => AppNotification(
        id: r['id'] as String,
        type: (r['type'] ?? '') as String,
        title: (r['title'] ?? '') as String,
        body: r['body'] as String?,
        data: r['data'] as Map<String, dynamic>?,
        read: (r['read'] ?? false) as bool,
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      );

  String? get gameId => data?['game_id'] as String?;
}

class NotificationService {
  static final _sb = SupabaseService.supabase;

  static Future<List<AppNotification>> fetch() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _sb
        .from('notifications')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(50);
    return (rows as List)
        .map((r) => AppNotification.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  static Future<int> unreadCount() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return 0;
    return _sb
        .from('notifications')
        .count(CountOption.exact)
        .eq('user_id', uid)
        .eq('read', false);
  }

  static Future<void> markAllRead() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    await _sb
        .from('notifications')
        .update({'read': true})
        .eq('user_id', uid)
        .eq('read', false);
  }
}
