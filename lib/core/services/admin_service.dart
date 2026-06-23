import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// A simple ad / announcement shown as a banner on the feed.
class Ad {
  final String id;
  final String title;
  final String? body;
  final String? link;
  final String? imageUrl;
  final bool active;
  const Ad({
    required this.id,
    required this.title,
    this.body,
    this.link,
    this.imageUrl,
    required this.active,
  });

  factory Ad.fromRow(Map<String, dynamic> r) => Ad(
        id: r['id'] as String,
        title: (r['title'] ?? '') as String,
        body: r['body'] as String?,
        link: r['link'] as String?,
        imageUrl: r['image_url'] as String?,
        active: (r['active'] ?? true) as bool,
      );
}

class AdminStats {
  final int teams;
  final int games;
  final int players;
  const AdminStats(
      {required this.teams, required this.games, required this.players});
}

/// A registered user, for the admin users list.
class AdminUser {
  final String id;
  final String fullName;
  final String role;
  final String? city;
  final String phone;
  final DateTime createdAt;
  const AdminUser({
    required this.id,
    required this.fullName,
    required this.role,
    this.city,
    required this.phone,
    required this.createdAt,
  });

  factory AdminUser.fromRow(Map<String, dynamic> r) => AdminUser(
        id: r['id'] as String,
        fullName: (r['full_name'] ?? '') as String,
        role: (r['role'] ?? 'player') as String,
        city: r['city'] as String?,
        phone: (r['phone'] ?? '') as String,
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      );
}

class AdminService {
  static final _sb = SupabaseService.supabase;

  static Future<AdminStats> fetchStats() async {
    final teams = await _sb.from('teams').count(CountOption.exact);
    final games = await _sb.from('games').count(CountOption.exact);
    final players = await _sb.from('users').count(CountOption.exact);
    return AdminStats(teams: teams, games: games, players: players);
  }

  /// All registered users (admin view), newest first.
  static Future<List<AdminUser>> fetchUsers() async {
    final rows = await _sb
        .from('users')
        .select('id, full_name, role, city, phone, created_at')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => AdminUser.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// All ads (admin view).
  static Future<List<Ad>> fetchAds() async {
    final rows =
        await _sb.from('ads').select().order('created_at', ascending: false);
    return (rows as List)
        .map((r) => Ad.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Active ads (for the feed banner).
  static Future<List<Ad>> fetchActiveAds() async {
    final rows = await _sb
        .from('ads')
        .select()
        .eq('active', true)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => Ad.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveAd({
    String? id,
    required String title,
    String? body,
    String? link,
    String? imageUrl,
    required bool active,
  }) async {
    final data = {
      'title': title,
      'body': body,
      'link': link,
      'image_url': imageUrl,
      'active': active,
    };
    if (id == null) {
      await _sb.from('ads').insert(data);
    } else {
      await _sb.from('ads').update(data).eq('id', id);
    }
  }

  /// Uploads a promo image to the ad-images bucket and returns its public URL.
  static Future<String> uploadAdImage(Uint8List bytes, String ext) async {
    final uid = SupabaseService.userId;
    if (uid == null) throw Exception('Not signed in');
    final path = '$uid/ad_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _sb.storage.from('ad-images').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
        );
    return _sb.storage.from('ad-images').getPublicUrl(path);
  }

  static Future<void> deleteAd(String id) async {
    await _sb.from('ads').delete().eq('id', id);
  }
}
