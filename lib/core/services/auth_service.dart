import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Thrown by AuthService with a message safe to show in the UI.
class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override
  String toString() => message;
}

/// The signed-in user as the app sees them (public.users row).
class AppUser {
  final String id;
  final String phone;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? city; // wilaya
  final String role; // 'player' | 'captain' | 'admin'
  final String? teamId;
  final String? avatarUrl;
  final bool isBanned;

  const AppUser({
    required this.id,
    required this.phone,
    required this.fullName,
    this.dateOfBirth,
    this.city,
    required this.role,
    this.teamId,
    this.avatarUrl,
    this.isBanned = false,
  });

  factory AppUser.fromRow(Map<String, dynamic> r) => AppUser(
        id: r['id'] as String,
        phone: (r['phone'] ?? '') as String,
        fullName: (r['full_name'] ?? '') as String,
        dateOfBirth: r['date_of_birth'] == null
            ? null
            : DateTime.tryParse(r['date_of_birth'] as String),
        city: r['city'] as String?,
        role: (r['role'] ?? 'player') as String,
        teamId: r['team_id'] as String?,
        avatarUrl: r['avatar_url'] as String?,
        isBanned: (r['is_banned'] ?? false) as bool,
      );

  bool get isCaptain => role == 'captain';
  bool get hasTeam => teamId != null;

  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var a = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      a--;
    }
    return a;
  }
}

/// Result of verifying an OTP: whether this phone is brand new (needs profile
/// setup) and, if not, the existing profile.
class VerifyResult {
  final bool isNew;
  final AppUser? profile;
  VerifyResult(this.isNew, this.profile);
}

class AuthService {
  static final _sb = SupabaseService.supabase;

  /// Sends a 6-digit OTP by SMS to [phone] (E.164, e.g. +213…). For new numbers
  /// Supabase creates the auth user on verify (shouldCreateUser defaults true).
  static Future<void> sendOtp(String phone) async {
    try {
      await _sb.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      throw AuthFailure(friendly(e.message));
    } catch (e) {
      throw AuthFailure(friendly(e.toString()));
    }
  }

  /// Verifies the SMS [token] for [phone]. Returns whether the user is new
  /// (no public.users row yet → continue to profile setup).
  static Future<VerifyResult> verifyOtp(String phone, String token) async {
    try {
      final res = await _sb.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      final user = res.user;
      if (user == null) throw AuthFailure('Verification failed — try again');

      final row =
          await _sb.from('users').select().eq('id', user.id).maybeSingle();
      if (row == null) return VerifyResult(true, null);

      final profile = AppUser.fromRow(row);
      if (profile.isBanned) {
        await _sb.auth.signOut();
        throw AuthFailure('This account has been suspended');
      }
      return VerifyResult(false, profile);
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(friendly(e.message));
    } catch (e) {
      throw AuthFailure(friendly(e.toString()));
    }
  }

  /// Creates or updates the public.users row for the signed-in auth user.
  static Future<AppUser> upsertProfile({
    required String fullName,
    required DateTime dateOfBirth,
    required String city,
    required String role, // 'captain' | 'player'
    String? teamId,
  }) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw AuthFailure('Your session expired — sign in again');
    final dob = _fmtDate(dateOfBirth);
    try {
      final row = await _sb
          .from('users')
          .upsert({
            'id': user.id,
            'phone': user.phone == null ? null : '+${user.phone}',
            'full_name': fullName,
            'date_of_birth': dob,
            'city': city,
            'role': role,
            'team_id': teamId,
          })
          .select()
          .single();
      return AppUser.fromRow(row);
    } catch (e) {
      throw AuthFailure(friendly(e.toString()));
    }
  }

  /// Sets the current user's team + role (used right after a team is created
  /// or joined).
  static Future<void> setTeam(String teamId, {required String role}) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw AuthFailure('Your session expired — sign in again');
    await _sb
        .from('users')
        .update({'team_id': teamId, 'role': role}).eq('id', user.id);
  }

  /// The current user's profile, or null if not signed in / no profile yet.
  static Future<AppUser?> currentAppUser() async {
    final user = _sb.auth.currentUser;
    if (user == null) return null;
    try {
      final row =
          await _sb.from('users').select().eq('id', user.id).maybeSingle();
      return row == null ? null : AppUser.fromRow(row);
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _sb.auth.signOut();
    } catch (_) {}
  }

  static Stream<AuthState> get onAuthStateChange => _sb.auth.onAuthStateChange;

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String friendly(String raw) {
    final m = raw.toLowerCase();
    if (m.contains('token has expired') || m.contains('invalid') && m.contains('otp')) {
      return 'That code is wrong or expired — try again';
    }
    if (m.contains('otp') || m.contains('code')) {
      return 'That code is wrong or expired — try again';
    }
    if (m.contains('sms') || m.contains('provider')) {
      return 'Could not send the SMS — check the number and try again';
    }
    if (m.contains('rate') || m.contains('limit')) {
      return 'Too many attempts — wait a moment and try again';
    }
    if (m.contains('socket') ||
        m.contains('failed host') ||
        m.contains('connection') ||
        m.contains('network')) {
      return 'Check your connection and try again';
    }
    return 'Something went wrong — please try again';
  }
}
