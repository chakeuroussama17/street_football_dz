import 'dart:math';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class TeamFailure implements Exception {
  final String message;
  TeamFailure(this.message);
  @override
  String toString() => message;
}

/// A team (the central entity of the app).
class Team {
  final String id;
  final String captainId;
  final String name;
  final String? logoUrl;
  final String? city;
  final int? ageMin;
  final int? ageMax;
  final String? details;
  final String teamCode;

  const Team({
    required this.id,
    required this.captainId,
    required this.name,
    this.logoUrl,
    this.city,
    this.ageMin,
    this.ageMax,
    this.details,
    required this.teamCode,
  });

  factory Team.fromRow(Map<String, dynamic> r) => Team(
        id: r['id'] as String,
        captainId: r['captain_id'] as String,
        name: (r['name'] ?? '') as String,
        logoUrl: r['logo_url'] as String?,
        city: r['city'] as String?,
        ageMin: r['age_min'] as int?,
        ageMax: r['age_max'] as int?,
        details: r['details'] as String?,
        teamCode: (r['team_code'] ?? '') as String,
      );

  String get ageRangeLabel {
    if (ageMin == null && ageMax == null) return '';
    if (ageMin != null && ageMax != null) return '$ageMin–$ageMax';
    return '${ageMin ?? ageMax}+';
  }
}

/// A row of the league table (from the team_standings view).
class TeamStanding {
  final String id;
  final String name;
  final String? logoUrl;
  final String? city;
  final int points;
  final int wins;
  final int draws;
  final int losses;
  final int played;
  final double ratingAvg;
  final int ratingCount;
  final int rank;

  const TeamStanding({
    required this.id,
    required this.name,
    this.logoUrl,
    this.city,
    required this.points,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.played,
    required this.ratingAvg,
    required this.ratingCount,
    required this.rank,
  });

  factory TeamStanding.fromRow(Map<String, dynamic> r) => TeamStanding(
        id: r['id'] as String,
        name: (r['name'] ?? '') as String,
        logoUrl: r['logo_url'] as String?,
        city: r['city'] as String?,
        points: (r['points'] ?? 0) as int,
        wins: (r['wins'] ?? 0) as int,
        draws: (r['draws'] ?? 0) as int,
        losses: (r['losses'] ?? 0) as int,
        played: (r['played'] ?? 0) as int,
        ratingAvg: ((r['rating_avg'] ?? 0) as num).toDouble(),
        ratingCount: (r['rating_count'] ?? 0) as int,
        rank: (r['rank'] ?? 0) as int,
      );
}

/// A team member (for the roster).
class TeamMember {
  final String id;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final int? age;
  const TeamMember(
      {required this.id,
      required this.fullName,
      required this.role,
      this.avatarUrl,
      this.age});
}

/// One of the teams a user belongs to, with their role in it.
class TeamMembership {
  final Team team;
  final String role; // 'captain' | 'player'
  const TeamMembership({required this.team, required this.role});

  bool get isCaptain => role == 'captain';
}

class TeamService {
  static final _sb = SupabaseService.supabase;
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no O/0/I/1

  /// Creates a new team owned by the current user, with a unique join code.
  static Future<Team> createTeam({
    required String name,
    required String city,
    int? ageMin,
    int? ageMax,
    String? details,
    String? logoUrl,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw TeamFailure('Your session expired — sign in again');
    try {
      final code = await _uniqueCode();
      final row = await _sb
          .from('teams')
          .insert({
            'captain_id': uid,
            'name': name,
            'city': city,
            'age_min': ageMin,
            'age_max': ageMax,
            'details': details,
            'logo_url': logoUrl,
            'team_code': code,
          })
          .select()
          .single();
      final team = Team.fromRow(row);
      // The captain is also a roster member.
      await _sb.from('team_members').upsert(
        {'team_id': team.id, 'user_id': uid, 'role': 'captain'},
        onConflict: 'team_id,user_id',
        ignoreDuplicates: true,
      );
      return team;
    } catch (e) {
      throw TeamFailure('Could not create the team — please try again');
    }
  }

  /// Adds the current user to [teamId] (idempotent) and makes it their active
  /// team. A user can belong to as many teams as they have codes for.
  static Future<void> joinTeam(String teamId) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw TeamFailure('Your session expired — sign in again');
    final team = await fetchTeam(teamId);
    final role = team?.captainId == uid ? 'captain' : 'player';
    try {
      await _sb.from('team_members').upsert(
        {'team_id': teamId, 'user_id': uid, 'role': role},
        onConflict: 'team_id,user_id',
        ignoreDuplicates: true,
      );
      // Switch the active team to the one just joined.
      await _sb
          .from('users')
          .update({'team_id': teamId, 'role': role}).eq('id', uid);
    } catch (_) {
      throw TeamFailure('Could not join the team — please try again');
    }
  }

  /// Sets which of the user's teams is "active" (acted as for posting/bidding),
  /// keeping their global role in sync with that team.
  static Future<void> setActiveTeam(String teamId) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    final team = await fetchTeam(teamId);
    final role = team?.captainId == uid ? 'captain' : 'player';
    await _sb
        .from('users')
        .update({'team_id': teamId, 'role': role}).eq('id', uid);
  }

  /// Captain removes a member from their team (RPC enforces captain-only).
  static Future<void> removeMember(String teamId, String userId) async {
    try {
      await _sb.rpc('remove_team_member',
          params: {'p_team': teamId, 'p_user': userId});
    } on PostgrestException catch (e) {
      throw TeamFailure(e.message);
    }
  }

  /// All teams the current user belongs to, with their role in each.
  static Future<List<TeamMembership>> fetchMyTeams() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _sb
        .from('team_members')
        .select('role, team:teams(*)')
        .eq('user_id', uid)
        .order('joined_at', ascending: true);
    return (rows as List)
        .where((r) => (r as Map)['team'] != null)
        .map((r) {
          final m = r as Map<String, dynamic>;
          return TeamMembership(
            team: Team.fromRow(m['team'] as Map<String, dynamic>),
            role: (m['role'] ?? 'player') as String,
          );
        })
        .toList();
  }

  /// Finds a team by its join code (case-insensitive). Throws if not found.
  static Future<Team> findByCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) throw TeamFailure('Enter the team code');
    final row = await _sb
        .from('teams')
        .select()
        .eq('team_code', clean)
        .maybeSingle();
    if (row == null) throw TeamFailure('No team found with that code');
    return Team.fromRow(row);
  }

  /// The full league table, ordered by rank.
  static Future<List<TeamStanding>> fetchStandings({String? city}) async {
    var query = _sb.from('team_standings').select();
    if (city != null) query = query.eq('city', city);
    final rows = await query.order('rank', ascending: true);
    return (rows as List)
        .map((r) => TeamStanding.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// A single team's standing row (rank, points, rating).
  static Future<TeamStanding?> fetchStanding(String teamId) async {
    final row = await _sb
        .from('team_standings')
        .select()
        .eq('id', teamId)
        .maybeSingle();
    return row == null ? null : TeamStanding.fromRow(row);
  }

  /// Name of a team's captain (for the detail screen).
  static Future<String?> fetchCaptainName(String captainId) async {
    final row = await _sb
        .from('users')
        .select('full_name')
        .eq('id', captainId)
        .maybeSingle();
    return row?['full_name'] as String?;
  }

  static Future<Team?> fetchTeam(String teamId) async {
    final row =
        await _sb.from('teams').select().eq('id', teamId).maybeSingle();
    return row == null ? null : Team.fromRow(row);
  }

  static Future<Team?> fetchMyTeam() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    final me =
        await _sb.from('users').select('team_id').eq('id', uid).maybeSingle();
    final teamId = me?['team_id'] as String?;
    return teamId == null ? null : fetchTeam(teamId);
  }

  static Future<List<TeamMember>> fetchRoster(String teamId) async {
    final rows = await _sb
        .from('team_members')
        .select(
            'role, user:users(id, full_name, avatar_url, date_of_birth)')
        .eq('team_id', teamId);
    return (rows as List)
        .where((r) => (r as Map)['user'] != null)
        .map((r) {
          final row = r as Map<String, dynamic>;
          final u = row['user'] as Map<String, dynamic>;
          int? age;
          if (u['date_of_birth'] != null) {
            final dob = DateTime.tryParse(u['date_of_birth'] as String);
            if (dob != null) {
              final now = DateTime.now();
              age = now.year - dob.year;
              if (now.month < dob.month ||
                  (now.month == dob.month && now.day < dob.day)) {
                age = age - 1;
              }
            }
          }
          return TeamMember(
            id: u['id'] as String,
            fullName: (u['full_name'] ?? '') as String,
            role: (row['role'] ?? 'player') as String,
            avatarUrl: u['avatar_url'] as String?,
            age: age,
          );
        })
        .toList()
      ..sort((a, b) => a.role == 'captain' ? -1 : (b.role == 'captain' ? 1 : 0));
  }

  static Future<Team> updateTeam(
    String teamId, {
    String? name,
    String? city,
    int? ageMin,
    int? ageMax,
    String? details,
    String? logoUrl,
  }) async {
    final patch = <String, dynamic>{
      'name': ?name,
      'city': ?city,
      'age_min': ageMin,
      'age_max': ageMax,
      'details': ?details,
      'logo_url': ?logoUrl,
    };
    final row = await _sb
        .from('teams')
        .update(patch)
        .eq('id', teamId)
        .select()
        .single();
    return Team.fromRow(row);
  }

  /// Player leaves [teamId]. Their active team is repointed to another team
  /// they're still in, or cleared. (Captains can't leave their own team.)
  static Future<void> leaveTeam(String teamId) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    await _sb
        .from('team_members')
        .delete()
        .eq('team_id', teamId)
        .eq('user_id', uid);
    // Repoint the active team if we just left it.
    final me =
        await _sb.from('users').select('team_id').eq('id', uid).maybeSingle();
    if ((me?['team_id'] as String?) == teamId) {
      final remaining = await _sb
          .from('team_members')
          .select('team_id')
          .eq('user_id', uid)
          .limit(1);
      final next = (remaining as List).isEmpty
          ? null
          : (remaining.first as Map)['team_id'] as String?;
      if (next != null) {
        await setActiveTeam(next);
      } else {
        await _sb.from('users').update({'team_id': null}).eq('id', uid);
      }
    }
  }

  /// Uploads a team logo to the team-logos bucket and returns its public URL.
  static Future<String> uploadLogo(Uint8List bytes, String ext) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw TeamFailure('Your session expired — sign in again');
    final path = '$uid/logo_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _sb.storage.from('team-logos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/$ext',
          ),
        );
    return _sb.storage.from('team-logos').getPublicUrl(path);
  }

  static Future<String> _uniqueCode() async {
    final rnd = Random.secure();
    for (var attempt = 0; attempt < 8; attempt++) {
      final code = List.generate(
          6, (_) => _codeChars[rnd.nextInt(_codeChars.length)]).join();
      final existing = await _sb
          .from('teams')
          .select('id')
          .eq('team_code', code)
          .maybeSingle();
      if (existing == null) return code;
    }
    // Extremely unlikely fallback.
    return 'T${DateTime.now().millisecondsSinceEpoch % 100000}';
  }
}
