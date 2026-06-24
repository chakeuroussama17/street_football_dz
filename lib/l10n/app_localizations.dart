import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Street Football DZ'**
  String get appName;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Street Football,\nthe Algerian way.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build your team, challenge the neighbourhood, climb the national league.'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @iHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get iHaveAccount;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onboard2Title.
  ///
  /// In en, this message translates to:
  /// **'Captain or player'**
  String get onboard2Title;

  /// No description provided for @onboard2Body.
  ///
  /// In en, this message translates to:
  /// **'Create your own team and post games, or jump in with a friend\'s team code.'**
  String get onboard2Body;

  /// No description provided for @onboard3Title.
  ///
  /// In en, this message translates to:
  /// **'Win as a team'**
  String get onboard3Title;

  /// No description provided for @onboard3Body.
  ///
  /// In en, this message translates to:
  /// **'Record results, climb the Algerian League and build your team\'s reputation.'**
  String get onboard3Body;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMyGames.
  ///
  /// In en, this message translates to:
  /// **'My Games'**
  String get navMyGames;

  /// No description provided for @navLeague.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get navLeague;

  /// No description provided for @navMyTeam.
  ///
  /// In en, this message translates to:
  /// **'My Team'**
  String get navMyTeam;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @phoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone'**
  String get phoneTitle;

  /// No description provided for @phoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll text you a code to sign in.'**
  String get phoneSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'5XX XX XX XX'**
  String get phoneHint;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get codeLabel;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'So teams know who they\'re playing.'**
  String get profileSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @cityWilaya.
  ///
  /// In en, this message translates to:
  /// **'City (wilaya)'**
  String get cityWilaya;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select your wilaya'**
  String get selectCity;

  /// No description provided for @ageTooYoung.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 13'**
  String get ageTooYoung;

  /// No description provided for @roleTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to play?'**
  String get roleTitle;

  /// No description provided for @roleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can\'t change this later, so choose carefully.'**
  String get roleSubtitle;

  /// No description provided for @captain.
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get captain;

  /// No description provided for @captainDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a team, post games and pick opponents.'**
  String get captainDesc;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @playerDesc.
  ///
  /// In en, this message translates to:
  /// **'Join an existing team using its code.'**
  String get playerDesc;

  /// No description provided for @createTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your team'**
  String get createTeamTitle;

  /// No description provided for @createTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your team joins the Algerian League right away.'**
  String get createTeamSubtitle;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team name'**
  String get teamName;

  /// No description provided for @teamLogoOptional.
  ///
  /// In en, this message translates to:
  /// **'Team logo (optional)'**
  String get teamLogoOptional;

  /// No description provided for @addLogo.
  ///
  /// In en, this message translates to:
  /// **'Add a logo'**
  String get addLogo;

  /// No description provided for @ageRangeOptional.
  ///
  /// In en, this message translates to:
  /// **'Age range (optional)'**
  String get ageRangeOptional;

  /// No description provided for @minAge.
  ///
  /// In en, this message translates to:
  /// **'Min age'**
  String get minAge;

  /// No description provided for @maxAge.
  ///
  /// In en, this message translates to:
  /// **'Max age'**
  String get maxAge;

  /// No description provided for @teamDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'About the team (optional)'**
  String get teamDetailsOptional;

  /// No description provided for @createTeamBtn.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get createTeamBtn;

  /// No description provided for @joinTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a team'**
  String get joinTeamTitle;

  /// No description provided for @joinTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask your captain for the team code.'**
  String get joinTeamSubtitle;

  /// No description provided for @teamCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Team code'**
  String get teamCodeLabel;

  /// No description provided for @joinTeamBtn.
  ///
  /// In en, this message translates to:
  /// **'Join team'**
  String get joinTeamBtn;

  /// No description provided for @teamCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Team created! 🎉'**
  String get teamCreatedTitle;

  /// No description provided for @teamCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'Share this code with your players so they can join your team:'**
  String get teamCreatedBody;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get letsGo;

  /// No description provided for @leagueTitle.
  ///
  /// In en, this message translates to:
  /// **'Algerian League'**
  String get leagueTitle;

  /// No description provided for @leagueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every team, ranked by points.'**
  String get leagueSubtitle;

  /// No description provided for @allWilayas.
  ///
  /// In en, this message translates to:
  /// **'All wilayas'**
  String get allWilayas;

  /// No description provided for @noTeamsYet.
  ///
  /// In en, this message translates to:
  /// **'No teams yet — be the first to create one!'**
  String get noTeamsYet;

  /// No description provided for @pts.
  ///
  /// In en, this message translates to:
  /// **'Pts'**
  String get pts;

  /// No description provided for @playedShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get playedShort;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @unrated.
  ///
  /// In en, this message translates to:
  /// **'Not rated yet'**
  String get unrated;

  /// No description provided for @statPlayed.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get statPlayed;

  /// No description provided for @statWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get statWon;

  /// No description provided for @statDrawn.
  ///
  /// In en, this message translates to:
  /// **'Drawn'**
  String get statDrawn;

  /// No description provided for @statLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get statLost;

  /// No description provided for @captainLabel.
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get captainLabel;

  /// No description provided for @ageRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRangeTitle;

  /// No description provided for @rosterTitle.
  ///
  /// In en, this message translates to:
  /// **'Squad'**
  String get rosterTitle;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(int count);

  /// No description provided for @recentResults.
  ///
  /// In en, this message translates to:
  /// **'Recent results'**
  String get recentResults;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No matches played yet.'**
  String get noResultsYet;

  /// No description provided for @myTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'My Team'**
  String get myTeamTitle;

  /// No description provided for @yourTeamCode.
  ///
  /// In en, this message translates to:
  /// **'Your team code'**
  String get yourTeamCode;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get shareCode;

  /// No description provided for @editTeam.
  ///
  /// In en, this message translates to:
  /// **'Edit team'**
  String get editTeam;

  /// No description provided for @leaveTeam.
  ///
  /// In en, this message translates to:
  /// **'Leave team'**
  String get leaveTeam;

  /// No description provided for @leaveTeamConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave this team?'**
  String get leaveTeamConfirm;

  /// No description provided for @leaveTeamBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need a team code to join again.'**
  String get leaveTeamBody;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @noTeamYet.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in a team yet.'**
  String get noTeamYet;

  /// No description provided for @captainTag.
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get captainTag;

  /// No description provided for @playerTag.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerTag;

  /// No description provided for @teamSaved.
  ///
  /// In en, this message translates to:
  /// **'Team updated'**
  String get teamSaved;

  /// No description provided for @rankHash.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get rankHash;

  /// No description provided for @viewTeam.
  ///
  /// In en, this message translates to:
  /// **'View team'**
  String get viewTeam;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a game'**
  String get feedTitle;

  /// No description provided for @feedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open games posted by other teams.'**
  String get feedSubtitle;

  /// No description provided for @filterDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get filterDay;

  /// No description provided for @filterFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get filterFormat;

  /// No description provided for @anyDay.
  ///
  /// In en, this message translates to:
  /// **'Any day'**
  String get anyDay;

  /// No description provided for @anyFormat.
  ///
  /// In en, this message translates to:
  /// **'Any format'**
  String get anyFormat;

  /// No description provided for @asideLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}-a-side'**
  String asideLabel(String count);

  /// No description provided for @noGames.
  ///
  /// In en, this message translates to:
  /// **'No open games right now — check back soon.'**
  String get noGames;

  /// No description provided for @postGame.
  ///
  /// In en, this message translates to:
  /// **'Post a game'**
  String get postGame;

  /// No description provided for @onlyCaptainsPost.
  ///
  /// In en, this message translates to:
  /// **'Only captains can post games.'**
  String get onlyCaptainsPost;

  /// No description provided for @createGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Post a game'**
  String get createGameTitle;

  /// No description provided for @createGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Teams will bid to play you — you pick who.'**
  String get createGameSubtitle;

  /// No description provided for @gameFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get gameFormat;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Field / address'**
  String get fieldAddress;

  /// No description provided for @fieldAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stade de proximité, Bab Ezzouar'**
  String get fieldAddressHint;

  /// No description provided for @pickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick location on map'**
  String get pickLocation;

  /// No description provided for @tapToPickLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to set the field location'**
  String get tapToPickLocation;

  /// No description provided for @useThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get useThisLocation;

  /// No description provided for @searchPlace.
  ///
  /// In en, this message translates to:
  /// **'Search place or address'**
  String get searchPlace;

  /// No description provided for @movePinHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map to place the pin'**
  String get movePinHint;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable — enable location and try again'**
  String get locationPermissionDenied;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLocation;

  /// No description provided for @gameDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get gameDay;

  /// No description provided for @gameTime.
  ///
  /// In en, this message translates to:
  /// **'Kick-off time'**
  String get gameTime;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @gamePhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get gamePhotoOptional;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @gameDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get gameDetailsOptional;

  /// No description provided for @gameDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Anything the other team should know.'**
  String get gameDetailsHint;

  /// No description provided for @postGameBtn.
  ///
  /// In en, this message translates to:
  /// **'Post game'**
  String get postGameBtn;

  /// No description provided for @whenLabel.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get whenLabel;

  /// No description provided for @whereLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get whereLabel;

  /// No description provided for @kickoffLabel.
  ///
  /// In en, this message translates to:
  /// **'Kick-off'**
  String get kickoffLabel;

  /// No description provided for @hostTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'Host team'**
  String get hostTeamLabel;

  /// No description provided for @placeBid.
  ///
  /// In en, this message translates to:
  /// **'Place a bid'**
  String get placeBid;

  /// No description provided for @bidMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get bidMessage;

  /// No description provided for @bidMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Tell them about your team and why you want to play.'**
  String get bidMessageHint;

  /// No description provided for @bidPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get bidPhone;

  /// No description provided for @sendBid.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendBid;

  /// No description provided for @bidSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent! The host will get back to you.'**
  String get bidSent;

  /// No description provided for @alreadyBidTitle.
  ///
  /// In en, this message translates to:
  /// **'Request pending'**
  String get alreadyBidTitle;

  /// No description provided for @alreadyBidBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already asked to play this game. The host will choose soon.'**
  String get alreadyBidBody;

  /// No description provided for @thisIsYourGame.
  ///
  /// In en, this message translates to:
  /// **'This is your team\'s game.'**
  String get thisIsYourGame;

  /// No description provided for @needTeamToBid.
  ///
  /// In en, this message translates to:
  /// **'You need a team to send a request.'**
  String get needTeamToBid;

  /// No description provided for @gamePosted.
  ///
  /// In en, this message translates to:
  /// **'Game posted!'**
  String get gamePosted;

  /// No description provided for @myGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Games'**
  String get myGamesTitle;

  /// No description provided for @tabCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get tabCreated;

  /// No description provided for @tabJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get tabJoined;

  /// No description provided for @noCreated.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any games yet.'**
  String get noCreated;

  /// No description provided for @noJoined.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t been picked for a game yet.'**
  String get noJoined;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get statusMatched;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTitle;

  /// No description provided for @requestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} requests'**
  String requestsCount(int count);

  /// No description provided for @noBids.
  ///
  /// In en, this message translates to:
  /// **'No requests yet — share your game!'**
  String get noBids;

  /// No description provided for @pickTeam.
  ///
  /// In en, this message translates to:
  /// **'Pick this team'**
  String get pickTeam;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @picked.
  ///
  /// In en, this message translates to:
  /// **'Picked'**
  String get picked;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @pickConfirm.
  ///
  /// In en, this message translates to:
  /// **'Pick {team}?'**
  String pickConfirm(String team);

  /// No description provided for @pickConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'They become your opponent and the game is locked in.'**
  String get pickConfirmBody;

  /// No description provided for @opponentPicked.
  ///
  /// In en, this message translates to:
  /// **'Opponent picked! 🎉'**
  String get opponentPicked;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'vs'**
  String get vs;

  /// No description provided for @opponentLabel.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get opponentLabel;

  /// No description provided for @waitingBids.
  ///
  /// In en, this message translates to:
  /// **'Waiting for teams to send requests…'**
  String get waitingBids;

  /// No description provided for @manageGame.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageGame;

  /// No description provided for @cancelGame.
  ///
  /// In en, this message translates to:
  /// **'Cancel game'**
  String get cancelGame;

  /// No description provided for @cancelGameConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this game?'**
  String get cancelGameConfirm;

  /// No description provided for @cancelGameBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the game and all requests.'**
  String get cancelGameBody;

  /// No description provided for @gameCancelled.
  ///
  /// In en, this message translates to:
  /// **'Game cancelled'**
  String get gameCancelled;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @enterResult.
  ///
  /// In en, this message translates to:
  /// **'Enter the result'**
  String get enterResult;

  /// No description provided for @scoreFor.
  ///
  /// In en, this message translates to:
  /// **'{team} score'**
  String scoreFor(String team);

  /// No description provided for @saveResult.
  ///
  /// In en, this message translates to:
  /// **'Save result'**
  String get saveResult;

  /// No description provided for @resultSaved.
  ///
  /// In en, this message translates to:
  /// **'Result saved'**
  String get resultSaved;

  /// No description provided for @editResult.
  ///
  /// In en, this message translates to:
  /// **'Edit result'**
  String get editResult;

  /// No description provided for @resultPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the host to enter the result.'**
  String get resultPending;

  /// No description provided for @afterGameEnds.
  ///
  /// In en, this message translates to:
  /// **'You can enter the result after the game ends.'**
  String get afterGameEnds;

  /// No description provided for @rateHostTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate {team}'**
  String rateHostTitle(String team);

  /// No description provided for @rateHostBody.
  ///
  /// In en, this message translates to:
  /// **'How were they to play against — fair play, showing up, attitude?'**
  String get rateHostBody;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get submitRating;

  /// No description provided for @ratingSaved.
  ///
  /// In en, this message translates to:
  /// **'Thanks for rating!'**
  String get ratingSaved;

  /// No description provided for @youRated.
  ///
  /// In en, this message translates to:
  /// **'You rated {stars}★'**
  String youRated(int stars);

  /// No description provided for @rateHostCta.
  ///
  /// In en, this message translates to:
  /// **'Rate the host team'**
  String get rateHostCta;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @noContact.
  ///
  /// In en, this message translates to:
  /// **'No contact available'**
  String get noContact;

  /// No description provided for @profileTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTabTitle;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirm;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanel;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminTitle;

  /// No description provided for @statsTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get statsTeams;

  /// No description provided for @statsGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get statsGames;

  /// No description provided for @statsPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get statsPlayers;

  /// No description provided for @manageAds.
  ///
  /// In en, this message translates to:
  /// **'Ads & announcements'**
  String get manageAds;

  /// No description provided for @addAd.
  ///
  /// In en, this message translates to:
  /// **'New ad'**
  String get addAd;

  /// No description provided for @adTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adTitleField;

  /// No description provided for @adBodyField.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get adBodyField;

  /// No description provided for @adLinkField.
  ///
  /// In en, this message translates to:
  /// **'Link (optional)'**
  String get adLinkField;

  /// No description provided for @adActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adActive;

  /// No description provided for @adSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get adSaved;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No ads yet.'**
  String get noAds;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLink;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account.'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few details to get you started.'**
  String get registerSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @noAccountCta.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccountCta;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get manageUsers;

  /// No description provided for @joinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedOn(String date);

  /// No description provided for @editWindowNote.
  ///
  /// In en, this message translates to:
  /// **'You can edit the score for 10 minutes after saving. After that it\'s final.'**
  String get editWindowNote;

  /// No description provided for @editWindowLeft.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min left to edit'**
  String editWindowLeft(int minutes);

  /// No description provided for @resultFinal.
  ///
  /// In en, this message translates to:
  /// **'This result is final.'**
  String get resultFinal;

  /// No description provided for @scoreOpensIn.
  ///
  /// In en, this message translates to:
  /// **'Score entry opens ~{minutes} min after kick-off.'**
  String scoreOpensIn(int minutes);

  /// No description provided for @sectionLive.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get sectionLive;

  /// No description provided for @sectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get sectionUpcoming;

  /// No description provided for @sectionFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get sectionFinished;

  /// No description provided for @liveTag.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveTag;

  /// No description provided for @reviewComment.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get reviewComment;

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'How was the match / the host team?'**
  String get reviewCommentHint;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviews;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
