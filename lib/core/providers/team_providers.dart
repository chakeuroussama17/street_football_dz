import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/team_service.dart';
import 'session_provider.dart';

/// The full league table (optionally filtered by wilaya).
final standingsProvider =
    FutureProvider.autoDispose.family<List<TeamStanding>, String?>(
  (ref, city) => TeamService.fetchStandings(city: city),
);

/// A single team's profile.
final teamProvider = FutureProvider.autoDispose.family<Team?, String>(
  (ref, teamId) => TeamService.fetchTeam(teamId),
);

/// A single team's standing (rank/points/rating).
final teamStandingProvider =
    FutureProvider.autoDispose.family<TeamStanding?, String>(
  (ref, teamId) => TeamService.fetchStanding(teamId),
);

/// A team's roster.
final rosterProvider =
    FutureProvider.autoDispose.family<List<TeamMember>, String>(
  (ref, teamId) => TeamService.fetchRoster(teamId),
);

/// The signed-in user's own team (null until onboarding completes).
final myTeamProvider = FutureProvider.autoDispose<Team?>((ref) {
  ref.watch(myTeamIdProvider); // refetch when the team id changes
  return TeamService.fetchMyTeam();
});
