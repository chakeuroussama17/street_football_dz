import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current user's role in the app.
enum UserRole { player, captain, admin }

UserRole roleFromString(String? s) => switch (s) {
      'captain' => UserRole.captain,
      'admin' => UserRole.admin,
      _ => UserRole.player,
    };

String roleToString(UserRole r) => switch (r) {
      UserRole.captain => 'captain',
      UserRole.admin => 'admin',
      UserRole.player => 'player',
    };

/// Whether the signed-in user is the app admin.
final isAdminProvider = StateProvider<bool>((ref) => false);

/// The signed-in user's role (defaults to player).
final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.player);

/// The team the signed-in user belongs to (captain owns it / player joined it),
/// or null if they haven't set one up yet.
final myTeamIdProvider = StateProvider<String?>((ref) => null);
