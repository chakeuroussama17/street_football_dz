import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// A simple ad / announcement shown as a banner on the feed.
class Ad {
  final String id;
  final String title;
  final String? body;
  final String? link;
  final bool active;
  const Ad({
    required this.id,
    required this.title,
    this.body,
    this.link,
    required this.active,
  });

  factory Ad.fromRow(Map<String, dynamic> r) => Ad(
        id: r['id'] as String,
        title: (r['title'] ?? '') as String,
        body: r['body'] as String?,
        link: r['link'] as String?,
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

class AdminService {
  static final _sb = SupabaseService.supabase;

  static Future<AdminStats> fetchStats() async {
    final teams = await _sb.from('teams').count(CountOption.exact);
    final games = await _sb.from('games').count(CountOption.exact);
    final players = await _sb.from('users').count(CountOption.exact);
    return AdminStats(teams: teams, games: games, players: players);
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
    required bool active,
  }) async {
    final data = {
      'title': title,
      'body': body,
      'link': link,
      'active': active,
    };
    if (id == null) {
      await _sb.from('ads').insert(data);
    } else {
      await _sb.from('ads').update(data).eq('id', id);
    }
  }

  static Future<void> deleteAd(String id) async {
    await _sb.from('ads').delete().eq('id', id);
  }
}
