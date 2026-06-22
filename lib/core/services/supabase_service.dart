import 'package:supabase_flutter/supabase_flutter.dart';

/// Central access point for the Supabase client and auth session info.
class SupabaseService {
  static final supabase = Supabase.instance.client;

  /// The phone number (E.164, e.g. +213...) recognised as the app admin.
  /// Set this to your own number before launch.
  static const adminPhone = '+213000000000';

  static User? get currentUser => supabase.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userId => currentUser?.id;
  static String? get phone => currentUser?.phone;

  /// Admin = the configured [adminPhone]. Supabase stores phone without the
  /// leading '+', so normalise before comparing.
  static bool get isAdmin {
    final p = currentUser?.phone;
    if (p == null || p.isEmpty) return false;
    final normalized = p.startsWith('+') ? p : '+$p';
    return normalized == adminPhone;
  }
}
