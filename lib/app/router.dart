import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/role_choice_screen.dart';
import '../features/auth/screens/create_team_screen.dart';
import '../features/auth/screens/join_team_screen.dart';
import '../features/team/screens/team_detail_screen.dart';
import '../features/team/screens/edit_team_screen.dart';
import '../features/home/screens/home_shell.dart';
import '../features/home/screens/create_game_screen.dart';
import '../features/home/screens/game_detail_screen.dart';
import '../features/games/screens/game_manage_screen.dart';
import '../features/games/screens/match_detail_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/admin/screens/manage_ads_screen.dart';

/// App router. Built as a provider so routes can read session state for
/// redirects in later phases.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (c, s) => const SplashScreen()),
      GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (c, s) => const WelcomeScreen()),
      GoRoute(
          path: '/register',
          name: 'register',
          builder: (c, s) => const RegisterScreen()),
      GoRoute(
          path: '/login',
          name: 'login',
          builder: (c, s) => const LoginScreen()),
      GoRoute(
          path: '/role-choice',
          name: 'role-choice',
          builder: (c, s) => const RoleChoiceScreen()),
      GoRoute(
          path: '/create-team',
          name: 'create-team',
          builder: (c, s) => const CreateTeamScreen()),
      GoRoute(
          path: '/join-team',
          name: 'join-team',
          builder: (c, s) => const JoinTeamScreen()),
      GoRoute(
          path: '/home', name: 'home', builder: (c, s) => const HomeShell()),
      GoRoute(
          path: '/team/:id',
          name: 'team-detail',
          builder: (c, s) => TeamDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(
          path: '/team/:id/edit',
          name: 'team-edit',
          builder: (c, s) => EditTeamScreen(id: s.pathParameters['id']!)),
      GoRoute(
          path: '/create-game',
          name: 'create-game',
          builder: (c, s) => const CreateGameScreen()),
      GoRoute(
          path: '/game/:id',
          name: 'game-detail',
          builder: (c, s) => GameDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(
          path: '/my-game/:id',
          name: 'game-manage',
          builder: (c, s) => GameManageScreen(id: s.pathParameters['id']!)),
      GoRoute(
          path: '/match/:id',
          name: 'match-detail',
          builder: (c, s) => MatchDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (c, s) => const SettingsScreen()),
      GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (c, s) => const NotificationsScreen()),
      GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (c, s) => const AdminDashboardScreen()),
      GoRoute(
          path: '/admin/users',
          name: 'admin-users',
          builder: (c, s) => const AdminUsersScreen()),
      GoRoute(
          path: '/admin/ads',
          name: 'admin-ads',
          builder: (c, s) => const ManageAdsScreen()),
    ],
  );
});
