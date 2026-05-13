// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أوروك موتورز';

  @override
  String get appTagline => 'مركز الصيانة قسم السمكر والصبغ';

  @override
  String get appVersion => 'v1.0.0 • أوروك موتورز';

  @override
  String get commonOk => 'حسناً';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonSkip => 'تخطي';

  @override
  String get commonSend => 'إرسال';

  @override
  String get commonSubmit => 'إرسال';

  @override
  String get commonLoading => 'جارٍ التحميل...';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get commonOr => 'أو';

  @override
  String get commonRequired => 'مطلوب';

  @override
  String get commonOptional => 'اختياري';

  @override
  String get commonUpgrade => 'ترقية';

  @override
  String get commonViewAll => 'عرض الكل';

  @override
  String get commonUpload => 'رفع';

  @override
  String get commonRetake => 'إعادة الالتقاط';

  @override
  String get commonPrint => 'طباعة';

  @override
  String get commonMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get commonSendRequest => 'إرسال الطلب';

  @override
  String get commonAddPhoto => 'إضافة صورة';

  @override
  String get commonErrorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get authSuspendedTitle => 'تم تعليق حسابك';

  @override
  String get authSuspendedMessage =>
      'تم تعليق حسابك. يرجى التواصل مع الدعم لمزيد من المعلومات.';

  @override
  String get authRejectedTitle => 'تم رفض حسابك';

  @override
  String get authRejectedMessage =>
      'تم رفض حسابك. يرجى التواصل مع الدعم لمزيد من التفاصيل.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAccidents => 'الحوادث';

  @override
  String get navAppointments => 'المواعيد';

  @override
  String get navPayment => 'الدفع';

  @override
  String get navProfile => 'الملف';

  @override
  String get loginWelcomeBack => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول إلى حسابك';

  @override
  String get loginPhone => 'رقم الموبايل';

  @override
  String get loginPhoneHint => '+964 7xx xxx xxxx';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginSignInButton => 'تسجيل الدخول';

  @override
  String get loginNoAccount => 'لا تملك حساباً؟';

  @override
  String get loginRegister => 'إنشاء حساب';

  @override
  String get loginContinueAsGuest => 'تصفح كزائر';

  @override
  String get guestBannerMessage => 'أنت تتصفح كزائر';

  @override
  String get guestBannerAction => 'تسجيل الدخول';

  @override
  String get guestLoginRequired => 'تسجيل الدخول مطلوب';

  @override
  String get guestLoginRequiredMessage =>
      'يجب تسجيل الدخول للوصول إلى هذه الميزة.';

  @override
  String get guestLoginButton => 'تسجيل الدخول';

  @override
  String get registerTitle => 'أنشئ حسابك';

  @override
  String get registerSubtitle => 'أملأ بياناتك للبدء.';

  @override
  String get registerFullName => 'الاسم الكامل';

  @override
  String get registerFullNameHint => 'مثال: أحمد الراشدي';

  @override
  String get registerPhone => 'رقم الموبايل';

  @override
  String get registerPhoneHint => '+964 7xx xxx xxxx';

  @override
  String get registerEmailOptional => 'البريد الإلكتروني (اختياري)';

  @override
  String get registerEmailHint => 'you@email.com';

  @override
  String get registerPassword => 'كلمة المرور';

  @override
  String get registerConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get registerNextVerify => 'التالي — التحقق من الموبايل';

  @override
  String get registerAlreadyHaveAccount => 'هل لديك حساب؟';

  @override
  String get registerSignIn => 'تسجيل الدخول';

  @override
  String get otpTitle => 'التحقق من رقمك';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكوّن من 6 أرقام المُرسَل إلى $phone';
  }

  @override
  String get otpEnterCode => 'يرجى إدخال الرمز المكوّن من 6 أرقام';

  @override
  String get otpInvalidCode => 'رمز غير صحيح. حاول مجدداً.';

  @override
  String get otpDidntReceive => 'لم تستلم الرمز؟ ';

  @override
  String otpResendIn(int seconds) {
    return 'إعادة الإرسال خلال $secondsث';
  }

  @override
  String get otpResend => 'إعادة الإرسال';

  @override
  String get idUploadTitle => 'رفع بطاقة الهوية';

  @override
  String get idUploadBothSidesRequired => 'يرجى رفع كلا وجهَي بطاقة الهوية';

  @override
  String get idUploadInstructions =>
      'يرجى رفع صور واضحة لبطاقة الهوية الوطنية العراقية. كلا الوجهين مطلوبان.';

  @override
  String get idUploadFrontSubtitle => 'التقط صورة للوجه الأمامي';

  @override
  String get idUploadBackSubtitle => 'التقط صورة للوجه الخلفي';

  @override
  String get idUploadSubmit => 'تقديم الطلب';

  @override
  String get idUploadDisclaimer =>
      'بطاقتك محفوظة بشكل آمن ولا يطّلع عليها سوى فريق الإدارة.';

  @override
  String get idUploadSuccess => 'تم رفع الصورة بنجاح';

  @override
  String get idUploadRetake => 'إعادة الالتقاط';

  @override
  String get pendingTitle => 'طلبك قيد المراجعة';

  @override
  String get pendingSubtitle => 'يراجع فريقنا طلبك حالياً.';

  @override
  String get pendingStep1 => 'تم إنشاء الحساب';

  @override
  String get pendingStep2 => 'تم تقديم التحقق من الهوية';

  @override
  String get pendingStep3 => 'مراجعة الإدارة (1–2 يوم عمل)';

  @override
  String get pendingStep4 => 'تفعيل الحساب';

  @override
  String get pendingSmsNotification =>
      'ستصلك رسالة SMS عند الموافقة على حسابك.';

  @override
  String get pendingBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String get splashTagline => 'مركز الصيانة قسم السمكر والصبغ';

  @override
  String get onboard1Title => 'أبلّغ عن الحوادث بسهولة';

  @override
  String get onboard1Desc => 'قدّم تقارير الحوادث مع الصور مباشرةً من هاتفك.';

  @override
  String get onboard2Title => 'تابع إصلاحاتك';

  @override
  String get onboard2Desc =>
      'تابع كل خطوة في الإصلاح في الوقت الفعلي وشاهد تاريخ الصيانة الكامل.';

  @override
  String get onboard3Title => 'إدارة المدفوعات';

  @override
  String get onboard3Desc => 'ادفع اشتراكك الشهري وتصفح تاريخ الدفعات الكامل.';

  @override
  String get onboardSkip => 'تخطي';

  @override
  String get onboardGetStarted => 'ابدأ الآن';

  @override
  String get onboardAlreadyHaveAccount => 'هل لديك حساب؟';

  @override
  String get onboardSignIn => 'تسجيل الدخول';

  @override
  String get garageTitle => 'الكراج';

  @override
  String get garageMyCarsSectionTitle => 'سياراتي';

  @override
  String garageCarsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سيارات',
      one: 'سيارة واحدة',
      zero: 'لا توجد سيارات',
    );
    return '$_temp0';
  }

  @override
  String get garageNoCarYet => 'لا توجد سيارات مضافة بعد';

  @override
  String get garageAddCarButton => 'إضافة سيارة جديدة';

  @override
  String garageSubActive(String planName) {
    return '$planName نشط';
  }

  @override
  String get garageNoSubscription => 'بدون اشتراك';

  @override
  String get garageSelectCar => 'اختر سيارة لعرض التفاصيل';

  @override
  String get carAddTitle => 'أضف سيارتك';

  @override
  String get carEditTitle => 'طلب تعديل بيانات السيارة';

  @override
  String get carMakeLabel => 'الشركة المصنّعة *';

  @override
  String get carMakeHint => 'مثال: تويوتا';

  @override
  String get carModelLabel => 'الموديل *';

  @override
  String get carModelHint => 'مثال: كامري';

  @override
  String get carYearLabel => 'سنة الصنع *';

  @override
  String get carYearHint => 'مثال: 2020';

  @override
  String get carColorLabel => 'اللون *';

  @override
  String get carColorHint => 'مثال: أبيض';

  @override
  String get carPlateLabel => 'رقم اللوحة *';

  @override
  String get carPlateHint => 'مثال: 12345 - بغداد';

  @override
  String get carSaveSuccess => 'تم حفظ بيانات السيارة بنجاح';

  @override
  String get carNoChanges => 'لم تقم بتغيير أي معلومات';

  @override
  String get carChangeRequestSentTitle => 'تم إرسال الطلب';

  @override
  String get carChangeRequestSentContent =>
      'تم إرسال طلب تعديل بيانات سيارتك إلى الإدارة. ستُحدَّث البيانات بعد موافقة الإدارة.';

  @override
  String get carChangesLabel => 'التغييرات المطلوبة:';

  @override
  String get carPendingRequestWarning => 'يوجد طلب تعديل قيد المراجعة';

  @override
  String get carSubscriptionActivatedBanner =>
      'تم تفعيل اشتراكك! أضف بيانات سيارتك الآن لاستكمال ملفك.';

  @override
  String get carEditModeNote =>
      'التعديلات لا تُطبَّق مباشرةً — سيتم إرسالها كطلب إلى الإدارة للمراجعة.';

  @override
  String get carAddButton => 'إضافة السيارة';

  @override
  String get carSendChangeButton => 'إرسال طلب التعديل';

  @override
  String get carSkipButton => 'تخطي الآن';

  @override
  String get carPhotoAddLabel => 'أضف صورة السيارة';

  @override
  String get carPhotoHint => 'تساعدك على التمييز بين سياراتك';

  @override
  String get carPhotoChangeLabel => 'تغيير الصورة';

  @override
  String get subscriptionTitle => 'خطط الاشتراك';

  @override
  String get subscriptionSubtitle =>
      'اختر الخطة التي تناسبك. يمكنك الترقية في أي وقت.';

  @override
  String get subscriptionPerMonth => '/ شهرياً';

  @override
  String get subscriptionCurrentPlan => 'خطتك الحالية';

  @override
  String get subscriptionMostPopular => 'الأكثر طلباً';

  @override
  String get subscriptionCoveredPartsTitle => 'ما يشمله التصليح';

  @override
  String get subscriptionPaymentPeriodTitle => 'طريقة الدفع';

  @override
  String get subscriptionPaymentPeriodHint =>
      'الدفع المقدّم يمنحك عدد تصليحات أعلى كل شهر.';

  @override
  String subscriptionRepairsPerMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصليحات',
      one: 'تصليح واحد',
    );
    return '$_temp0/شهر';
  }

  @override
  String get subscriptionDisclaimer =>
      'تشمل جميع الخطط الأضرار الخارجية للسيارة فقط (الأبواب، المصدّات، الهيكل). لا يشمل الإصلاح أضرار المحرك أو الأجزاء الميكانيكية أو زجاج السيارة أو الأنوار.';

  @override
  String get subscriptionConfirmTitle => 'تأكيد الاشتراك';

  @override
  String get subscriptionPlanLabel => 'الخطة';

  @override
  String get subscriptionPaymentMethodLabel => 'طريقة الدفع';

  @override
  String get subscriptionRepairsLabel => 'تصليحات / شهر';

  @override
  String get subscriptionTotalLabel => 'المبلغ الإجمالي';

  @override
  String get subscriptionConfirmNote =>
      'سيتواصل معك فريقنا لتأكيد الدفعة وتفعيل الاشتراك.';

  @override
  String get subscriptionSubscribeButton => 'اشترك الآن';

  @override
  String get subscriptionSelectPlan => 'اختر خطة';

  @override
  String get subscriptionPeriodMonthly => 'دفع شهري';

  @override
  String get subscriptionPeriod3Months => 'دفع ٣ أشهر مقدماً';

  @override
  String get subscriptionPeriod6Months => 'دفع ٦ أشهر مقدماً';

  @override
  String get subscriptionPeriod12Months => 'دفع سنة مقدماً';

  @override
  String get accidentHistoryTitle => 'بلاغات الحوادث';

  @override
  String get accidentHistoryNewReportTooltip => 'بلاغ جديد';

  @override
  String get accidentHistoryDraftsSectionTitle => 'المسودات';

  @override
  String get accidentHistoryTotal => 'الإجمالي';

  @override
  String get accidentHistoryCompleted => 'مكتمل';

  @override
  String get accidentHistoryUnderReview => 'قيد المراجعة';

  @override
  String get accidentHistoryNewReportFab => 'بلاغ جديد';

  @override
  String get accidentHistoryEmpty => 'لا توجد بلاغات';

  @override
  String get accidentHistoryEmptyDesc =>
      'إذا تعرضت سيارتك لحادث، قدّم بلاغاً هنا وسيتولى فريقنا إصلاحها.';

  @override
  String get accidentHistorySubmitButton => 'تقديم بلاغ';

  @override
  String get accidentHistoryDeleteDraftTitle => 'حذف المسودة';

  @override
  String get accidentHistoryDeleteDraftContent =>
      'هل أنت متأكد من حذف هذه المسودة؟';

  @override
  String get accidentHistoryOtherPartyInvolved => 'طرف آخر متورط';

  @override
  String accidentHistoryPhotosCount(int count) {
    return '$count صور';
  }

  @override
  String accidentHistoryLastModified(String dateTime) {
    return 'آخر تعديل: $dateTime';
  }

  @override
  String get accidentHistoryCoordinatesSet => 'إحداثيات محددة';

  @override
  String get accidentHistorySwipeToDelete => 'اسحب لليسار للحذف';

  @override
  String get accidentReportTitle => 'تبليغ عن حادث';

  @override
  String get accidentEditDraftTitle => 'تعديل المسودة';

  @override
  String get accidentDraftButton => 'مسودة';

  @override
  String get accidentDraftEditingNote =>
      'أنت تعدّل مسودة محفوظة. يمكنك الإرسال أو إعادة الحفظ.';

  @override
  String get accidentInfoBanner =>
      'أدخل تفاصيل الحادث بدقة. سيقوم فريقنا بالمراجعة وتحديد موعد الإصلاح.';

  @override
  String get accidentPhotosTitle => 'صور الحادث *';

  @override
  String get accidentPhotosSubtitle =>
      'أضف صوراً واضحة لمكان الضرر ومشهد الحادث';

  @override
  String accidentPhotosMaxReached(int max) {
    return 'الحد الأقصى $max صور';
  }

  @override
  String get accidentPhotosTakePhoto => 'التقاط صورة';

  @override
  String get accidentPhotosFromGallery => 'اختيار من المعرض';

  @override
  String accidentPhotosCountLabel(int used, int allowed) {
    return '$used/$allowed';
  }

  @override
  String get accidentDateTitle => 'تاريخ الحادث *';

  @override
  String get accidentLocationTitle => 'موقع الحادث *';

  @override
  String get accidentLocationHint => 'مثال: الكرادة، بغداد';

  @override
  String get accidentLocationGpsTooltip => 'موقعي الحالي';

  @override
  String get accidentLocationMapTooltip => 'اختر على الخريطة';

  @override
  String get accidentLocationPermissionDenied =>
      'تم رفض إذن الموقع. يرجى تفعيله من إعدادات الجهاز.';

  @override
  String get accidentLocationGpsError =>
      'تعذّر الحصول على الموقع. تأكد من تفعيل GPS.';

  @override
  String get accidentDescriptionLabel => 'وصف الضرر *';

  @override
  String get accidentDescriptionHint => 'صف ما حدث وما الذي تضرر...';

  @override
  String get accidentOtherPartyTitle => 'هل كان هناك طرف آخر؟';

  @override
  String get accidentOtherPartySubtitle =>
      'هل كانت هناك مركبة أخرى متورطة في الحادث؟';

  @override
  String get accidentSaveDraftButton => 'حفظ مسودة';

  @override
  String get accidentSubmitButton => 'إرسال البلاغ';

  @override
  String get accidentDraftSavedSuccess => 'تم حفظ المسودة بنجاح';

  @override
  String get accidentSubmittedSuccess =>
      'تم إرسال البلاغ بنجاح! سيقوم فريقنا بمراجعته قريباً.';

  @override
  String get accidentPhotosRequiredError =>
      'يرجى إضافة صورة واحدة على الأقل للحادث';

  @override
  String get accidentRepairLimitTitle => 'وصلت للحد الشهري';

  @override
  String accidentRepairLimitContent(int used, int allowed) {
    return 'لقد استنفدت عدد التصليحات المسموح بها هذا الشهر ($used/$allowed). الترقية إلى خطة أعلى أو الانتظار للشهر القادم.';
  }

  @override
  String get accidentRepairLimitUpgrade => 'ترقية الخطة';

  @override
  String get accidentDetailTitle => 'تفاصيل البلاغ';

  @override
  String get accidentDetailNotFound => 'البلاغ غير موجود';

  @override
  String get accidentDetailPrintTooltip => 'طباعة البلاغ';

  @override
  String get accidentDetailInfoSection => 'معلومات الحادث';

  @override
  String get accidentDetailDescSection => 'الوصف';

  @override
  String accidentDetailPhotosSection(int count) {
    return 'صور الحادث ($count)';
  }

  @override
  String get accidentDetailMaintenanceSection => 'ملاحظات الصيانة';

  @override
  String accidentDetailRepairPhotosSection(int count) {
    return 'صور التصليح ($count)';
  }

  @override
  String get accidentDetailDateLabel => 'التاريخ';

  @override
  String get accidentDetailLocationLabel => 'الموقع';

  @override
  String get accidentDetailSubmittedLabel => 'تاريخ الإرسال';

  @override
  String get accidentDetailOtherPartyLabel => 'طرف آخر';

  @override
  String get accidentDetailYes => 'نعم';

  @override
  String get accidentDetailNo => 'لا';

  @override
  String accidentDetailCompletedAt(String date) {
    return 'اكتمل في $date';
  }

  @override
  String get accidentDetailUploadSection => 'إضافة صور التصليح';

  @override
  String get accidentDetailUploadHint =>
      'أرفق صوراً واضحة تُظهر حالة السيارة بعد التصليح.';

  @override
  String accidentDetailUploadPendingCount(int count) {
    return '$count صورة';
  }

  @override
  String get accidentDetailUploadAddButton => 'أضف صورة';

  @override
  String accidentDetailUploadSubmitButton(int count) {
    return 'إرسال صور التصليح ($count)';
  }

  @override
  String get accidentDetailUploadSubmitting => 'جارٍ الإرسال...';

  @override
  String get accidentDetailUploadSuccess => 'تم إرسال صور التصليح بنجاح';

  @override
  String get accidentDetailUploadError => 'حدث خطأ، يرجى المحاولة مجدداً';

  @override
  String get accidentDetailPrintTitle => 'طباعة البلاغ';

  @override
  String get accidentDetailPrintContent =>
      'سيتم إنشاء ملف PDF يحتوي على تفاصيل بلاغ الحادث.';

  @override
  String get accidentDetailPrintButton => 'طباعة';

  @override
  String get accidentDetailPrintPlaceholder =>
      'تم إنشاء PDF (يتطلب تكامل الباك إند)';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusUnderReview => 'قيد المراجعة';

  @override
  String get statusApproved => 'معتمد';

  @override
  String get statusInRepair => 'قيد التصليح';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusScheduled => 'مجدوَل';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusChangeRequested => 'طُلب التغيير';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusUnpaid => 'غير مدفوع';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get statusOverdue => 'متأخر';

  @override
  String get statusNoPlan => 'بلا خطة';

  @override
  String get statusStandard => 'ستاندارد';

  @override
  String get statusShared => 'المزدوج';

  @override
  String get statusVip => 'VIP';

  @override
  String get homeRecentReports => 'آخر البلاغات';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get homeNoReports => 'لا توجد بلاغات بعد';

  @override
  String get homeGarageBack => 'الكراج';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء النور';

  @override
  String get homeMemberFallback => 'عضو';

  @override
  String get homeMySubscription => 'اشتراكي';

  @override
  String get homeRepairsThisMonth => 'التصليحات هذا الشهر';

  @override
  String get homeRepairsExhausted =>
      'وصلت لحد التصليحات هذا الشهر. يتجدد الشهر القادم.';

  @override
  String homeRepairsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصليحات',
      one: 'تصليح واحد',
    );
    return 'متبقي $_temp0 هذا الشهر';
  }

  @override
  String homeSubscriptionStart(String date) {
    return 'بدأ في $date';
  }

  @override
  String homeSubscriptionExpiry(String date) {
    return 'ينتهي في $date';
  }

  @override
  String get homeUpgradeLink => 'ترقية';

  @override
  String get homeNoSubscription =>
      'لا يوجد اشتراك نشط.\nاشترك للحصول على تغطية الأضرار الخارجية.';

  @override
  String get homeSubscribeButton => 'اشترك';

  @override
  String get homePaymentDue => 'دفعة مستحقة! اضغط هنا لسداد الاشتراك الشهري.';

  @override
  String get homeQuickActionsTitle => 'الإجراءات السريعة';

  @override
  String get homeReportAccident => 'الإبلاغ\nعن حادث';

  @override
  String get homeOilChange => 'تغيير\nالزيت';

  @override
  String get homeMyAppointments => 'مواعيدي';

  @override
  String get homeMyPlan => 'خطتي';

  @override
  String get homeUpcomingAppointmentTitle => 'الموعد القادم';

  @override
  String get homeViewButton => 'عرض';

  @override
  String get appointmentsTitle => 'مواعيدي';

  @override
  String get appointmentsUpcoming => 'موعد قادم';

  @override
  String get appointmentsPast => 'موعد سابق';

  @override
  String get appointmentsEmpty => 'لا توجد مواعيد';

  @override
  String get appointmentsEmptyDesc =>
      'بعد تقديم بلاغ حادث، سيحدد فريق الصيانة موعداً لك.';

  @override
  String get appointmentsChangeTime => 'طلب تغيير الموعد';

  @override
  String get appointmentsChangeRequestSent =>
      'تم إرسال طلب التغيير — بانتظار التأكيد';

  @override
  String appointmentsYourNote(String note) {
    return 'ملاحظتك: $note';
  }

  @override
  String get appointmentsDialogTitle => 'طلب تغيير الموعد';

  @override
  String get appointmentsDialogContent => 'يرجى تقديم سبب أو وقت بديل مفضّل:';

  @override
  String get appointmentsDialogHint =>
      'مثال: لدي عمل في هذا اليوم، يرجى إعادة الجدولة في المساء...';

  @override
  String get paymentTitle => 'الدفع';

  @override
  String get paymentHistoryTitle => 'تاريخ المدفوعات';

  @override
  String get paymentConfirmTitle => 'تأكيد الدفع';

  @override
  String get paymentMethodTitle => 'اختر طريقة الدفع';

  @override
  String get paymentZainCash => 'ZainCash';

  @override
  String get paymentZainCashDesc => 'التحويل عبر محفظة ZainCash';

  @override
  String get paymentZainCashAccount => '+964 770 000 0000';

  @override
  String get paymentSuperQi => 'Super QI';

  @override
  String get paymentSuperQiDesc => 'أرسل مباشرةً — دون الحاجة لبنك';

  @override
  String get paymentSuperQiAccount => '07XX-XXX-XXXX';

  @override
  String get paymentOther => 'طريقة أخرى';

  @override
  String get paymentOtherDesc => 'طريقة دفع أخرى';

  @override
  String get paymentAccountNumberLabel => 'رقم الحساب';

  @override
  String get paymentProofUploadLabel => 'رفع إثبات الدفع';

  @override
  String get paymentProofUploadHint => 'صورة أو لقطة شاشة لإيصال التحويل';

  @override
  String get paymentProofChangeLabel => 'تغيير الصورة';

  @override
  String paymentIvePaid(String amount) {
    return 'لقد دفعت $amount';
  }

  @override
  String get paymentZainCashInstructionsTitle => 'تعليمات تحويل ZainCash';

  @override
  String get paymentSuperQiInstructionsTitle => 'تعليمات تحويل Super QI';

  @override
  String get paymentOtherInstructionsTitle => 'تعليمات الدفع الأخرى';

  @override
  String get paymentVerificationNote =>
      'سيتحقق فريق الحسابات من دفعتك خلال 24 ساعة.';

  @override
  String get paymentAllPaid => 'تم السداد!';

  @override
  String get paymentNoPending => 'لا توجد مدفوعات معلّقة. شكراً!';

  @override
  String paymentPaidOn(String date) {
    return 'مدفوع في $date';
  }

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات بعد';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get profileEditCarTooltip => 'تعديل السيارة';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileFullName => 'الاسم الكامل';

  @override
  String get profileMobile => 'الموبايل';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profileMemberSince => 'عضو منذ';

  @override
  String get profileNotProvided => 'غير مُدرج';

  @override
  String profileCarSection(int number, String make, String model) {
    return 'سيارة $number: $make $model';
  }

  @override
  String get profileCarMake => 'الشركة المصنّعة';

  @override
  String get profileCarModel => 'الموديل';

  @override
  String get profileCarYear => 'السنة';

  @override
  String get profileCarColor => 'اللون';

  @override
  String get profileCarPlate => 'اللوحة';

  @override
  String get profileNationalId => 'الهوية الوطنية';

  @override
  String get profileIdUploaded => 'تم الرفع';

  @override
  String get profileIdNotUploaded => 'لم يُرفع';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileLogoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get profileLogoutConfirmContent => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileDeleteAccountConfirmTitle => 'حذف حسابك؟';

  @override
  String get profileDeleteAccountConfirmContent =>
      'سيؤدي هذا إلى حذف حسابك نهائيًا وجميع البيانات المرتبطة به — ملفك الشخصي، سياراتك، اشتراكاتك، مدفوعاتك، مواعيدك، وبلاغات الحوادث. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get profileDeleteAccountButton => 'حذف حسابي';

  @override
  String get profileDeleteAccountSuccess => 'تم حذف حسابك.';

  @override
  String get profileDeleteAccountError => 'تعذّر حذف حسابك. حاول مرة أخرى.';

  @override
  String get profileMemberFallback => 'عضو';

  @override
  String get oilChangeTitle => 'حجز تغيير الزيت';

  @override
  String get oilChangeServiceName => 'تغيير زيت السيارة';

  @override
  String get oilChangeServiceNote => 'خدمة إضافية — غير مشمولة بالاشتراك';

  @override
  String get oilChangePriceLabel => 'دينار';

  @override
  String get oilChangeSelectCarTitle => 'اختر السيارة';

  @override
  String get oilChangeDateTitle => 'اختر التاريخ';

  @override
  String get oilChangeTimeTitle => 'اختر الوقت';

  @override
  String get oilChangeNotesTitle => 'ملاحظات (اختياري)';

  @override
  String get oilChangeNotesHint => 'مثال: أرغب باستخدام زيت 5W-30...';

  @override
  String get oilChangeBookButton => 'تأكيد الحجز';

  @override
  String get oilChangeValidationError => 'يرجى اختيار السيارة والتاريخ والوقت';

  @override
  String get oilChangeTakePhoto => 'التقاط صورة';

  @override
  String get oilChangeFromGallery => 'اختيار من المعرض';

  @override
  String get mapPickerTitle => 'اختر الموقع على الخريطة';

  @override
  String get mapPickerConfirmButton => 'تأكيد الموقع';

  @override
  String get mapPickerAppBarConfirm => 'تأكيد';

  @override
  String get mapPickerHint => 'اضغط على الخريطة لتحديد موقع الحادث';

  @override
  String get mapPickerGpsTooltip => 'موقعي الحالي';

  @override
  String get mapPickerGpsError => 'تعذّر الحصول على موقعك. تأكد من تفعيل GPS.';

  @override
  String get mapPickerPermissionDenied =>
      'تم رفض إذن الموقع. يرجى تفعيله من إعدادات الجهاز.';

  @override
  String get mapPickerSelectFirst => 'اضغط على الخريطة لتحديد الموقع أولاً';

  @override
  String get draftLocationUnknown => 'موقع غير محدد';

  @override
  String draftLastModified(String dateTime) {
    return 'آخر تعديل: $dateTime';
  }

  @override
  String get draftBadge => 'مسودة';

  @override
  String get draftSwipeToDelete => 'اسحب لليسار للحذف';

  @override
  String get draftCoordinatesSet => 'إحداثيات محددة';

  @override
  String get draftEditingNote =>
      'أنت تعدّل مسودة محفوظة. يمكنك الإرسال أو إعادة الحفظ.';

  @override
  String get draftSavedSuccess => 'تم حفظ المسودة بنجاح';

  @override
  String get validatorPhoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get validatorPhoneInvalid => 'أدخل رقم هاتف صحيح';

  @override
  String get validatorPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get validatorPasswordTooShort =>
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get validatorConfirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get validatorPasswordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String validatorRequired(String fieldName) {
    return '$fieldName مطلوب';
  }

  @override
  String get validatorNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get validatorNameTooShort => 'الاسم يجب أن يكون 3 أحرف على الأقل';

  @override
  String get validatorEmailInvalid => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get validatorYearRequired => 'سنة الصنع مطلوبة';

  @override
  String get validatorYearInvalid => 'أدخل سنة صنع صحيحة (1990–2030)';

  @override
  String get idFrontLabel => 'الوجه الأمامي';

  @override
  String get idBackLabel => 'الوجه الخلفي';

  @override
  String get idUploadTapHint => 'اضغط لرفع الصورة';

  @override
  String get paymentDueLabel => 'دفعة مستحقة';

  @override
  String paymentDueDateLabel(String date) {
    return 'الاستحقاق: $date';
  }

  @override
  String paymentConfirmContent(String amount, String method, String month) {
    return 'هل تأكدت من تحويل $amount عبر $method لشهر $month؟';
  }

  @override
  String get paymentMethodZainCash => 'ZainCash';

  @override
  String get paymentMethodSuperQi => 'Super QI';

  @override
  String get paymentMethodOther => 'أخرى';

  @override
  String get paymentSnackbarSuccess =>
      'تم تسجيل الدفعة. سيتحقق فريق المحاسبة خلال 24 ساعة.';

  @override
  String get paymentZainCashStep1 => 'افتح تطبيق ZainCash';

  @override
  String get paymentZainCashStep2 => 'حوّل إلى: +964 770 000 0000';

  @override
  String get paymentZainCashStep3 => 'اذكر اسمك ورقم اللوحة في ملاحظة التحويل';

  @override
  String get paymentZainCashStep4 =>
      'ارفع لقطة شاشة أدناه ثم اضغط \"لقد دفعت\"';

  @override
  String get paymentSuperQiStep1 => 'افتح تطبيق Super QI أو اتصل بـ *3200#';

  @override
  String get paymentSuperQiStep2 => 'أرسل إلى الحساب: 07XX-XXX-XXXX';

  @override
  String get paymentSuperQiStep3 => 'اذكر اسمك ورقم اللوحة في ملاحظة التحويل';

  @override
  String get paymentSuperQiStep4 => 'ارفع لقطة شاشة أدناه ثم اضغط \"لقد دفعت\"';

  @override
  String get paymentOtherStep1 => 'حوّل إلى رقم الحساب الذي سيُرسله لك فريقنا';

  @override
  String get paymentOtherStep2 => 'اذكر اسمك الكامل وبيانات الاشتراك';

  @override
  String get paymentOtherStep3 => 'احتفظ بالإيصال كدليل على الدفع';

  @override
  String get paymentOtherStep4 => 'ارفع لقطة شاشة أدناه ثم اضغط \"لقد دفعت\"';

  @override
  String notificationsTimeAgoMinutes(int count) {
    return 'منذ $count د';
  }

  @override
  String notificationsTimeAgoHours(int count) {
    return 'منذ $count س';
  }

  @override
  String profileActivePlan(String plan) {
    return 'خطة $plan نشطة';
  }

  @override
  String get profileNoActiveSub => 'لا يوجد اشتراك نشط — اضغط للاشتراك';

  @override
  String get profileAddCarTitle => 'أضف سيارتك';

  @override
  String get profileAddCarDesc => 'سجّل سيارتك لبدء استخدام خدماتنا';

  @override
  String get appointmentsRequestSentSnackbar =>
      'تم إرسال طلب التغيير إلى فريق الصيانة.';

  @override
  String get oilChangeConfirmTitle => 'تم الحجز بنجاح';

  @override
  String oilChangeConfirmContent(String make, String model) {
    return 'تم حجز موعد تغيير الزيت لسيارة $make $model.';
  }

  @override
  String get oilChangeDayMon => 'الإثنين';

  @override
  String get oilChangeDayTue => 'الثلاثاء';

  @override
  String get oilChangeDayWed => 'الأربعاء';

  @override
  String get oilChangeDayThu => 'الخميس';

  @override
  String get oilChangeDaySat => 'السبت';

  @override
  String get oilChangeDaySun => 'الأحد';

  @override
  String get oilChangeMonthJan => 'يناير';

  @override
  String get oilChangeMonthFeb => 'فبراير';

  @override
  String get oilChangeMonthMar => 'مارس';

  @override
  String get oilChangeMonthApr => 'أبريل';

  @override
  String get oilChangeMonthMay => 'مايو';

  @override
  String get oilChangeMonthJun => 'يونيو';

  @override
  String get oilChangeMonthJul => 'يوليو';

  @override
  String get oilChangeMonthAug => 'أغسطس';

  @override
  String get oilChangeMonthSep => 'سبتمبر';

  @override
  String get oilChangeMonthOct => 'أكتوبر';

  @override
  String get oilChangeMonthNov => 'نوفمبر';

  @override
  String get oilChangeMonthDec => 'ديسمبر';

  @override
  String get oilChangeTimeSlot1 => '8:00 ص – 9:00 ص';

  @override
  String get oilChangeTimeSlot2 => '9:00 ص – 10:00 ص';

  @override
  String get oilChangeTimeSlot3 => '10:00 ص – 11:00 ص';

  @override
  String get oilChangeTimeSlot4 => '11:00 ص – 12:00 م';

  @override
  String get oilChangeTimeSlot5 => '1:00 م – 2:00 م';

  @override
  String get oilChangeTimeSlot6 => '2:00 م – 3:00 م';

  @override
  String get oilChangeTimeSlot7 => '3:00 م – 4:00 م';

  @override
  String get oilChangeTimeSlot8 => '4:00 م – 5:00 م';

  @override
  String get subscriptionRepairsByPeriod => 'التصليحات حسب الدفع';

  @override
  String get upgradeTitle => 'ترقية الاشتراك';

  @override
  String get upgradeCurrentPlanSection => 'الخطة الحالية';

  @override
  String get upgradeNewPlanSection => 'الخطة الجديدة';

  @override
  String upgradeRemainingMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشهر متبقية',
      one: 'شهر واحد متبقٍ',
    );
    return '$_temp0';
  }

  @override
  String get upgradeCreditLabel => 'الرصيد المتبقي';

  @override
  String get upgradeNewCostLabel => 'تكلفة الخطة الجديدة';

  @override
  String get upgradeAmountDueLabel => 'المبلغ المستحق';

  @override
  String get upgradeAmountFree => 'مغطى بالرصيد';

  @override
  String get upgradeNote =>
      'سيتواصل معك فريقنا لإتمام سداد الفرق وتفعيل خطتك الجديدة فوراً.';

  @override
  String get upgradeSubmitButton => 'طلب الترقية';

  @override
  String get upgradeSentTitle => 'تم إرسال طلب الترقية';

  @override
  String upgradeSentContent(String currentPlan, String newPlan) {
    return 'تم إرسال طلب ترقيتك من $currentPlan إلى $newPlan. سيتواصل معك فريقنا قريباً لإتمام الدفع.';
  }

  @override
  String get upgradePendingBanner => 'لديك طلب ترقية قيد المراجعة';

  @override
  String get upgradeStatusCardTitle => 'طلب اشتراكك';

  @override
  String get upgradeStatusStepSubmitted => 'تم الإرسال';

  @override
  String get upgradeStatusStepReview => 'قيد المراجعة';

  @override
  String get upgradeStatusStepDecision => 'القرار';

  @override
  String get upgradeStatusPendingDesc =>
      'جاري التحقق من دفعتك. سنخبرك فور الموافقة عليها.';

  @override
  String get upgradeStatusApprovedLabel => 'مقبول';

  @override
  String get upgradeStatusRejectedLabel => 'مرفوض';

  @override
  String get upgradeStatusRejectedDesc =>
      'لم تتم الموافقة على طلبك السابق. يمكنك إرسال طلب جديد.';

  @override
  String get upgradeStatusAdminNote => 'ملاحظة من الإدارة';

  @override
  String upgradeStatusSubmittedAt(String date) {
    return 'أُرسل بتاريخ $date';
  }

  @override
  String get upgradeStatusAmountLabel => 'المبلغ';

  @override
  String get upgradeStatusRequestedPlanLabel => 'الخطة المطلوبة';

  @override
  String get subscriptionPendingShort => 'طلب الاشتراك قيد المراجعة';

  @override
  String get subscriptionPendingDesc =>
      'جاري التحقق من دفعتك. سنقوم بتفعيل خطتك فور الموافقة.';

  @override
  String get subscriptionPendingViewStatus => 'عرض الحالة';

  @override
  String get subscriptionPendingBadge => 'قيد المراجعة';

  @override
  String subscriptionUpgradePendingTo(String planName) {
    return 'ترقية إلى $planName قيد المراجعة';
  }

  @override
  String get subscriptionCurrentPlanBanner => 'خطتك الحالية';

  @override
  String get upgradeDowngradeNote =>
      'يسري تخفيض الخطة بعد انتهاء اشتراكك الحالي. تواصل مع فريقنا للمساعدة.';

  @override
  String get upgradeRenewButton => 'تجديد الخطة';

  @override
  String get upgradeRenewNote =>
      'خطتك الحالية لا تزال نشطة. التجديد الآن سيمدد اشتراكك من تاريخ الانتهاء الحالي.';

  @override
  String get upgradeSamePlanBanner => 'أنت مشترك بهذه الخطة حالياً';

  @override
  String get navMyCars => 'سياراتي';

  @override
  String get myCarsTitle => 'سياراتي';

  @override
  String get myCarsNoCars => 'لا توجد سيارات مسجلة';

  @override
  String get myCarsNoCarsDesc => 'أضف سيارتك لبدء استخدام خدماتنا';

  @override
  String get myCarsAddCar => 'إضافة سيارة';

  @override
  String get myCarsSubscription => 'الاشتراك';

  @override
  String get myCarsNoSubscription => 'لا يوجد اشتراك';

  @override
  String get myCarsSubscribNow => 'اشترك الآن';

  @override
  String get myCarsPayNow => 'ادفع الآن';

  @override
  String myCarsExpires(String date) {
    return 'ينتهي: $date';
  }

  @override
  String myCarsRepairsLeft(int count) {
    return '$count تصليحات متبقية هذا الشهر';
  }

  @override
  String myCarsPerMonth(String price) {
    return '$price / شهرياً';
  }

  @override
  String get myCarsPlanDetails => 'تفاصيل الخطة';

  @override
  String get myCarsManage => 'إدارة';

  @override
  String get carDetailTitle => 'تفاصيل السيارة';

  @override
  String get carDetailCarInfo => 'معلومات السيارة';

  @override
  String get carDetailMake => 'الشركة المصنّعة';

  @override
  String get carDetailModel => 'الموديل';

  @override
  String get carDetailYear => 'السنة';

  @override
  String get carDetailColor => 'اللون';

  @override
  String get carDetailPlate => 'اللوحة';

  @override
  String get carDetailSubscription => 'الاشتراك';

  @override
  String get profileEditButton => 'تعديل المعلومات';

  @override
  String get profileEditTitle => 'طلب تعديل المعلومات';

  @override
  String get profileEditDesc =>
      'سيتم إرسال طلبك إلى الإدارة للمراجعة والموافقة.';

  @override
  String get profileEditName => 'الاسم الكامل';

  @override
  String get profileEditEmail => 'البريد الإلكتروني';

  @override
  String get profileEditPhone => 'رقم الموبايل';

  @override
  String get profileEditSubmit => 'إرسال طلب التعديل';

  @override
  String get profileEditSuccess =>
      'تم إرسال طلب التعديل بنجاح. سيتم مراجعته من قبل الإدارة.';

  @override
  String get profileEditNoChanges => 'لم تقم بتغيير أي معلومات';

  @override
  String get profileEditPending => 'لديك طلب تعديل قيد المراجعة';

  @override
  String get oilChangeRequestSubmit => 'إرسال الطلب';

  @override
  String get oilChangeRequestDesc =>
      'سيقوم فريق الصيانة بتحديد التاريخ والوقت والفرع المناسب لك.';

  @override
  String get oilChangeValidationNoCar => 'يرجى اختيار السيارة';

  @override
  String oilChangeConfirmContentSimple(String make, String model) {
    return 'تم إرسال طلب تغيير الزيت لسيارة $make $model. سنتواصل معك بتفاصيل الموعد.';
  }

  @override
  String get appointmentsBranch => 'الفرع';

  @override
  String get appointmentsNavigate => 'اذهب للموقع';

  @override
  String get appointmentsChooseNav => 'افتح بواسطة';

  @override
  String get appointmentsGoogleMaps => 'خرائط جوجل';

  @override
  String get appointmentsWaze => 'Waze';

  @override
  String get appointmentsLocationNotSet =>
      'سيتم تحديد الموقع من قبل فريق الصيانة';

  @override
  String get availableCitiesTitle => 'مركز الصيانة متاح حالياً في';

  @override
  String get accidentDetailRepairEntry => 'عملية إصلاح';

  @override
  String get accidentDetailFinalRepair => 'نهائي';

  @override
  String get accidentDetailRepairDate => 'التاريخ';

  @override
  String get accidentDetailTechnician => 'الفني';

  @override
  String get accidentDetailPartsReplaced => 'القطع المستبدلة:';

  @override
  String get supportTitle => 'الدعم والمساعدة';

  @override
  String get supportCallUs => 'اتصل بنا';

  @override
  String get supportEmailUs => 'راسلنا';

  @override
  String get supportWhatsApp => 'واتساب';

  @override
  String get supportWorkingHours => 'ساعات العمل';

  @override
  String get supportWorkingHoursValue => 'السبت - الخميس، 9 صباحاً - 5 مساءً';

  @override
  String get supportAddress => 'العنوان';

  @override
  String get supportFollowUs => 'تابعنا';

  @override
  String get supportNeedHelp => 'هل تحتاج مساعدة؟';

  @override
  String get supportDesc =>
      'فريقنا جاهز لمساعدتك في أي وقت. تواصل معنا عبر أي من الطرق التالية.';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String privacyPolicyLastUpdated(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get privacyPolicyLink => 'سياسة الخصوصية';

  @override
  String get privacyPolicyAgreePrefix => 'بالمتابعة، فإنك توافق على ';

  @override
  String get privacyPolicyView => 'عرض سياسة الخصوصية';

  @override
  String get accidentNoSubscriptionTitle => 'الاشتراك مطلوب';

  @override
  String get accidentNoSubscriptionContent =>
      'يجب أن يكون لديك اشتراك فعّال للإبلاغ عن حادث. اشترك في إحدى الخطط أولاً.';

  @override
  String get accidentNoSubscriptionAction => 'اشترك الآن';

  @override
  String get subscriptionPayTitle => 'إتمام الدفع';

  @override
  String get subscriptionPayDesc =>
      'حوّل المبلغ أدناه ثم اضغط تأكيد لتفعيل اشتراكك.';

  @override
  String get subscriptionPayAccountsTitle => 'حسابات الدفع';

  @override
  String get subscriptionPayNote =>
      'بعد الدفع، سيتحقق فريق المالية خلال 24 ساعة ويفعّل اشتراكك.';

  @override
  String get subscriptionPayConfirmButton => 'لقد دفعت — تفعيل';

  @override
  String get subscriptionPaySuccess =>
      'تم تقديم طلب الاشتراك. سيتحقق فريقنا من الدفع قريباً.';
}
