// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Street Football DZ';

  @override
  String get welcomeTitle => 'Le foot de rue,\nà l\'algérienne.';

  @override
  String get welcomeSubtitle =>
      'Crée ton équipe, défie le quartier, grimpe dans le championnat national.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get iHaveAccount => 'J\'ai déjà un compte';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get loading => 'Chargement…';

  @override
  String get retry => 'Réessayer';

  @override
  String get fieldRequired => 'Requis';

  @override
  String get navHome => 'Accueil';

  @override
  String get navMyGames => 'Mes matchs';

  @override
  String get navLeague => 'Classement';

  @override
  String get navMyTeam => 'Mon équipe';

  @override
  String get navProfile => 'Profil';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get language => 'Langue';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get phoneTitle => 'Entre ton numéro';

  @override
  String get phoneSubtitle => 'On t\'envoie un code par SMS pour te connecter.';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get phoneHint => '5XX XX XX XX';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get invalidPhone => 'Entre un numéro valide';

  @override
  String get otpTitle => 'Vérifie ton numéro';

  @override
  String otpSubtitle(String phone) {
    return 'Entre le code à 6 chiffres envoyé au $phone';
  }

  @override
  String get codeLabel => 'Code de vérification';

  @override
  String get verify => 'Vérifier';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String resendIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get profileTitle => 'Tes informations';

  @override
  String get profileSubtitle =>
      'Pour que les équipes sachent contre qui elles jouent.';

  @override
  String get fullName => 'Nom complet';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get selectDate => 'Choisir une date';

  @override
  String get cityWilaya => 'Ville (wilaya)';

  @override
  String get selectCity => 'Choisis ta wilaya';

  @override
  String get ageTooYoung => 'Tu dois avoir au moins 13 ans';

  @override
  String get roleTitle => 'Comment veux-tu jouer ?';

  @override
  String get roleSubtitle =>
      'Tu ne pourras pas changer plus tard, choisis bien.';

  @override
  String get captain => 'Capitaine';

  @override
  String get captainDesc =>
      'Crée une équipe, publie des matchs et choisis les adversaires.';

  @override
  String get player => 'Joueur';

  @override
  String get playerDesc => 'Rejoins une équipe existante avec son code.';

  @override
  String get createTeamTitle => 'Crée ton équipe';

  @override
  String get createTeamSubtitle =>
      'Ton équipe rejoint le championnat algérien immédiatement.';

  @override
  String get teamName => 'Nom de l\'équipe';

  @override
  String get teamLogoOptional => 'Logo de l\'équipe (optionnel)';

  @override
  String get addLogo => 'Ajouter un logo';

  @override
  String get ageRangeOptional => 'Tranche d\'âge (optionnel)';

  @override
  String get minAge => 'Âge min';

  @override
  String get maxAge => 'Âge max';

  @override
  String get teamDetailsOptional => 'À propos de l\'équipe (optionnel)';

  @override
  String get createTeamBtn => 'Créer l\'équipe';

  @override
  String get joinTeamTitle => 'Rejoindre une équipe';

  @override
  String get joinTeamSubtitle =>
      'Demande le code de l\'équipe à ton capitaine.';

  @override
  String get teamCodeLabel => 'Code de l\'équipe';

  @override
  String get joinTeamBtn => 'Rejoindre';

  @override
  String get teamCreatedTitle => 'Équipe créée ! 🎉';

  @override
  String get teamCreatedBody =>
      'Partage ce code avec tes joueurs pour qu\'ils rejoignent ton équipe :';

  @override
  String get copyCode => 'Copier le code';

  @override
  String get codeCopied => 'Code copié';

  @override
  String get letsGo => 'C\'est parti';

  @override
  String get leagueTitle => 'Championnat algérien';

  @override
  String get leagueSubtitle => 'Toutes les équipes, classées par points.';

  @override
  String get allWilayas => 'Toutes les wilayas';

  @override
  String get noTeamsYet => 'Aucune équipe — sois le premier à en créer une !';

  @override
  String get pts => 'Pts';

  @override
  String get playedShort => 'J';

  @override
  String get ratingLabel => 'Note';

  @override
  String get unrated => 'Pas encore noté';

  @override
  String get statPlayed => 'Joués';

  @override
  String get statWon => 'Gagnés';

  @override
  String get statDrawn => 'Nuls';

  @override
  String get statLost => 'Perdus';

  @override
  String get captainLabel => 'Capitaine';

  @override
  String get ageRangeTitle => 'Tranche d\'âge';

  @override
  String get rosterTitle => 'Effectif';

  @override
  String membersCount(int count) {
    return '$count membres';
  }

  @override
  String get recentResults => 'Derniers résultats';

  @override
  String get noResultsYet => 'Aucun match joué pour l\'instant.';

  @override
  String get myTeamTitle => 'Mon équipe';

  @override
  String get yourTeamCode => 'Code de ton équipe';

  @override
  String get shareCode => 'Partager le code';

  @override
  String get editTeam => 'Modifier l\'équipe';

  @override
  String get leaveTeam => 'Quitter l\'équipe';

  @override
  String get leaveTeamConfirm => 'Quitter cette équipe ?';

  @override
  String get leaveTeamBody => 'Il te faudra un code pour rejoindre à nouveau.';

  @override
  String get leave => 'Quitter';

  @override
  String get noTeamYet => 'Tu n\'es dans aucune équipe.';

  @override
  String get captainTag => 'Capitaine';

  @override
  String get playerTag => 'Joueur';

  @override
  String get teamSaved => 'Équipe mise à jour';

  @override
  String get rankHash => '#';

  @override
  String get viewTeam => 'Voir l\'équipe';

  @override
  String get feedTitle => 'Trouver un match';

  @override
  String get feedSubtitle => 'Matchs publiés par d\'autres équipes.';

  @override
  String get filterDay => 'Jour';

  @override
  String get filterFormat => 'Format';

  @override
  String get anyDay => 'Tous les jours';

  @override
  String get anyFormat => 'Tous formats';

  @override
  String asideLabel(String count) {
    return '$count contre $count';
  }

  @override
  String get noGames => 'Aucun match ouvert pour l\'instant — reviens bientôt.';

  @override
  String get postGame => 'Publier un match';

  @override
  String get onlyCaptainsPost =>
      'Seuls les capitaines peuvent publier des matchs.';

  @override
  String get createGameTitle => 'Publier un match';

  @override
  String get createGameSubtitle =>
      'Les équipes proposeront de jouer — c\'est toi qui choisis.';

  @override
  String get gameFormat => 'Format';

  @override
  String get fieldAddress => 'Terrain / adresse';

  @override
  String get fieldAddressHint => 'ex. Stade de proximité, Bab Ezzouar';

  @override
  String get gameDay => 'Jour';

  @override
  String get gameTime => 'Heure du coup d\'envoi';

  @override
  String get selectTime => 'Choisir l\'heure';

  @override
  String get durationLabel => 'Durée';

  @override
  String get minutesShort => 'min';

  @override
  String get gamePhotoOptional => 'Photo (optionnel)';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get gameDetailsOptional => 'Détails (optionnel)';

  @override
  String get gameDetailsHint => 'Tout ce que l\'autre équipe doit savoir.';

  @override
  String get postGameBtn => 'Publier le match';

  @override
  String get whenLabel => 'Quand';

  @override
  String get whereLabel => 'Où';

  @override
  String get kickoffLabel => 'Coup d\'envoi';

  @override
  String get hostTeamLabel => 'Équipe hôte';

  @override
  String get placeBid => 'Proposer ton équipe';

  @override
  String get bidMessage => 'Ton message';

  @override
  String get bidMessageHint =>
      'Parle de ton équipe et explique pourquoi tu veux jouer.';

  @override
  String get bidPhone => 'Téléphone de contact';

  @override
  String get sendBid => 'Envoyer la demande';

  @override
  String get bidSent => 'Demande envoyée ! L\'hôte te répondra.';

  @override
  String get alreadyBidTitle => 'Demande en attente';

  @override
  String get alreadyBidBody =>
      'Tu as déjà demandé à jouer ce match. L\'hôte choisira bientôt.';

  @override
  String get thisIsYourGame => 'C\'est le match de ton équipe.';

  @override
  String get needTeamToBid => 'Il te faut une équipe pour envoyer une demande.';

  @override
  String get gamePosted => 'Match publié !';

  @override
  String get myGamesTitle => 'Mes matchs';

  @override
  String get tabCreated => 'Créés';

  @override
  String get tabJoined => 'Rejoints';

  @override
  String get noCreated => 'Tu n\'as publié aucun match.';

  @override
  String get noJoined => 'Tu n\'as encore été choisi pour aucun match.';

  @override
  String get statusOpen => 'Ouvert';

  @override
  String get statusMatched => 'Confirmé';

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get requestsTitle => 'Demandes';

  @override
  String requestsCount(int count) {
    return '$count demandes';
  }

  @override
  String get noBids => 'Aucune demande — partage ton match !';

  @override
  String get pickTeam => 'Choisir cette équipe';

  @override
  String get decline => 'Refuser';

  @override
  String get picked => 'Choisi';

  @override
  String get call => 'Appeler';

  @override
  String pickConfirm(String team) {
    return 'Choisir $team ?';
  }

  @override
  String get pickConfirmBody =>
      'Elle devient ton adversaire et le match est verrouillé.';

  @override
  String get opponentPicked => 'Adversaire choisi ! 🎉';

  @override
  String get vs => 'vs';

  @override
  String get opponentLabel => 'Adversaire';

  @override
  String get waitingBids => 'En attente des demandes des équipes…';

  @override
  String get manageGame => 'Gérer';

  @override
  String get cancelGame => 'Annuler le match';

  @override
  String get cancelGameConfirm => 'Annuler ce match ?';

  @override
  String get cancelGameBody => 'Cela supprime le match et toutes les demandes.';

  @override
  String get gameCancelled => 'Match annulé';

  @override
  String get deleteLabel => 'Supprimer';

  @override
  String get enterResult => 'Saisir le résultat';

  @override
  String scoreFor(String team) {
    return 'Score de $team';
  }

  @override
  String get saveResult => 'Enregistrer le résultat';

  @override
  String get resultSaved => 'Résultat enregistré';

  @override
  String get editResult => 'Modifier le résultat';

  @override
  String get resultPending => 'En attente du résultat de l\'hôte.';

  @override
  String get afterGameEnds =>
      'Tu pourras saisir le résultat après la fin du match.';

  @override
  String rateHostTitle(String team) {
    return 'Noter $team';
  }

  @override
  String get rateHostBody =>
      'Comment était le match — fair-play, présence, attitude ?';

  @override
  String get submitRating => 'Envoyer la note';

  @override
  String get ratingSaved => 'Merci pour ta note !';

  @override
  String youRated(int stars) {
    return 'Tu as noté $stars★';
  }

  @override
  String get rateHostCta => 'Noter l\'équipe hôte';

  @override
  String get contactLabel => 'Contact';

  @override
  String get noContact => 'Aucun contact disponible';

  @override
  String get profileTabTitle => 'Profil';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get theme => 'Thème';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutConfirm => 'Se déconnecter ?';

  @override
  String get aboutApp => 'À propos';

  @override
  String get appVersion => 'Version';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification.';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get adminPanel => 'Panneau admin';

  @override
  String get adminTitle => 'Admin';

  @override
  String get statsTeams => 'Équipes';

  @override
  String get statsGames => 'Matchs';

  @override
  String get statsPlayers => 'Joueurs';

  @override
  String get manageAds => 'Annonces & pubs';

  @override
  String get addAd => 'Nouvelle annonce';

  @override
  String get adTitleField => 'Titre';

  @override
  String get adBodyField => 'Message';

  @override
  String get adLinkField => 'Lien (optionnel)';

  @override
  String get adActive => 'Actif';

  @override
  String get adSaved => 'Enregistré';

  @override
  String get noAds => 'Aucune annonce.';

  @override
  String get edit => 'Modifier';

  @override
  String get openLink => 'Ouvrir';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connecte-toi à ton compte.';

  @override
  String get registerTitle => 'Crée ton compte';

  @override
  String get registerSubtitle => 'Quelques infos pour commencer.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'toi@exemple.com';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String get createAccount => 'Créer le compte';

  @override
  String get noAccountCta => 'Nouveau ? Crée un compte';

  @override
  String get invalidEmail => 'Entre un e-mail valide';

  @override
  String get passwordTooShort => 'Au moins 6 caractères';

  @override
  String get manageUsers => 'Utilisateurs';

  @override
  String joinedOn(String date) {
    return 'Inscrit le $date';
  }

  @override
  String get editWindowNote =>
      'Tu peux modifier le score pendant 10 minutes après l\'enregistrement. Ensuite c\'est définitif.';

  @override
  String editWindowLeft(int minutes) {
    return '~$minutes min pour modifier';
  }

  @override
  String get resultFinal => 'Ce résultat est définitif.';

  @override
  String get reviewComment => 'Commentaire (optionnel)';

  @override
  String get reviewCommentHint => 'Comment était le match / l\'équipe hôte ?';

  @override
  String get reviewsTitle => 'Avis';

  @override
  String get noReviews => 'Aucun avis pour l\'instant.';
}
