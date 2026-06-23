import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/game_service.dart';
import 'session_provider.dart';

/// Feed filter selection (value type so it can key a Riverpod family).
class FeedFilters {
  final String? city;
  final String? format;
  final DateTime? day;
  const FeedFilters({this.city, this.format, this.day});

  FeedFilters copyWith({
    Object? city = _sentinel,
    Object? format = _sentinel,
    Object? day = _sentinel,
  }) =>
      FeedFilters(
        city: city == _sentinel ? this.city : city as String?,
        format: format == _sentinel ? this.format : format as String?,
        day: day == _sentinel ? this.day : day as DateTime?,
      );

  static const _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is FeedFilters &&
      other.city == city &&
      other.format == format &&
      other.day == day;

  @override
  int get hashCode => Object.hash(city, format, day);
}

/// The open-games feed for the given filters. Shows every open game, including
/// the viewer's own (the detail screen disables bidding on your own game).
final feedProvider =
    FutureProvider.autoDispose.family<List<GameFeedItem>, FeedFilters>(
  (ref, filters) {
    ref.watch(myTeamIdProvider); // refresh feed when the user's team changes
    return GameService.fetchFeed(
      city: filters.city,
      format: filters.format,
      day: filters.day,
    );
  },
);

/// A single game with host info.
final gameProvider = FutureProvider.autoDispose.family<GameFeedItem?, String>(
  (ref, id) => GameService.fetchGame(id),
);

/// The current user's team's bid on a game ((gameId, teamId)).
final myBidProvider =
    FutureProvider.autoDispose.family<Bid?, (String, String)>(
  (ref, key) => GameService.myBidForGame(key.$1, key.$2),
);

/// Games my team posted.
final createdGamesProvider =
    FutureProvider.autoDispose.family<List<MatchGame>, String>(
  (ref, teamId) => GameService.fetchCreatedGames(teamId),
);

/// Games my team was picked to play.
final joinedGamesProvider =
    FutureProvider.autoDispose.family<List<MatchGame>, String>(
  (ref, teamId) => GameService.fetchJoinedGames(teamId),
);

/// A matched game (both teams resolved).
final matchProvider =
    FutureProvider.autoDispose.family<MatchGame?, String>(
  (ref, id) => GameService.fetchMatch(id),
);

/// All bids on a game (host view).
final gameBidsProvider =
    FutureProvider.autoDispose.family<List<BidView>, String>(
  (ref, gameId) => GameService.fetchBids(gameId),
);

/// The visiting team's existing rating for a game ((gameId, raterTeamId)).
final myRatingProvider =
    FutureProvider.autoDispose.family<int?, (String, String)>(
  (ref, key) => GameService.myRating(key.$1, key.$2),
);

/// The other side's contact phone ((gameId, amHost)).
final contactPhoneProvider =
    FutureProvider.autoDispose.family<String?, (String, bool)>(
  (ref, key) => GameService.contactPhone(key.$1, amHost: key.$2),
);

/// Reviews left for a team (shown on the team's games + profile).
final teamReviewsProvider =
    FutureProvider.autoDispose.family<List<Review>, String>(
  (ref, teamId) => GameService.fetchTeamReviews(teamId),
);
