import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../games/screens/my_games_screen.dart';
import '../../league/screens/league_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../team/screens/my_team_screen.dart';
import 'home_feed_screen.dart';

/// The 5-tab app shell (RTL order: Home · My Games · League · My Team · Profile).
class HomeShell extends StatefulWidget {
  final int initialIndex;
  const HomeShell({super.key, this.initialIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tabs = <(String, IconData)>[
      (t.navHome, Icons.home_rounded),
      (t.navMyGames, Icons.sports_soccer_rounded),
      (t.navLeague, Icons.emoji_events_rounded),
      (t.navMyTeam, Icons.groups_rounded),
      (t.navProfile, Icons.person_rounded),
    ];

    final bodies = <Widget>[
      const HomeFeedScreen(),
      const MyGamesScreen(),
      const LeagueScreen(),
      const MyTeamScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: bodies),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final (label, icon) in tabs)
            NavigationDestination(icon: Icon(icon), label: label),
        ],
      ),
    );
  }
}
