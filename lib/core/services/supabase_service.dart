import 'package:supabase_flutter/supabase_flutter.dart';

/// Central access point for the Supabase client and auth session info.
class SupabaseService {
  static final supabase = Supabase.instance.client;

  /// The dedicated admin account (email + password login). Anyone signing in
  /// with this email gets admin powers (stats, users, ads). Change before launch.
  static const adminEmail = 'admin@gmail.com';

  /// Optional: a phone also recognised as admin (legacy). Leave as-is if unused.
  static const adminPhone = '+213000000000';

  static User? get currentUser => supabase.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userId => currentUser?.id;
  static String? get phone => currentUser?.phone;

  /// True when the signed-in auth user is the admin account.
  static bool get isAdminEmail =>
      currentUser?.email?.toLowerCase() == adminEmail;

  static bool get isAdmin => isAdminEmail;
}
