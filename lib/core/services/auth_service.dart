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

class AuthService {
  static final _sb = SupabaseService.supabase;

  // ── Testing-mode auth (NO verification) ──────────────────────────────────────
  // The phone number is the account identity. We sign the user in/up with a
  // deterministic email + password derived from the phone, with Supabase email
  // confirmation turned OFF — so there's no OTP, no SMS, no verification step.
  // (Not secure: anyone who knows a phone can sign in. Fine for testing; swap
  // back to real OTP before launch.)

  static String _emailFor(String phoneE164) =>
      '${phoneE164.replaceAll(RegExp(r'\D'), '')}@sfdz.app';

  static String _passwordFor(String phoneE164) =>
      'sfdz-${phoneE164.replaceAll(RegExp(r'\D'), '')}';

  /// Signs the phone in, creating the account on first use. No verification.
  static Future<void> authByPhone(String phoneE164) async {
    final email = _emailFor(phoneE164);
    final pw = _passwordFor(phoneE164);
    try {
      await _sb.auth.signInWithPassword(email: email, password: pw);
    } on AuthException {
      // Not registered yet → create the account (instant, no confirmation).
      try {
        await _sb.auth.signUp(email: email, password: pw);
      } on AuthException catch (e2) {
        if (e2.message.toLowerCase().contains('already')) {
          await _sb.auth.signInWithPassword(email: email, password: pw);
        } else {
          throw AuthFailure(friendly(e2.message));
        }
      }
    }
    if (_sb.auth.currentSession == null) {
      throw AuthFailure(
          'Could not sign in. In Supabase → Authentication → Email, turn OFF '
          '"Confirm email".');
    }
  }

  /// Creates or updates the public.users row for the signed-in auth user.
  static Future<AppUser> upsertProfile({
    required String fullName,
    required DateTime dateOfBirth,
    required String city,
    required String phone, // E.164, e.g. +213…
    required String role, // 'captain' | 'player'
    String? teamId,
  }) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw AuthFailure('Your session expired — sign in again');
    final dob = _fmtDate(dateOfBirth);
    final effectiveRole =
        phone == SupabaseService.adminPhone ? 'admin' : role;
    try {
      final row = await _sb
          .from('users')
          .upsert({
            'id': user.id,
            'phone': phone,
            'full_name': fullName,
            'date_of_birth': dob,
            'city': city,
            'role': effectiveRole,
            'team_id': teamId,
          })
          .select()
          .single();
      return AppUser.fromRow(row);
    } catch (e) {
      throw AuthFailure(friendly(e.toString()));
    }
  }

  /// Sets the current user's team + role (after a team is created or joined).
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
    if (m.contains('confirm') && m.contains('email')) {
      return 'Turn off "Confirm email" in Supabase → Authentication → Email.';
    }
    if (m.contains('duplicate') || m.contains('unique')) {
      return 'That phone number is already registered to another account.';
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
