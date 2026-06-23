// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'كرة الشارع';

  @override
  String get welcomeTitle => 'كرة القدم في الشارع،\nعلى الطريقة الجزائرية.';

  @override
  String get welcomeSubtitle => 'كوّن فريقك، تحدّى الحي، وتسلّق الدوري الوطني.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get iHaveAccount => 'لديّ حساب بالفعل';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get fieldRequired => 'مطلوب';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMyGames => 'مبارياتي';

  @override
  String get navLeague => 'الترتيب';

  @override
  String get navMyTeam => 'فريقي';

  @override
  String get navProfile => 'حسابي';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get phoneTitle => 'أدخل رقم هاتفك';

  @override
  String get phoneSubtitle => 'سنرسل لك رمزاً عبر رسالة قصيرة لتسجيل الدخول.';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneHint => '5XX XX XX XX';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get invalidPhone => 'أدخل رقم هاتف صحيح';

  @override
  String get otpTitle => 'تأكيد رقمك';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكوّن من 6 أرقام المُرسَل إلى $phone';
  }

  @override
  String get codeLabel => 'رمز التأكيد';

  @override
  String get verify => 'تأكيد';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ث';
  }

  @override
  String get profileTitle => 'معلوماتك';

  @override
  String get profileSubtitle => 'حتى تعرف الفرق مع من تلعب.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get cityWilaya => 'المدينة (الولاية)';

  @override
  String get selectCity => 'اختر ولايتك';

  @override
  String get ageTooYoung => 'يجب أن يكون عمرك 13 سنة على الأقل';

  @override
  String get roleTitle => 'كيف تريد أن تلعب؟';

  @override
  String get roleSubtitle => 'لا يمكنك تغيير هذا لاحقاً، فاختر بعناية.';

  @override
  String get captain => 'كابتن';

  @override
  String get captainDesc => 'أنشئ فريقاً، انشر المباريات واختر الخصوم.';

  @override
  String get player => 'لاعب';

  @override
  String get playerDesc => 'انضم إلى فريق موجود باستخدام رمزه.';

  @override
  String get createTeamTitle => 'أنشئ فريقك';

  @override
  String get createTeamSubtitle => 'ينضم فريقك إلى الدوري الجزائري فوراً.';

  @override
  String get teamName => 'اسم الفريق';

  @override
  String get teamLogoOptional => 'شعار الفريق (اختياري)';

  @override
  String get addLogo => 'أضف شعاراً';

  @override
  String get ageRangeOptional => 'الفئة العمرية (اختياري)';

  @override
  String get minAge => 'أصغر سن';

  @override
  String get maxAge => 'أكبر سن';

  @override
  String get teamDetailsOptional => 'عن الفريق (اختياري)';

  @override
  String get createTeamBtn => 'إنشاء الفريق';

  @override
  String get joinTeamTitle => 'انضم إلى فريق';

  @override
  String get joinTeamSubtitle => 'اطلب رمز الفريق من الكابتن.';

  @override
  String get teamCodeLabel => 'رمز الفريق';

  @override
  String get joinTeamBtn => 'انضمام';

  @override
  String get teamCreatedTitle => 'تم إنشاء الفريق! 🎉';

  @override
  String get teamCreatedBody =>
      'شارك هذا الرمز مع لاعبيك حتى ينضموا إلى فريقك:';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get codeCopied => 'تم نسخ الرمز';

  @override
  String get letsGo => 'هيا بنا';

  @override
  String get leagueTitle => 'الدوري الجزائري';

  @override
  String get leagueSubtitle => 'كل الفرق، مرتّبة حسب النقاط.';

  @override
  String get allWilayas => 'كل الولايات';

  @override
  String get noTeamsYet => 'لا توجد فرق بعد — كن أول من ينشئ فريقاً!';

  @override
  String get pts => 'نقطة';

  @override
  String get playedShort => 'ل';

  @override
  String get ratingLabel => 'التقييم';

  @override
  String get unrated => 'لم يُقيَّم بعد';

  @override
  String get statPlayed => 'لعب';

  @override
  String get statWon => 'فاز';

  @override
  String get statDrawn => 'تعادل';

  @override
  String get statLost => 'خسر';

  @override
  String get captainLabel => 'الكابتن';

  @override
  String get ageRangeTitle => 'الفئة العمرية';

  @override
  String get rosterTitle => 'التشكيلة';

  @override
  String membersCount(int count) {
    return '$count أعضاء';
  }

  @override
  String get recentResults => 'آخر النتائج';

  @override
  String get noResultsYet => 'لم تُلعب أي مباراة بعد.';

  @override
  String get myTeamTitle => 'فريقي';

  @override
  String get yourTeamCode => 'رمز فريقك';

  @override
  String get shareCode => 'مشاركة الرمز';

  @override
  String get editTeam => 'تعديل الفريق';

  @override
  String get leaveTeam => 'مغادرة الفريق';

  @override
  String get leaveTeamConfirm => 'مغادرة هذا الفريق؟';

  @override
  String get leaveTeamBody => 'ستحتاج إلى رمز فريق للانضمام مجدداً.';

  @override
  String get leave => 'مغادرة';

  @override
  String get noTeamYet => 'أنت لست في فريق بعد.';

  @override
  String get captainTag => 'كابتن';

  @override
  String get playerTag => 'لاعب';

  @override
  String get teamSaved => 'تم تحديث الفريق';

  @override
  String get rankHash => '#';

  @override
  String get viewTeam => 'عرض الفريق';

  @override
  String get feedTitle => 'ابحث عن مباراة';

  @override
  String get feedSubtitle => 'مباريات منشورة من فرق أخرى.';

  @override
  String get filterDay => 'اليوم';

  @override
  String get filterFormat => 'النمط';

  @override
  String get anyDay => 'أي يوم';

  @override
  String get anyFormat => 'أي نمط';

  @override
  String asideLabel(String count) {
    return '$count ضد $count';
  }

  @override
  String get noGames => 'لا توجد مباريات متاحة الآن — عُد قريباً.';

  @override
  String get postGame => 'انشر مباراة';

  @override
  String get onlyCaptainsPost => 'الكباتن فقط يمكنهم نشر المباريات.';

  @override
  String get createGameTitle => 'انشر مباراة';

  @override
  String get createGameSubtitle => 'ستتقدم الفرق للعب ضدك — أنت تختار.';

  @override
  String get gameFormat => 'النمط';

  @override
  String get fieldAddress => 'الملعب / العنوان';

  @override
  String get fieldAddressHint => 'مثال: ملعب الجوار، باب الزوار';

  @override
  String get gameDay => 'اليوم';

  @override
  String get gameTime => 'وقت البداية';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get durationLabel => 'المدة';

  @override
  String get minutesShort => 'دقيقة';

  @override
  String get gamePhotoOptional => 'صورة (اختياري)';

  @override
  String get addPhoto => 'أضف صورة';

  @override
  String get gameDetailsOptional => 'تفاصيل (اختياري)';

  @override
  String get gameDetailsHint => 'أي شيء يجب أن يعرفه الفريق الآخر.';

  @override
  String get postGameBtn => 'نشر المباراة';

  @override
  String get whenLabel => 'متى';

  @override
  String get whereLabel => 'أين';

  @override
  String get kickoffLabel => 'البداية';

  @override
  String get hostTeamLabel => 'الفريق المضيف';

  @override
  String get placeBid => 'قدّم طلباً';

  @override
  String get bidMessage => 'رسالتك';

  @override
  String get bidMessageHint => 'أخبرهم عن فريقك ولماذا تريد اللعب.';

  @override
  String get bidPhone => 'هاتف للتواصل';

  @override
  String get sendBid => 'إرسال الطلب';

  @override
  String get bidSent => 'تم إرسال الطلب! سيرد عليك المضيف.';

  @override
  String get alreadyBidTitle => 'الطلب قيد الانتظار';

  @override
  String get alreadyBidBody =>
      'لقد طلبت اللعب في هذه المباراة بالفعل. سيختار المضيف قريباً.';

  @override
  String get thisIsYourGame => 'هذه مباراة فريقك.';

  @override
  String get needTeamToBid => 'تحتاج إلى فريق لإرسال طلب.';

  @override
  String get gamePosted => 'تم نشر المباراة!';

  @override
  String get myGamesTitle => 'مبارياتي';

  @override
  String get tabCreated => 'أنشأتها';

  @override
  String get tabJoined => 'انضممت إليها';

  @override
  String get noCreated => 'لم تنشر أي مباراة بعد.';

  @override
  String get noJoined => 'لم يتم اختيارك لأي مباراة بعد.';

  @override
  String get statusOpen => 'مفتوحة';

  @override
  String get statusMatched => 'محددة';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get requestsTitle => 'الطلبات';

  @override
  String requestsCount(int count) {
    return '$count طلبات';
  }

  @override
  String get noBids => 'لا توجد طلبات بعد — شارك مباراتك!';

  @override
  String get pickTeam => 'اختر هذا الفريق';

  @override
  String get decline => 'رفض';

  @override
  String get picked => 'تم الاختيار';

  @override
  String get call => 'اتصال';

  @override
  String pickConfirm(String team) {
    return 'اختيار $team؟';
  }

  @override
  String get pickConfirmBody => 'سيصبح خصمك وتُقفل المباراة.';

  @override
  String get opponentPicked => 'تم اختيار الخصم! 🎉';

  @override
  String get vs => 'ضد';

  @override
  String get opponentLabel => 'الخصم';

  @override
  String get waitingBids => 'في انتظار طلبات الفرق…';

  @override
  String get manageGame => 'إدارة';

  @override
  String get cancelGame => 'إلغاء المباراة';

  @override
  String get cancelGameConfirm => 'إلغاء هذه المباراة؟';

  @override
  String get cancelGameBody => 'سيؤدي ذلك إلى حذف المباراة وكل الطلبات.';

  @override
  String get gameCancelled => 'تم إلغاء المباراة';

  @override
  String get deleteLabel => 'حذف';

  @override
  String get enterResult => 'أدخل النتيجة';

  @override
  String scoreFor(String team) {
    return 'نتيجة $team';
  }

  @override
  String get saveResult => 'حفظ النتيجة';

  @override
  String get resultSaved => 'تم حفظ النتيجة';

  @override
  String get editResult => 'تعديل النتيجة';

  @override
  String get resultPending => 'في انتظار إدخال المضيف للنتيجة.';

  @override
  String get afterGameEnds => 'يمكنك إدخال النتيجة بعد انتهاء المباراة.';

  @override
  String rateHostTitle(String team) {
    return 'قيّم $team';
  }

  @override
  String get rateHostBody =>
      'كيف كان اللعب ضدهم — اللعب النظيف، الحضور، الأخلاق؟';

  @override
  String get submitRating => 'إرسال التقييم';

  @override
  String get ratingSaved => 'شكراً على تقييمك!';

  @override
  String youRated(int stars) {
    return 'قيّمت $stars★';
  }

  @override
  String get rateHostCta => 'قيّم الفريق المضيف';

  @override
  String get contactLabel => 'التواصل';

  @override
  String get noContact => 'لا يوجد رقم للتواصل';

  @override
  String get profileTabTitle => 'حسابي';

  @override
  String get roleLabel => 'الدور';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'النظام';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirm => 'تسجيل الخروج؟';

  @override
  String get aboutApp => 'حول';

  @override
  String get appVersion => 'الإصدار';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات بعد.';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get adminPanel => 'لوحة الإدارة';

  @override
  String get adminTitle => 'الإدارة';

  @override
  String get statsTeams => 'الفرق';

  @override
  String get statsGames => 'المباريات';

  @override
  String get statsPlayers => 'اللاعبون';

  @override
  String get manageAds => 'الإعلانات والإشعارات';

  @override
  String get addAd => 'إعلان جديد';

  @override
  String get adTitleField => 'العنوان';

  @override
  String get adBodyField => 'الرسالة';

  @override
  String get adLinkField => 'رابط (اختياري)';

  @override
  String get adActive => 'مفعّل';

  @override
  String get adSaved => 'تم الحفظ';

  @override
  String get noAds => 'لا توجد إعلانات بعد.';

  @override
  String get edit => 'تعديل';

  @override
  String get openLink => 'فتح';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول إلى حسابك.';

  @override
  String get registerTitle => 'أنشئ حسابك';

  @override
  String get registerSubtitle => 'بعض المعلومات للبدء.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get noAccountCta => 'جديد هنا؟ أنشئ حساباً';

  @override
  String get invalidEmail => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get passwordTooShort => '6 أحرف على الأقل';

  @override
  String get manageUsers => 'المستخدمون';

  @override
  String joinedOn(String date) {
    return 'انضم في $date';
  }
}
