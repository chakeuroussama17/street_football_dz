// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Street Football DZ';

  @override
  String get welcomeTitle => 'Street Football,\nthe Algerian way.';

  @override
  String get welcomeSubtitle =>
      'Build your team, challenge the neighbourhood, climb the national league.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get iHaveAccount => 'I already have an account';

  @override
  String get skip => 'Skip';

  @override
  String get onboard2Title => 'Captain or player';

  @override
  String get onboard2Body =>
      'Create your own team and post games, or jump in with a friend\'s team code.';

  @override
  String get onboard3Title => 'Win as a team';

  @override
  String get onboard3Body =>
      'Record results, climb the Algerian League and build your team\'s reputation.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get fieldRequired => 'Required';

  @override
  String get navHome => 'Home';

  @override
  String get navMyGames => 'My Games';

  @override
  String get navLeague => 'League';

  @override
  String get navMyTeam => 'My Team';

  @override
  String get navProfile => 'Profile';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get phoneTitle => 'Enter your phone';

  @override
  String get phoneSubtitle => 'We\'ll text you a code to sign in.';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '5XX XX XX XX';

  @override
  String get sendCode => 'Send code';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get codeLabel => 'Verification code';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get profileTitle => 'Your details';

  @override
  String get profileSubtitle => 'So teams know who they\'re playing.';

  @override
  String get fullName => 'Full name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get selectDate => 'Select date';

  @override
  String get cityWilaya => 'City (wilaya)';

  @override
  String get selectCity => 'Select your wilaya';

  @override
  String get ageTooYoung => 'You must be at least 13';

  @override
  String get roleTitle => 'How do you want to play?';

  @override
  String get roleSubtitle =>
      'You can\'t change this later, so choose carefully.';

  @override
  String get captain => 'Captain';

  @override
  String get captainDesc => 'Create a team, post games and pick opponents.';

  @override
  String get player => 'Player';

  @override
  String get playerDesc => 'Join an existing team using its code.';

  @override
  String get createTeamTitle => 'Create your team';

  @override
  String get createTeamSubtitle =>
      'Your team joins the Algerian League right away.';

  @override
  String get teamName => 'Team name';

  @override
  String get teamLogoOptional => 'Team logo (optional)';

  @override
  String get addLogo => 'Add a logo';

  @override
  String get ageRangeOptional => 'Age range (optional)';

  @override
  String get minAge => 'Min age';

  @override
  String get maxAge => 'Max age';

  @override
  String get teamDetailsOptional => 'About the team (optional)';

  @override
  String get createTeamBtn => 'Create team';

  @override
  String get joinTeamTitle => 'Join a team';

  @override
  String get joinTeamSubtitle => 'Ask your captain for the team code.';

  @override
  String get teamCodeLabel => 'Team code';

  @override
  String get joinTeamBtn => 'Join team';

  @override
  String get teamCreatedTitle => 'Team created! 🎉';

  @override
  String get teamCreatedBody =>
      'Share this code with your players so they can join your team:';

  @override
  String get copyCode => 'Copy code';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get letsGo => 'Let\'s go';

  @override
  String get leagueTitle => 'Algerian League';

  @override
  String get leagueSubtitle => 'Every team, ranked by points.';

  @override
  String get allWilayas => 'All wilayas';

  @override
  String get noTeamsYet => 'No teams yet — be the first to create one!';

  @override
  String get pts => 'Pts';

  @override
  String get playedShort => 'P';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get unrated => 'Not rated yet';

  @override
  String get statPlayed => 'Played';

  @override
  String get statWon => 'Won';

  @override
  String get statDrawn => 'Drawn';

  @override
  String get statLost => 'Lost';

  @override
  String get captainLabel => 'Captain';

  @override
  String get ageRangeTitle => 'Age range';

  @override
  String get rosterTitle => 'Squad';

  @override
  String membersCount(int count) {
    return '$count members';
  }

  @override
  String get recentResults => 'Recent results';

  @override
  String get noResultsYet => 'No matches played yet.';

  @override
  String get myTeamTitle => 'My Team';

  @override
  String get yourTeamCode => 'Your team code';

  @override
  String get shareCode => 'Share code';

  @override
  String get editTeam => 'Edit team';

  @override
  String get leaveTeam => 'Leave team';

  @override
  String get leaveTeamConfirm => 'Leave this team?';

  @override
  String get leaveTeamBody => 'You\'ll need a team code to join again.';

  @override
  String get leave => 'Leave';

  @override
  String get yourTeams => 'Your teams';

  @override
  String get joinAnotherTeam => 'Join another team';

  @override
  String get removeMember => 'Remove';

  @override
  String removeMemberConfirm(String name) {
    return 'Remove $name from the team?';
  }

  @override
  String get memberRemoved => 'Member removed';

  @override
  String get noTeamYet => 'You\'re not in a team yet.';

  @override
  String get captainTag => 'Captain';

  @override
  String get playerTag => 'Player';

  @override
  String get teamSaved => 'Team updated';

  @override
  String get rankHash => '#';

  @override
  String get viewTeam => 'View team';

  @override
  String get feedTitle => 'Find a game';

  @override
  String get feedSubtitle => 'Open games posted by other teams.';

  @override
  String get filterDay => 'Day';

  @override
  String get filterFormat => 'Format';

  @override
  String get anyDay => 'Any day';

  @override
  String get anyFormat => 'Any format';

  @override
  String asideLabel(String count) {
    return '$count-a-side';
  }

  @override
  String get noGames => 'No open games right now — check back soon.';

  @override
  String get postGame => 'Post a game';

  @override
  String get onlyCaptainsPost => 'Only captains can post games.';

  @override
  String get createGameTitle => 'Post a game';

  @override
  String get createGameSubtitle => 'Teams will bid to play you — you pick who.';

  @override
  String get gameFormat => 'Format';

  @override
  String get fieldAddress => 'Field / address';

  @override
  String get fieldAddressHint => 'e.g. Stade de proximité, Bab Ezzouar';

  @override
  String get pickLocation => 'Pick location on map';

  @override
  String get tapToPickLocation => 'Tap to set the field location';

  @override
  String get useThisLocation => 'Use this location';

  @override
  String get searchPlace => 'Search place or address';

  @override
  String get movePinHint => 'Move the map to place the pin';

  @override
  String get locationPermissionDenied =>
      'Location unavailable — enable location and try again';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get changeLocation => 'Change';

  @override
  String get gameDay => 'Day';

  @override
  String get gameTime => 'Kick-off time';

  @override
  String get selectTime => 'Select time';

  @override
  String get durationLabel => 'Duration';

  @override
  String get minutesShort => 'min';

  @override
  String get gamePhotoOptional => 'Photo (optional)';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get gameDetailsOptional => 'Details (optional)';

  @override
  String get gameDetailsHint => 'Anything the other team should know.';

  @override
  String get postGameBtn => 'Post game';

  @override
  String get whenLabel => 'When';

  @override
  String get whereLabel => 'Where';

  @override
  String get kickoffLabel => 'Kick-off';

  @override
  String get hostTeamLabel => 'Host team';

  @override
  String get placeBid => 'Place a bid';

  @override
  String get bidMessage => 'Your message';

  @override
  String get bidMessageHint =>
      'Tell them about your team and why you want to play.';

  @override
  String get bidPhone => 'Contact phone';

  @override
  String get sendBid => 'Send request';

  @override
  String get bidSent => 'Request sent! The host will get back to you.';

  @override
  String get alreadyBidTitle => 'Request pending';

  @override
  String get alreadyBidBody =>
      'You\'ve already asked to play this game. The host will choose soon.';

  @override
  String get thisIsYourGame => 'This is your team\'s game.';

  @override
  String get needTeamToBid => 'You need a team to send a request.';

  @override
  String get gamePosted => 'Game posted!';

  @override
  String get myGamesTitle => 'My Games';

  @override
  String get tabCreated => 'Created';

  @override
  String get tabJoined => 'Joined';

  @override
  String get noCreated => 'You haven\'t posted any games yet.';

  @override
  String get noJoined => 'You haven\'t been picked for a game yet.';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusMatched => 'Matched';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get requestsTitle => 'Requests';

  @override
  String requestsCount(int count) {
    return '$count requests';
  }

  @override
  String get noBids => 'No requests yet — share your game!';

  @override
  String get pickTeam => 'Pick this team';

  @override
  String get decline => 'Decline';

  @override
  String get picked => 'Picked';

  @override
  String get call => 'Call';

  @override
  String pickConfirm(String team) {
    return 'Pick $team?';
  }

  @override
  String get pickConfirmBody =>
      'They become your opponent and the game is locked in.';

  @override
  String get opponentPicked => 'Opponent picked! 🎉';

  @override
  String get vs => 'vs';

  @override
  String get opponentLabel => 'Opponent';

  @override
  String get waitingBids => 'Waiting for teams to send requests…';

  @override
  String get manageGame => 'Manage';

  @override
  String get cancelGame => 'Cancel game';

  @override
  String get cancelGameConfirm => 'Cancel this game?';

  @override
  String get cancelGameBody => 'This removes the game and all requests.';

  @override
  String get gameCancelled => 'Game cancelled';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get enterResult => 'Enter the result';

  @override
  String scoreFor(String team) {
    return '$team score';
  }

  @override
  String get saveResult => 'Save result';

  @override
  String get resultSaved => 'Result saved';

  @override
  String get editResult => 'Edit result';

  @override
  String get resultPending => 'Waiting for the host to enter the result.';

  @override
  String get afterGameEnds => 'You can enter the result after the game ends.';

  @override
  String rateHostTitle(String team) {
    return 'Rate $team';
  }

  @override
  String get rateHostBody =>
      'How were they to play against — fair play, showing up, attitude?';

  @override
  String get submitRating => 'Submit rating';

  @override
  String get ratingSaved => 'Thanks for rating!';

  @override
  String youRated(int stars) {
    return 'You rated $stars★';
  }

  @override
  String get rateHostCta => 'Rate the host team';

  @override
  String get contactLabel => 'Contact';

  @override
  String get noContact => 'No contact available';

  @override
  String get profileTabTitle => 'Profile';

  @override
  String get roleLabel => 'Role';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Sign out?';

  @override
  String get aboutApp => 'About';

  @override
  String get appVersion => 'Version';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet.';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get adminPanel => 'Admin panel';

  @override
  String get adminTitle => 'Admin';

  @override
  String get statsTeams => 'Teams';

  @override
  String get statsGames => 'Games';

  @override
  String get statsPlayers => 'Players';

  @override
  String get manageAds => 'Ads & announcements';

  @override
  String get addAd => 'New ad';

  @override
  String get adTitleField => 'Title';

  @override
  String get adBodyField => 'Message';

  @override
  String get adLinkField => 'Link (optional)';

  @override
  String get adActive => 'Active';

  @override
  String get adSaved => 'Saved';

  @override
  String get noAds => 'No ads yet.';

  @override
  String get edit => 'Edit';

  @override
  String get openLink => 'Open';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to your account.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'A few details to get you started.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get login => 'Log in';

  @override
  String get createAccount => 'Create account';

  @override
  String get noAccountCta => 'New here? Create an account';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordTooShort => 'At least 6 characters';

  @override
  String get manageUsers => 'Users';

  @override
  String joinedOn(String date) {
    return 'Joined $date';
  }

  @override
  String get editWindowNote =>
      'You can edit the score for 10 minutes after saving. After that it\'s final.';

  @override
  String editWindowLeft(int minutes) {
    return '~$minutes min left to edit';
  }

  @override
  String get resultFinal => 'This result is final.';

  @override
  String scoreOpensIn(int minutes) {
    return 'Score entry opens ~$minutes min after kick-off.';
  }

  @override
  String get sectionLive => 'Live now';

  @override
  String get sectionUpcoming => 'Upcoming';

  @override
  String get sectionFinished => 'Finished';

  @override
  String get liveTag => 'LIVE';

  @override
  String get reviewComment => 'Comment (optional)';

  @override
  String get reviewCommentHint => 'How was the match / the host team?';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get noReviews => 'No reviews yet.';
}
