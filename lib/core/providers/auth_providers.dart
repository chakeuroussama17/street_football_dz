import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'session_provider.dart';

/// Draft profile basics collected during onboarding, carried from the profile
/// setup screen to the captain/player branch.
class OnboardingDraft {
  final String fullName;
  final DateTime dateOfBirth;
  final String city;
  final String phone; // E.164
  const OnboardingDraft({
    required this.fullName,
    required this.dateOfBirth,
    required this.city,
    required this.phone,
  });
}

final onboardingDraftProvider = StateProvider<OnboardingDraft?>((ref) => null);

/// The current signed-in profile (re-fetched on demand).
final currentUserProvider = FutureProvider.autoDispose<AppUser?>(
  (ref) => AuthService.currentAppUser(),
);

bool _isAdmin(AppUser? user) =>
    user != null &&
    (user.role == 'admin' || user.phone == SupabaseService.adminPhone);

/// Pushes a freshly loaded profile into the session state providers (role,
/// admin flag, team id). Call after login and after onboarding completes.
void applySessionState(Ref ref, AppUser? user) {
  final admin = _isAdmin(user);
  ref.read(isAdminProvider.notifier).state = admin;
  ref.read(userRoleProvider.notifier).state =
      admin ? UserRole.admin : roleFromString(user?.role);
  ref.read(myTeamIdProvider.notifier).state = user?.teamId;
}

/// Same as [applySessionState] but usable from a widget with a [WidgetRef].
void applySessionStateW(WidgetRef ref, AppUser? user) {
  final admin = _isAdmin(user);
  ref.read(isAdminProvider.notifier).state = admin;
  ref.read(userRoleProvider.notifier).state =
      admin ? UserRole.admin : roleFromString(user?.role);
  ref.read(myTeamIdProvider.notifier).state = user?.teamId;
}
