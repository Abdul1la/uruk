import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
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
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final _service = ApiService();

  // ── State ──────────────────────────────────────────────────────────────────

  List<AccidentReport> _accidents = [];
  List<AppointmentModel> _appointments = [];
  List<PaymentRecord> _payments = [];
  List<NotificationModel> _notifications = [];
  List<CarChangeRequest> _carChangeRequests = [];
  List<UpgradeRequest> _upgradeRequests = [];
  List<AdBanner> _adBanners = [];
  List<OilChangeBooking> _oilChangeBookings = [];
  List<String> _availableCities = [];
  List<BranchModel> _branches = [];
  SupportInfo? _supportInfo;
  PrivacyPolicy? _privacyPolicy;
  PaymentAccounts? _paymentAccounts;
  List<OnboardingPageData> _onboardingPages = [];
  List<SubscriptionPlan> _plans = SubscriptionPlan.plans;

  CarInfo? _selectedCar;

  bool _loadingAccidents = false;
  bool _loadingAppointments = false;
  bool _loadingPayments = false;
  bool _loadingNotifications = false;

  // ── Getters ────────────────────────────────────────────────────────────────

  List<AccidentReport> get accidents => _accidents;
  List<AppointmentModel> get appointments => _appointments;
  List<PaymentRecord> get payments => _payments;
  List<NotificationModel> get notifications => _notifications;
  List<CarChangeRequest> get carChangeRequests => _carChangeRequests;
  List<UpgradeRequest> get upgradeRequests => _upgradeRequests;

  UpgradeRequest? get pendingUpgradeRequest =>
      _upgradeRequests.where((r) => r.isPending).isNotEmpty
          ? _upgradeRequests.firstWhere((r) => r.isPending)
          : null;

  // Most recent rejected request, but only when nothing newer supersedes it.
  // _upgradeRequests is newest-first (see submitUpgradeRequest).
  UpgradeRequest? get mostRecentRejectedUpgradeRequest {
    for (final r in _upgradeRequests) {
      if (r.isPending || r.isApproved) return null;
      if (r.isRejected) return r;
    }
    return null;
  }
  List<AdBanner> get adBanners => _adBanners;
  List<OilChangeBooking> get oilChangeBookings => _oilChangeBookings;
  List<String> get availableCities => _availableCities;
  List<BranchModel> get branches => _branches;
  SupportInfo? get supportInfo => _supportInfo;
  PrivacyPolicy? get privacyPolicy => _privacyPolicy;
  PaymentAccounts? get paymentAccounts => _paymentAccounts;
  List<OnboardingPageData> get onboardingPages => _onboardingPages;
  List<SubscriptionPlan> get plans => _plans;
  CarInfo? get selectedCar => _selectedCar;

  CarChangeRequest? get pendingCarChangeRequest =>
      _carChangeRequests.where((r) => r.isPending).isNotEmpty
          ? _carChangeRequests.firstWhere((r) => r.isPending)
          : null;

  bool get loadingAccidents => _loadingAccidents;
  bool get loadingAppointments => _loadingAppointments;
  bool get loadingPayments => _loadingPayments;
  bool get loadingNotifications => _loadingNotifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  AppointmentModel? get upcomingAppointment {
    final upcoming = _appointments.where(
      (a) =>
          a.scheduledDate.isAfter(DateTime.now()) &&
          a.status != AppointmentStatus.cancelled &&
          a.status != AppointmentStatus.completed,
    );
    if (upcoming.isEmpty) return null;
    return upcoming.reduce((a, b) => a.scheduledDate.isBefore(b.scheduledDate) ? a : b);
  }

  PaymentRecord? get currentDuePayment {
    final unpaid = _payments.where((p) => p.status == PaymentStatus.unpaid);
    if (unpaid.isEmpty) return null;
    return unpaid.first;
  }

  /// All payments belonging to a specific car.
  List<PaymentRecord> paymentsForCar(String carId) =>
      _payments.where((p) => p.carId == carId).toList();

  /// First unpaid/overdue payment for a specific car (or null).
  PaymentRecord? duePaymentForCar(String carId) {
    for (final p in _payments) {
      if (p.carId == carId &&
          (p.status == PaymentStatus.unpaid || p.status == PaymentStatus.overdue)) {
        return p;
      }
    }
    return null;
  }

  // ── Selected car ──────────────────────────────────────────────────────────

  void setSelectedCar(CarInfo car) {
    _selectedCar = car;
    notifyListeners();
  }

  void clearSelectedCar() {
    _selectedCar = null;
    notifyListeners();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadAll(String userId) async {
    await Future.wait([
      loadAccidents(userId),
      loadAppointments(userId),
      loadPayments(userId),
      loadNotifications(userId),
      loadAdBanners(),
      loadOilChangeBookings(userId),
      loadUpgradeRequests(userId),
      loadAvailableCities(),
      loadSupportInfo(),
      loadBranches(),
      loadPaymentAccounts(),
      loadSubscriptionPlans(),
    ]);
  }

  Future<void> loadAccidents(String userId) async {
    _loadingAccidents = true;
    _accidents = await _service.getAccidentReports(userId);
    _loadingAccidents = false;
    _safeNotify();
  }

  Future<void> loadAppointments(String userId) async {
    _loadingAppointments = true;
    _appointments = await _service.getAppointments(userId);
    _loadingAppointments = false;
    _safeNotify();
  }

  Future<void> loadPayments(String userId) async {
    _loadingPayments = true;
    _payments = await _service.getPaymentHistory(userId);
    _loadingPayments = false;
    _safeNotify();
  }

  Future<void> loadNotifications(String userId) async {
    _loadingNotifications = true;
    _notifications = await _service.getNotifications(userId);
    _loadingNotifications = false;
    _safeNotify();
  }

  Future<void> loadAdBanners() async {
    _adBanners = await _service.getAdBanners();
    _safeNotify();
  }

  Future<void> loadOilChangeBookings(String userId) async {
    _oilChangeBookings = await _service.getOilChangeBookings(userId);
    _safeNotify();
  }

  Future<void> loadAvailableCities() async {
    _availableCities = await _service.getAvailableCities();
    _safeNotify();
  }

  Future<void> loadSupportInfo() async {
    _supportInfo = await _service.getSupportInfo();
    _safeNotify();
  }

  Future<void> loadBranches() async {
    _branches = await _service.getBranches();
    _safeNotify();
  }

  Future<void> loadPrivacyPolicy() async {
    _privacyPolicy = await _service.getPrivacyPolicy();
    _safeNotify();
  }

  Future<void> loadPaymentAccounts() async {
    _paymentAccounts = await _service.getPaymentAccounts();
    _safeNotify();
  }

  Future<void> loadOnboardingPages() async {
    _onboardingPages = await _service.getOnboardingPages();
    _safeNotify();
  }

  Future<void> loadSubscriptionPlans() async {
    final fetched = await _service.getSubscriptionPlans();
    if (fetched.isNotEmpty) {
      _plans = fetched;
      SubscriptionPlan.setPlans(fetched);
    }
    _safeNotify();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<bool> submitAccidentReport({
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
    final report = await _service.submitReport(
      userId: userId,
      carId: carId,
      accidentDate: accidentDate,
      location: location,
      lat: lat,
      lng: lng,
      description: description,
      otherPartyInvolved: otherPartyInvolved,
      photoUrls: photoUrls,
    );
    _accidents.insert(0, report);
    notifyListeners();
    return true;
  }

  Future<bool> submitRepairPhotos(String reportId, List<String> photoUrls) async {
    final ok = await _service.submitRepairPhotos(reportId, photoUrls);
    if (ok) {
      final idx = _accidents.indexWhere((r) => r.id == reportId);
      if (idx != -1) {
        final existing = _accidents[idx].repairPhotoUrls ?? [];
        _accidents[idx] = _accidents[idx].copyWith(
          repairPhotoUrls: [...existing, ...photoUrls],
        );
        notifyListeners();
      }
    }
    return ok;
  }

  Future<bool> requestAppointmentChange(String appointmentId, String note) async {
    final ok = await _service.requestAppointmentChange(appointmentId, note);
    if (ok) {
      final idx = _appointments.indexWhere((a) => a.id == appointmentId);
      if (idx != -1) {
        _appointments[idx] = AppointmentModel(
          id: _appointments[idx].id,
          userId: _appointments[idx].userId,
          reportId: _appointments[idx].reportId,
          scheduledDate: _appointments[idx].scheduledDate,
          timeSlot: _appointments[idx].timeSlot,
          status: AppointmentStatus.changeRequested,
          userNote: note,
          createdAt: _appointments[idx].createdAt,
        );
        notifyListeners();
      }
    }
    return ok;
  }

  Future<bool> markPaymentMade(
    String paymentId,
    PaymentMethod method, {
    String? proofImageUrl,
  }) async {
    final ok = await _service.markPaymentMade(
      paymentId,
      method,
      proofImageUrl: proofImageUrl,
    );
    if (ok) {
      final idx = _payments.indexWhere((p) => p.id == paymentId);
      if (idx != -1) {
        _payments[idx] = _payments[idx].copyWith(
          status: PaymentStatus.paid,
          paidDate: DateTime.now(),
          method: method,
          proofImageUrl: proofImageUrl,
        );
        notifyListeners();
      }
    }
    return ok;
  }

  Future<void> markNotificationRead(String userId, String notifId) async {
    // Optimistic local update.
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].markRead();
      notifyListeners();
    }
    // Best-effort backend sync.
    await _service.markNotificationRead(userId: userId, notifId: notifId);
  }

  Future<void> markAllNotificationsRead(String userId) async {
    _notifications = _notifications.map((n) => n.markRead()).toList();
    notifyListeners();
    await _service.markAllNotificationsRead(userId);
  }

  /// Insert a push notification that just arrived via FCM into the in-memory
  /// list so the bell badge ([unreadCount]) and the notifications screen
  /// update without waiting for the next pull from the server. Idempotent —
  /// re-delivery of the same FCM message id is ignored.
  void addIncomingNotification(NotificationModel n) {
    if (_notifications.any((existing) => existing.id == n.id)) return;
    _notifications = [n, ..._notifications];
    notifyListeners();
  }

  Future<void> loadCarChangeRequests(String userId) async {
    _carChangeRequests = await _service.getCarChangeRequests(userId);
    _safeNotify();
  }

  Future<void> loadUpgradeRequests(String userId) async {
    _upgradeRequests = await _service.getUpgradeRequests(userId);
    _safeNotify();
  }

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
    String? proofImageUrl,
  }) async {
    final request = await _service.submitUpgradeRequest(
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
      proofImageUrl: proofImageUrl,
    );
    _upgradeRequests.insert(0, request);
    _safeNotify();
    return request;
  }

  Future<CarChangeRequest> submitCarChangeRequest({
    required String userId,
    required Map<String, String> requestedChanges,
    CarChangeRequestType type = CarChangeRequestType.carChange,
  }) async {
    final request = await _service.submitCarChangeRequest(
      userId: userId,
      requestedChanges: requestedChanges,
      type: type,
    );
    _carChangeRequests.insert(0, request);
    _safeNotify();
    return request;
  }

  Future<OilChangeBooking> bookOilChange({
    required String userId,
    required String carId,
    String? notes,
  }) async {
    final booking = await _service.bookOilChange(
      userId: userId,
      carId: carId,
      notes: notes,
    );
    _oilChangeBookings.insert(0, booking);
    notifyListeners();
    return booking;
  }

  // ── Safe notify ───────────────────────────────────────────────────────────

  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }
}
