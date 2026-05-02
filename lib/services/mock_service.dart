import 'package:flutter/material.dart';
import '../models/accident_report_model.dart';
import '../models/ad_banner_model.dart';
import '../models/appointment_model.dart';
import '../models/branch_model.dart';
import '../models/car_change_request_model.dart';
import '../models/upgrade_request_model.dart';
import '../models/notification_model.dart';
import '../models/oil_change_model.dart';
import '../models/onboarding_page_model.dart';
import '../models/payment_accounts_model.dart';
import '../models/payment_model.dart';
import '../models/privacy_policy_model.dart';
import '../models/subscription_model.dart';
import '../models/support_info_model.dart';
import '../models/user_model.dart';

/// Mock service simulating API responses.
/// Replace method bodies with real API calls during backend integration.
class MockService {
  static final MockService _instance = MockService._();
  factory MockService() => _instance;
  MockService._();

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<UserModel?> login(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (phone.isNotEmpty && password.length >= 6) return _mockUser;
    return null;
  }

  Future<bool> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return otp == '123456' || otp.length == 6;
  }

  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      phone: phone,
      email: email,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  /// Persist the uploaded national-ID images against the user and return the
  /// updated user. The real backend should store the URLs and mark the user
  /// as ready for review.
  Future<UserModel> uploadIdImages({
    required String userId,
    required String frontUrl,
    required String backUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _mockUser.copyWith(
      idFrontUrl: frontUrl,
      idBackUrl: backUrl,
    );
  }

  // ── User ──────────────────────────────────────────────────────────────────

  Future<UserModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockUser;
  }

  /// Re-fetch the current user's status (used to detect approval/suspension
  /// changes made by the admin panel).
  Future<UserModel> refreshUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockUser;
  }

  // ── Accidents ─────────────────────────────────────────────────────────────

  Future<List<AccidentReport>> getAccidentReports(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockAccidents;
  }

  Future<AccidentReport> submitReport({
    required String userId,
    String? carId,
    required DateTime accidentDate,
    required String location,
    double? lat,
    double? lng,
    required String description,
    required bool otherPartyInvolved,
    required List<String> photoUrls,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return AccidentReport(
      id: 'rpt_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      carId: carId,
      accidentDate: accidentDate,
      location: location,
      lat: lat,
      lng: lng,
      description: description,
      photoUrls: photoUrls,
      otherPartyInvolved: otherPartyInvolved,
      submittedAt: DateTime.now(),
    );
  }

  Future<bool> submitRepairPhotos(String reportId, List<String> photoUrls) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  // ── Appointments ──────────────────────────────────────────────────────────

  Future<List<AppointmentModel>> getAppointments(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockAppointments;
  }

  Future<bool> requestAppointmentChange(String appointmentId, String note) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  Future<List<PaymentRecord>> getPaymentHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockPayments;
  }

  Future<bool> markPaymentMade(
    String paymentId,
    PaymentMethod method, {
    String? proofImageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  /// Dynamic ZainCash / SuperQi account numbers — editable by finance/admin.
  Future<PaymentAccounts> getPaymentAccounts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockPaymentAccounts;
  }

  /// Dynamic onboarding pages — admin can override title/desc/image. Mock
  /// returns an empty list so the customer app falls back to its built-in copy.
  Future<List<OnboardingPageData>> getOnboardingPages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const [];
  }

  // ── Subscription Plans ────────────────────────────────────────────────────

  /// Dynamic subscription plans — editable by finance/admin from the dashboard.
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In mock mode we just return the bundled defaults so the UI stays stable.
    return SubscriptionPlan.plans;
  }

  // ── Car Change Requests ───────────────────────────────────────────────────

  Future<CarChangeRequest> submitCarChangeRequest({
    required String userId,
    required Map<String, String> requestedChanges,
    CarChangeRequestType type = CarChangeRequestType.carChange,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return CarChangeRequest(
      id: 'ccr_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      requestedChanges: requestedChanges,
      status: CarChangeRequestStatus.pending,
      submittedAt: DateTime.now(),
    );
  }

  Future<List<CarChangeRequest>> getCarChangeRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockCarChangeRequests.where((r) => r.userId == userId).toList();
  }

  // ── Upgrade Requests ──────────────────────────────────────────────────────

  Future<UpgradeRequest> submitUpgradeRequest({
    required String userId,
    required String carId,
    required SubscriptionType currentPlan,
    required int currentPlanPriceIQD,
    required int remainingMonths,
    required int creditIQD,
    required SubscriptionType requestedPlan,
    required int requestedPlanPriceIQD,
    required int requestedMonths,
    required int newCostIQD,
    required int amountDueIQD,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return UpgradeRequest(
      id: 'upg_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      carId: carId,
      currentPlan: currentPlan,
      currentPlanPriceIQD: currentPlanPriceIQD,
      remainingMonths: remainingMonths,
      creditIQD: creditIQD,
      requestedPlan: requestedPlan,
      requestedPlanPriceIQD: requestedPlanPriceIQD,
      requestedMonths: requestedMonths,
      newCostIQD: newCostIQD,
      amountDueIQD: amountDueIQD,
      status: UpgradeRequestStatus.pending,
      submittedAt: DateTime.now(),
    );
  }

  Future<List<UpgradeRequest>> getUpgradeRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return []; // no mock data — starts empty
  }

  // ── Ad Banners ────────────────────────────────────────────────────────────

  Future<List<AdBanner>> getAdBanners() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockAdBanners;
  }

  // ── Oil Change ────────────────────────────────────────────────────────────

  Future<OilChangeBooking> bookOilChange({
    required String userId,
    required String carId,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return OilChangeBooking(
      id: 'oil_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      carId: carId,
      notes: notes,
      status: OilChangeStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  Future<List<OilChangeBooking>> getOilChangeBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockOilChangeBookings.where((b) => b.userId == userId).toList();
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockNotifications
        .where((n) => n.userId == userId || n.userId == 'all')
        .toList();
  }

  /// Persist "read" state on the backend so the counter stays in sync across
  /// app launches and devices.
  Future<bool> markNotificationRead({
    required String userId,
    required String notifId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  /// Mark every notification for a user as read.
  Future<bool> markAllNotificationsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // ── Support Info ─────────────────────────────────────────────────────────

  Future<SupportInfo> getSupportInfo() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockSupportInfo;
  }

  // ── Branches ─────────────────────────────────────────────────────────────

  Future<List<BranchModel>> getBranches() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockBranches;
  }

  // ── Privacy Policy ───────────────────────────────────────────────────────

  Future<PrivacyPolicy> getPrivacyPolicy() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockPrivacyPolicy;
  }

  static const PrivacyPolicy _mockPrivacyPolicy = PrivacyPolicy(
    updatedAt: '2026-04-09',
    content:
        'سياسة الخصوصية\n\n'
        'مرحباً بك في تطبيق Uruk Motors. نهتم بخصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة كيف نجمع المعلومات ونستخدمها ونحميها.\n\n'
        '1. المعلومات التي نجمعها\n'
        'نجمع البيانات التي تقدّمها بنفسك عند التسجيل (الاسم، رقم الهاتف، البريد الإلكتروني، الهوية الوطنية، بيانات السيارة).\n\n'
        '2. كيف نستخدم بياناتك\n'
        'نستخدم بياناتك لتقديم خدمات الصيانة والاشتراكات وإدارة المواعيد والمدفوعات والتواصل معك.\n\n'
        '3. مشاركة البيانات\n'
        'لا نشارك بياناتك مع أي طرف ثالث إلا بموافقتك أو بموجب القانون.\n\n'
        '4. أمان البيانات\n'
        'نطبّق إجراءات أمنية لحماية بياناتك من الوصول غير المصرّح به.\n\n'
        '5. حقوقك\n'
        'يحق لك طلب الاطلاع على بياناتك أو تعديلها أو حذفها في أي وقت بالتواصل معنا.\n\n'
        '6. التواصل\n'
        'لأي استفسار حول الخصوصية، تواصل معنا عبر معلومات الدعم في التطبيق.',
  );

  static const List<BranchModel> _mockBranches = [
    BranchModel(
      id: 'br_001',
      name: 'فرع الكرادة',
      lat: 33.3128,
      lng: 44.3615,
      address: 'الكرادة، بغداد',
      phone: '+964 770 111 0001',
    ),
    BranchModel(
      id: 'br_002',
      name: 'فرع المنصور',
      lat: 33.3152,
      lng: 44.3506,
      address: 'المنصور، بغداد',
      phone: '+964 770 111 0002',
    ),
    BranchModel(
      id: 'br_003',
      name: 'فرع زيونة',
      lat: 33.33,
      lng: 44.42,
      address: 'زيونة، بغداد',
      phone: '+964 770 111 0003',
    ),
  ];

  static const PaymentAccounts _mockPaymentAccounts = PaymentAccounts(
    zainCash: '+964 770 000 0000',
    superQi: '07XX-XXX-XXXX',
  );

  // ── Available Cities ──────────────────────────────────────────────────────

  Future<List<String>> getAvailableCities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockAvailableCities;
  }

  // ── Mock Data ─────────────────────────────────────────────────────────────

  static final List<String> _mockAvailableCities = ['بغداد'];

  static const SupportInfo _mockSupportInfo = SupportInfo(
    phone: '+964 770 000 0000',
    email: 'support@urukmotors.iq',
    whatsapp: '+964 770 000 0000',
    address: 'بغداد، الكرادة، شارع أبو نؤاس',
    workingHours: 'السبت - الخميس، 9 صباحاً - 5 مساءً',
    instagram: 'urukmotors',
    facebook: 'urukmotors',
    telegram: 'urukmotors',
    website: 'www.urukmotors.iq',
  );

  static final UserModel _mockUser = UserModel(
    id: 'usr_001',
    fullName: 'أحمد الراشدي',
    phone: '+964 770 123 4567',
    email: 'ahmed@example.com',
    status: UserStatus.approved,
    paymentDue: true,
    cars: [
      CarInfo(
        id: 'car_001',
        make: 'تويوتا',
        model: 'كامري',
        year: 2021,
        color: 'أبيض',
        plateNumber: '12345 - بغداد',
        subscription: SubscriptionType.shared,
        subscriptionExpiry: DateTime.now().add(const Duration(days: 18)),
        paymentMonths: 1,           // دفع شهري
        repairsAllowedPerMonth: 1,  // shared + شهري = 1 تصليح
        repairsUsedThisMonth: 0,
      ),
      CarInfo(
        id: 'car_002',
        make: 'هيونداي',
        model: 'سونتا',
        year: 2019,
        color: 'رمادي',
        plateNumber: '54321 - بغداد',
        subscription: SubscriptionType.standard,
        subscriptionExpiry: DateTime.now().add(const Duration(days: 45)),
        paymentMonths: 3,           // دفع 3 أشهر مقدماً
        repairsAllowedPerMonth: 2,  // standard + 3 أشهر = 2 تصليح
        repairsUsedThisMonth: 1,
      ),
      CarInfo(
        id: 'car_003',
        make: 'كيا',
        model: 'سبورتاج',
        year: 2023,
        color: 'أسود',
        plateNumber: '99887 - كربلاء',
        subscription: SubscriptionType.none,
        paymentMonths: 1,
        repairsAllowedPerMonth: 0,
        repairsUsedThisMonth: 0,
      ),
    ],
    createdAt: DateTime(2026, 1, 15),
  );

  static final List<AccidentReport> _mockAccidents = [
    AccidentReport(
      id: 'rpt_001',
      userId: 'usr_001',
      carId: 'car_001',
      accidentDate: DateTime(2026, 3, 15),
      location: 'الكرادة، بغداد',
      lat: 33.3128,
      lng: 44.3615,
      description: 'اصطدام بسيط عند تقاطع. تضرر المصد الأمامي والغطاء.',
      photoUrls: ['photo1', 'photo2', 'photo3'],
      otherPartyInvolved: true,
      status: ReportStatus.completed,
      submittedAt: DateTime(2026, 3, 15, 14, 30),
      maintenanceNotes: 'تم استبدال المصد الأمامي وإصلاح الغطاء وإعادة طلائه بلون مطابق للأصلي.',
      repairPhotoUrls: ['repair1', 'repair2'],
      completedAt: DateTime(2026, 3, 22),
      appointmentId: 'apt_001',
    ),
    AccidentReport(
      id: 'rpt_002',
      userId: 'usr_001',
      carId: 'car_001',
      accidentDate: DateTime(2026, 3, 28),
      location: 'المنصور، بغداد',
      lat: 33.3152,
      lng: 44.3506,
      description: 'خدش الباب أثناء وقوف السيارة. الباب الخلفي الأيسر به خدش عميق.',
      photoUrls: ['photo4'],
      otherPartyInvolved: false,
      status: ReportStatus.inRepair,
      submittedAt: DateTime(2026, 3, 28, 10, 0),
      appointmentId: 'apt_002',
    ),
    AccidentReport(
      id: 'rpt_003',
      userId: 'usr_001',
      carId: 'car_002',
      accidentDate: DateTime(2026, 4, 1),
      location: 'زيونة، بغداد',
      lat: 33.33,
      lng: 44.42,
      description: 'تشقق المصد الخلفي بعد الاصطدام بعمود أثناء التراجع.',
      photoUrls: ['photo5', 'photo6'],
      otherPartyInvolved: false,
      status: ReportStatus.underReview,
      submittedAt: DateTime(2026, 4, 1, 16, 45),
    ),
  ];

  static final List<AppointmentModel> _mockAppointments = [
    AppointmentModel(
      id: 'apt_001',
      userId: 'usr_001',
      reportId: 'rpt_001',
      scheduledDate: DateTime(2026, 3, 18),
      timeSlot: '10:00 ص – 11:00 ص',
      status: AppointmentStatus.completed,
      createdAt: DateTime(2026, 3, 16),
      branchName: 'فرع الكرادة',
      locationLat: 33.3128,
      locationLng: 44.3615,
    ),
    AppointmentModel(
      id: 'apt_002',
      userId: 'usr_001',
      reportId: 'rpt_002',
      scheduledDate: DateTime(2026, 4, 5),
      timeSlot: '2:00 م – 3:00 م',
      status: AppointmentStatus.confirmed,
      createdAt: DateTime(2026, 3, 29),
      maintenanceNote: 'يرجى الحضور قبل 10 دقائق من موعدك لإتمام إجراءات الاستلام.',
      branchName: 'فرع المنصور',
      locationLat: 33.3152,
      locationLng: 44.3506,
    ),
  ];

  static final List<PaymentRecord> _mockPayments = [
    PaymentRecord(
      id: 'pay_001',
      userId: 'usr_001',
      carId: 'car_001',
      carDesc: 'تويوتا كامري 2021',
      amountIQD: 60000,
      dueDate: DateTime(2026, 4, 1),
      status: PaymentStatus.unpaid,
      month: 'نيسان 2026',
    ),
    PaymentRecord(
      id: 'pay_002',
      userId: 'usr_001',
      carId: 'car_001',
      carDesc: 'تويوتا كامري 2021',
      amountIQD: 60000,
      dueDate: DateTime(2026, 3, 1),
      paidDate: DateTime(2026, 3, 3),
      status: PaymentStatus.paid,
      method: PaymentMethod.zaincash,
      month: 'آذار 2026',
    ),
    PaymentRecord(
      id: 'pay_003',
      userId: 'usr_001',
      carId: 'car_002',
      carDesc: 'هيونداي سونتا 2019',
      amountIQD: 35000,
      dueDate: DateTime(2026, 3, 15),
      status: PaymentStatus.overdue,
      month: 'آذار 2026',
    ),
  ];

  static final List<CarChangeRequest> _mockCarChangeRequests = [
    CarChangeRequest(
      id: 'ccr_001',
      userId: 'usr_001',
      requestedChanges: {'color': 'أسود', 'plateNumber': '54321 - بغداد'},
      status: CarChangeRequestStatus.pending,
      submittedAt: DateTime(2026, 3, 30),
    ),
  ];

  static final List<AdBanner> _mockAdBanners = [
    const AdBanner(
      id: 'ban_001',
      title: 'خصم 15% على تجديد الاشتراك',
      subtitle: 'جدّد اشتراكك قبل انتهائه واحصل على خصم حصري لعملائنا المميزين',
      backgroundColor: Color(0xFF1A3A8F),
      icon: Icons.local_offer_outlined,
      actionLabel: 'اشترك الآن',
      actionRoute: '/subscription',
    ),
    const AdBanner(
      id: 'ban_002',
      title: 'خدمة تغيير الزيت متاحة الآن',
      subtitle: 'احجز موعد تغيير الزيت لسيارتك بسعر خاص — 15,000 د.ع فقط',
      backgroundColor: Color(0xFF065F46),
      icon: Icons.build_circle_outlined,
      actionLabel: 'احجز الآن',
      actionRoute: '/oil-change',
    ),
    const AdBanner(
      id: 'ban_003',
      title: 'تقييم مجاني لسيارتك',
      subtitle: 'احصل على تقييم شامل لحالة سيارتك الخارجية مجاناً مع كل اشتراك جديد',
      backgroundColor: Color(0xFF7C3AED),
      icon: Icons.star_outline,
      actionLabel: 'اعرف المزيد',
    ),
  ];

  static final List<OilChangeBooking> _mockOilChangeBookings = [
    OilChangeBooking(
      id: 'oil_001',
      userId: 'usr_001',
      carId: 'car_001',
      scheduledDate: DateTime(2026, 3, 10),
      timeSlot: '9:00 ص – 10:00 ص',
      branchName: 'فرع الكرادة',
      locationLat: 33.3128,
      locationLng: 44.3615,
      status: OilChangeStatus.completed,
      createdAt: DateTime(2026, 3, 8),
      priceIQD: 15000,
    ),
  ];

  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: 'notif_001',
      userId: 'usr_001',
      title: 'دفعة مستحقة',
      body: 'دفعة اشتراك نيسان 2026 البالغة 35,000 د.ع مستحقة اليوم.',
      type: NotificationType.payment,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      actionRoute: '/payment',
    ),
    NotificationModel(
      id: 'notif_002',
      userId: 'usr_001',
      title: 'تم تأكيد الموعد',
      body: 'تم تأكيد موعد الإصلاح بتاريخ 5 أبريل الساعة 2:00 م.',
      type: NotificationType.appointment,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      actionRoute: '/appointments',
    ),
    NotificationModel(
      id: 'notif_003',
      userId: 'usr_001',
      title: 'التقرير قيد المراجعة',
      body: 'تقرير الحادث المقدَّم بتاريخ 1 أبريل قيد المراجعة من قِبل فريق الصيانة.',
      type: NotificationType.report,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      actionRoute: '/accidents',
    ),
    NotificationModel(
      id: 'notif_004',
      userId: 'usr_001',
      title: 'اكتمل الإصلاح',
      body: 'اكتمل إصلاح سيارتك بتاريخ 18 مارس. اضغط لعرض التقرير الكامل.',
      type: NotificationType.report,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      actionRoute: '/accidents',
    ),
  ];
}
