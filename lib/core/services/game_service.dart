import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class GameFailure implements Exception {
  final String message;
  GameFailure(this.message);
  @override
  String toString() => message;
}

/// Lightweight team reference embedded in games/bids.
class TeamLite {
  final String id;
  final String name;
  final String? logoUrl;
  final String? city;
  final String? captainId;
  const TeamLite(
      {required this.id,
      required this.name,
      this.logoUrl,
      this.city,
      this.captainId});

  factory TeamLite.fromRow(Map<String, dynamic> r) => TeamLite(
        id: r['id'] as String,
        name: (r['name'] ?? '') as String,
        logoUrl: r['logo_url'] as String?,
        city: r['city'] as String?,
        captainId: r['captain_id'] as String?,
      );
}

/// A posted game.
class Game {
  final String id;
  final String hostTeamId;
  final String hostCaptainId;
  final String format; // '5' | '7' | '9' | '11'
  final String? city;
  final String? fieldAddress;
  final double? lat;
  final double? lng;
  final DateTime kickoff;
  final int durationMinutes;
  final String? photoUrl;
  final String? details;
  final String status; // open | matched | completed | cancelled
  final String? opponentTeamId;
  final String? acceptedBidId;
  final int? hostScore;
  final int? oppScore;
  final DateTime? scoredAt;

  const Game({
    required this.id,
    required this.hostTeamId,
    required this.hostCaptainId,
    required this.format,
    this.city,
    this.fieldAddress,
    this.lat,
    this.lng,
    required this.kickoff,
    required this.durationMinutes,
    this.photoUrl,
    this.details,
    required this.status,
    this.opponentTeamId,
    this.acceptedBidId,
    this.hostScore,
    this.oppScore,
    this.scoredAt,
  });

  factory Game.fromRow(Map<String, dynamic> r) => Game(
        id: r['id'] as String,
        hostTeamId: r['host_team_id'] as String,
        hostCaptainId: r['host_captain_id'] as String,
        format: (r['format'] ?? '5') as String,
        city: r['city'] as String?,
        fieldAddress: r['field_address'] as String?,
        lat: (r['lat'] as num?)?.toDouble(),
        lng: (r['lng'] as num?)?.toDouble(),
        kickoff: DateTime.parse(r['kickoff'] as String).toLocal(),
        durationMinutes: (r['duration_minutes'] ?? 90) as int,
        photoUrl: r['photo_url'] as String?,
        details: r['details'] as String?,
        status: (r['status'] ?? 'open') as String,
        opponentTeamId: r['opponent_team_id'] as String?,
        acceptedBidId: r['accepted_bid_id'] as String?,
        hostScore: r['host_score'] as int?,
        oppScore: r['opp_score'] as int?,
        scoredAt: r['scored_at'] == null
            ? null
            : DateTime.parse(r['scored_at'] as String).toLocal(),
      );

  DateTime get endTime => kickoff.add(Duration(minutes: durationMinutes));
  bool get hasEnded => DateTime.now().isAfter(endTime);
  bool get hasScore => hostScore != null && oppScore != null;
  bool get isOpen => status == 'open';
  bool get isMatched => status == 'matched';
  bool get isCompleted => status == 'completed';
}

/// A feed row: a game + its host team + the host's league rank/rating.
class GameFeedItem {
  final Game game;
  final TeamLite host;
  final int? hostRank;
  final double hostRating;
  final int hostRatingCount;

  const GameFeedItem({
    required this.game,
    required this.host,
    this.hostRank,
    this.hostRating = 0,
    this.hostRatingCount = 0,
  });
}

class GameService {
  static final _sb = SupabaseService.supabase;

  static const _hostJoin =
      'host:teams!games_host_team_id_fkey(id,name,logo_url,city,captain_id)';
  static const _oppJoin =
      'opp:teams!games_opponent_team_id_fkey(id,name,logo_url,city,captain_id)';

  /// The open-games feed, newest kickoff first, with host team + rank/rating.
  /// Excludes the viewer's own team and past games.
  static Future<List<GameFeedItem>> fetchFeed({
    String? city,
    String? format,
    DateTime? day,
    String? excludeTeamId,
  }) async {
    var q = _sb.from('games').select('*, $_hostJoin').eq('status', 'open');
    if (city != null) q = q.eq('city', city);
    if (format != null) q = q.eq('format', format);
    if (day != null) {
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      q = q.gte('kickoff', start.toUtc().toIso8601String());
      q = q.lt('kickoff', end.toUtc().toIso8601String());
    } else {
      // Only upcoming games (from the start of today).
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      q = q.gte('kickoff', todayStart.toUtc().toIso8601String());
    }
    if (excludeTeamId != null) q = q.neq('host_team_id', excludeTeamId);

    final rows = await q.order('kickoff', ascending: true);
    final games = (rows as List).cast<Map<String, dynamic>>();
    final standings = await _standingsFor(
        games.map((g) => g['host_team_id'] as String).toSet());

    return games.map((r) {
      final game = Game.fromRow(r);
      final host = TeamLite.fromRow(r['host'] as Map<String, dynamic>);
      final s = standings[game.hostTeamId];
      return GameFeedItem(
        game: game,
        host: host,
        hostRank: s?.$1,
        hostRating: s?.$2 ?? 0,
        hostRatingCount: s?.$3 ?? 0,
      );
    }).toList();
  }

  /// id → (rank, ratingAvg, ratingCount) for the given team ids.
  static Future<Map<String, (int, double, int)>> _standingsFor(
      Set<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = await _sb
        .from('team_standings')
        .select('id, rank, rating_avg, rating_count')
        .inFilter('id', ids.toList());
    final map = <String, (int, double, int)>{};
    for (final r in (rows as List).cast<Map<String, dynamic>>()) {
      map[r['id'] as String] = (
        (r['rank'] ?? 0) as int,
        ((r['rating_avg'] ?? 0) as num).toDouble(),
        (r['rating_count'] ?? 0) as int,
      );
    }
    return map;
  }

  static Future<GameFeedItem?> fetchGame(String id) async {
    final r = await _sb
        .from('games')
        .select('*, $_hostJoin')
        .eq('id', id)
        .maybeSingle();
    if (r == null) return null;
    final game = Game.fromRow(r);
    final host = TeamLite.fromRow(r['host'] as Map<String, dynamic>);
    final s = (await _standingsFor({game.hostTeamId}))[game.hostTeamId];
    return GameFeedItem(
      game: game,
      host: host,
      hostRank: s?.$1,
      hostRating: s?.$2 ?? 0,
      hostRatingCount: s?.$3 ?? 0,
    );
  }

  /// Creates a game post (host = the captain's team).
  static Future<Game> createGame({
    required String hostTeamId,
    required String format,
    required String city,
    required String fieldAddress,
    double? lat,
    double? lng,
    required DateTime kickoff,
    int durationMinutes = 90,
    String? photoUrl,
    String? details,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw GameFailure('Your session expired — sign in again');
    try {
      final row = await _sb
          .from('games')
          .insert({
            'host_team_id': hostTeamId,
            'host_captain_id': uid,
            'format': format,
            'city': city,
            'field_address': fieldAddress,
            'lat': lat,
            'lng': lng,
            'kickoff': kickoff.toUtc().toIso8601String(),
            'duration_minutes': durationMinutes,
            'photo_url': photoUrl,
            'details': details,
          })
          .select()
          .single();
      return Game.fromRow(row);
    } catch (_) {
      throw GameFailure('Could not post the game — please try again');
    }
  }

  static Future<void> deleteGame(String gameId) async {
    await _sb.from('games').delete().eq('id', gameId);
  }

  static Future<String> uploadPhoto(Uint8List bytes, String ext) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw GameFailure('Your session expired — sign in again');
    final path = '$uid/game_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _sb.storage.from('game-photos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
        );
    return _sb.storage.from('game-photos').getPublicUrl(path);
  }

  // ── Bids ───────────────────────────────────────────────────────────────────

  /// Places a bid for the current user's team on [gameId].
  static Future<void> placeBid({
    required String gameId,
    required String bidderTeamId,
    required String message,
    required String phone,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw GameFailure('Your session expired — sign in again');
    try {
      await _sb.from('bids').insert({
        'game_id': gameId,
        'bidder_team_id': bidderTeamId,
        'bidder_user_id': uid,
        'message': message,
        'phone': phone,
      });
      // Let the host know a team wants to play.
      try {
        final g = await _sb
            .from('games')
            .select('host_captain_id')
            .eq('id', gameId)
            .maybeSingle();
        final hostId = g?['host_captain_id'] as String?;
        if (hostId != null) {
          await _sb.rpc('notify_user', params: {
            'target_user': hostId,
            'n_type': 'bid_received',
            'n_title': 'New request to play 🤝',
            'n_body': 'A team wants to play your game.',
            'n_data': {'game_id': gameId},
          });
        }
      } catch (_) {}
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw GameFailure('Your team has already bid on this game');
      }
      throw GameFailure('Could not send your bid — please try again');
    } catch (_) {
      throw GameFailure('Could not send your bid — please try again');
    }
  }

  /// The current user's team's bid on a game, if any.
  static Future<Bid?> myBidForGame(String gameId, String teamId) async {
    final row = await _sb
        .from('bids')
        .select()
        .eq('game_id', gameId)
        .eq('bidder_team_id', teamId)
        .maybeSingle();
    return row == null ? null : Bid.fromRow(row);
  }

  // ── My Games ─────────────────────────────────────────────────────────────

  /// Finalises any matched game still unscored 4h after kick-off as a 0–0 draw
  /// (server-side, idempotent). Fire-and-forget — called when My Games loads so
  /// stale games close even on projects without pg_cron. Failures are ignored.
  static Future<void> autoCompleteStaleGames() async {
    try {
      await _sb.rpc('auto_complete_stale_games');
    } catch (_) {}
  }

  /// Games my team posted (newest kick-off first).
  static Future<List<MatchGame>> fetchCreatedGames(String teamId) async {
    final rows = await _sb
        .from('games')
        .select('*, $_hostJoin, $_oppJoin')
        .eq('host_team_id', teamId)
        .order('kickoff', ascending: false);
    return (rows as List)
        .map((r) => MatchGame.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Games my team was picked to play (as the opponent).
  static Future<List<MatchGame>> fetchJoinedGames(String teamId) async {
    final rows = await _sb
        .from('games')
        .select('*, $_hostJoin, $_oppJoin')
        .eq('opponent_team_id', teamId)
        .order('kickoff', ascending: false);
    return (rows as List)
        .map((r) => MatchGame.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  static Future<MatchGame?> fetchMatch(String gameId) async {
    final r = await _sb
        .from('games')
        .select('*, $_hostJoin, $_oppJoin')
        .eq('id', gameId)
        .maybeSingle();
    return r == null ? null : MatchGame.fromRow(r);
  }

  /// All bids on a game (host-only), with bidder team + name + rank/rating.
  static Future<List<BidView>> fetchBids(String gameId) async {
    final rows = await _sb
        .from('bids')
        .select(
            '*, bidder:teams!bids_bidder_team_id_fkey(id,name,logo_url,city), '
            'user:users!bids_bidder_user_id_fkey(full_name)')
        .eq('game_id', gameId)
        .order('created_at', ascending: true);
    final list = (rows as List).cast<Map<String, dynamic>>();
    final standings = await _standingsFor(
        list.map((r) => r['bidder_team_id'] as String).toSet());
    return list.map((r) {
      final bid = Bid.fromRow(r);
      final team = TeamLite.fromRow(r['bidder'] as Map<String, dynamic>);
      final name =
          ((r['user'] as Map?)?['full_name'] ?? '') as String;
      final s = standings[bid.bidderTeamId];
      return BidView(
        bid: bid,
        team: team,
        bidderName: name,
        rank: s?.$1,
        rating: s?.$2 ?? 0,
        ratingCount: s?.$3 ?? 0,
      );
    }).toList();
  }

  /// Host accepts a bid: the bidder becomes the opponent, the game is matched,
  /// the chosen bid is accepted and the rest rejected. The accepted team and
  /// every declined team are notified.
  static Future<void> acceptBid(BidView chosen) async {
    final gameId = chosen.bid.gameId;
    // Who else bid? (notify them they weren't picked)
    final others = await _sb
        .from('bids')
        .select('bidder_user_id')
        .eq('game_id', gameId)
        .neq('id', chosen.bid.id);

    await _sb.from('games').update({
      'opponent_team_id': chosen.bid.bidderTeamId,
      'accepted_bid_id': chosen.bid.id,
      'status': 'matched',
    }).eq('id', gameId);
    await _sb
        .from('bids')
        .update({'status': 'accepted'}).eq('id', chosen.bid.id);
    await _sb
        .from('bids')
        .update({'status': 'rejected'})
        .eq('game_id', gameId)
        .neq('id', chosen.bid.id);

    try {
      await _sb.rpc('notify_user', params: {
        'target_user': chosen.bid.bidderUserId,
        'n_type': 'bid_accepted',
        'n_title': 'You got the game! ⚽',
        'n_body': 'The host picked your team. Check the match details.',
        'n_data': {'game_id': gameId},
      });
      for (final o in (others as List).cast<Map<String, dynamic>>()) {
        await _sb.rpc('notify_user', params: {
          'target_user': o['bidder_user_id'],
          'n_type': 'bid_rejected',
          'n_title': 'Not this time',
          'n_body': 'The host chose another team for this game.',
          'n_data': {'game_id': gameId},
        });
      }
    } catch (_) {}
  }

  /// Host declines a single bid (and notifies that team).
  static Future<void> rejectBid(String bidId,
      {String? bidderUserId, String? gameId}) async {
    await _sb.from('bids').update({'status': 'rejected'}).eq('id', bidId);
    if (bidderUserId != null) {
      try {
        await _sb.rpc('notify_user', params: {
          'target_user': bidderUserId,
          'n_type': 'bid_rejected',
          'n_title': 'Request declined',
          'n_body': 'The host declined your request for this game.',
          'n_data': {'game_id': ?gameId},
        });
      } catch (_) {}
    }
  }

  // ── Results + ratings ──────────────────────────────────────────────────────

  /// Host records the final score → the game is completed and standings update.
  static Future<void> enterScore({
    required String gameId,
    required int hostScore,
    required int oppScore,
    String? opponentCaptainId,
  }) async {
    await _sb.from('games').update({
      'host_score': hostScore,
      'opp_score': oppScore,
      'status': 'completed',
      'scored_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', gameId);
    if (opponentCaptainId != null) {
      try {
        await _sb.rpc('notify_user', params: {
          'target_user': opponentCaptainId,
          'n_type': 'result_posted',
          'n_title': 'Result is in 📋',
          'n_body': 'The host posted the score. You can rate them now.',
          'n_data': {'game_id': gameId},
        });
      } catch (_) {}
    }
  }

  /// Visiting team rates the host team (1–5) with an optional comment.
  /// One rating per game per team.
  static Future<void> rateHost({
    required String gameId,
    required String raterTeamId,
    required String ratedTeamId,
    required int stars,
    String? comment,
  }) async {
    try {
      await _sb.from('ratings').insert({
        'game_id': gameId,
        'rater_team_id': raterTeamId,
        'rated_team_id': ratedTeamId,
        'stars': stars,
        'comment': comment,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') return; // already rated — ignore
      throw GameFailure('Could not save your rating — please try again');
    }
  }

  /// All reviews left for a team (newest first), with the rater team's name.
  static Future<List<Review>> fetchTeamReviews(String teamId) async {
    final rows = await _sb
        .from('ratings')
        .select(
            'stars, comment, created_at, '
            'rater:teams!ratings_rater_team_id_fkey(name)')
        .eq('rated_team_id', teamId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => Review.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// The visiting team's existing rating for a game (stars), or null.
  static Future<int?> myRating(String gameId, String raterTeamId) async {
    final row = await _sb
        .from('ratings')
        .select('stars')
        .eq('game_id', gameId)
        .eq('rater_team_id', raterTeamId)
        .maybeSingle();
    return row?['stars'] as int?;
  }

  /// The phone to contact the other side: for the host it's the accepted bid's
  /// phone; for the visitor it's the host captain's phone.
  static Future<String?> contactPhone(String gameId,
      {required bool amHost}) async {
    if (amHost) {
      final row = await _sb
          .from('bids')
          .select('phone')
          .eq('game_id', gameId)
          .eq('status', 'accepted')
          .maybeSingle();
      return row?['phone'] as String?;
    }
    final g = await _sb
        .from('games')
        .select('host_captain_id')
        .eq('id', gameId)
        .maybeSingle();
    final hostId = g?['host_captain_id'] as String?;
    if (hostId == null) return null;
    final u = await _sb
        .from('users')
        .select('phone')
        .eq('id', hostId)
        .maybeSingle();
    final p = u?['phone'] as String?;
    return p;
  }
}

/// A game with both teams resolved (host + opponent when matched).
class MatchGame {
  final Game game;
  final TeamLite host;
  final TeamLite? opponent;
  const MatchGame({required this.game, required this.host, this.opponent});

  factory MatchGame.fromRow(Map<String, dynamic> r) => MatchGame(
        game: Game.fromRow(r),
        host: TeamLite.fromRow(r['host'] as Map<String, dynamic>),
        opponent: r['opp'] == null
            ? null
            : TeamLite.fromRow(r['opp'] as Map<String, dynamic>),
      );
}

/// A review left for a team by a visiting team.
class Review {
  final int stars;
  final String? comment;
  final String raterName;
  final DateTime createdAt;
  const Review({
    required this.stars,
    this.comment,
    required this.raterName,
    required this.createdAt,
  });

  factory Review.fromRow(Map<String, dynamic> r) => Review(
        stars: (r['stars'] ?? 0) as int,
        comment: r['comment'] as String?,
        raterName: ((r['rater'] as Map?)?['name'] ?? '') as String,
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      );
}

/// A bid enriched with the bidder team + captain name + league rank/rating.
class BidView {
  final Bid bid;
  final TeamLite team;
  final String bidderName;
  final int? rank;
  final double rating;
  final int ratingCount;
  const BidView({
    required this.bid,
    required this.team,
    required this.bidderName,
    this.rank,
    this.rating = 0,
    this.ratingCount = 0,
  });
}

/// A bid placed by a team to play a game.
class Bid {
  final String id;
  final String gameId;
  final String bidderTeamId;
  final String bidderUserId;
  final String? message;
  final String? phone;
  final String status; // pending | accepted | rejected
  final DateTime createdAt;

  const Bid({
    required this.id,
    required this.gameId,
    required this.bidderTeamId,
    required this.bidderUserId,
    this.message,
    this.phone,
    required this.status,
    required this.createdAt,
  });

  factory Bid.fromRow(Map<String, dynamic> r) => Bid(
        id: r['id'] as String,
        gameId: r['game_id'] as String,
        bidderTeamId: r['bidder_team_id'] as String,
        bidderUserId: r['bidder_user_id'] as String,
        message: r['message'] as String?,
        phone: r['phone'] as String?,
        status: (r['status'] ?? 'pending') as String,
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      );

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
}
