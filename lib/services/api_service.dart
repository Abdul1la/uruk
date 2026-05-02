import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Real API service that replaces MockService.
/// Communicates with the Node.js backend on Spaceship.
class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  // ── Configuration ──
  // Production: uruk-services.com (Spaceship hosting)
  // Override for local testing: --dart-define=API_URL=http://localhost:3000/api
  // Android emulator: --dart-define=API_URL=http://10.0.2.2:3000/api
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://uruk-services.com/api',
  );

  String? _token;

  // ── Token persistence ──
  Future<void> loadToken() async {
    if (_token != null) return;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  bool get hasToken => _token != null;

  // ── HTTP helpers ──
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Request timeout — long enough for slow mobile networks, short enough
  /// that we don't hang the UI forever on a dead server.
  static const _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> _get(String path) async {
    await loadToken();
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl$path'), headers: _headers)
          .timeout(_timeout);
      return _handleResponse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(_networkError(e), 0);
    }
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    await loadToken();
    try {
      final res = await http
          .post(Uri.parse('$_baseUrl$path'), headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(_networkError(e), 0);
    }
  }

  Future<Map<String, dynamic>> _patch(String path, Map<String, dynamic> body) async {
    await loadToken();
    try {
      final res = await http
          .patch(Uri.parse('$_baseUrl$path'), headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(_networkError(e), 0);
    }
  }

  /// Wraps raw socket/http errors into a friendly Arabic message. Keeps the
  /// status code at 0 so callers can distinguish "network failure" (0) from
  /// "server returned 4xx/5xx" (real status codes).
  String _networkError(Object e) {
    final s = e.toString();
    if (s.contains('Connection refused') || s.contains('SocketException')) {
      return 'تعذّر الاتصال بالخادم';
    }
    if (s.contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال بالخادم';
    }
    return 'فشل الاتصال بالخادم';
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      data = {};
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(
      data['error']?.toString() ?? 'حدث خطأ (${res.statusCode})',
      res.statusCode,
    );
  }

  // ── File upload ──
  /// Cross-platform multipart upload.
  /// Takes [XFile]s from image_picker — works on iOS, Android, and Web
  /// (web can't use MultipartFile.fromPath because there's no dart:io).
  Future<List<String>> uploadFiles(List<XFile> files, {required String folder}) async {
    await loadToken();
    final uri = Uri.parse('$_baseUrl/upload/$folder');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $_token';
    for (final f in files) {
      final bytes = await f.readAsBytes();
      // Use original filename if available; fall back to a generated one.
      final filename = f.name.isNotEmpty ? f.name : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
      request.files.add(http.MultipartFile.fromBytes('files', bytes, filename: filename));
    }
    final streamRes = await request.send();
    final res = await http.Response.fromStream(streamRes);
    final data = _handleResponse(res);
    return List<String>.from(data['urls'] ?? []);
  }

  // ════════════════════════════════════════════════════
  // AUTH
  // ════════════════════════════════════════════════════

  Future<bool> sendOtp(String phone) async {
    final data = await _post('/auth/send-otp', {'phone': phone});
    return data['success'] == true;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    final data = await _post('/auth/verify-otp', {'phone': phone, 'code': otp});
    return data['success'] == true;
  }

  Future<UserModel?> login(String phone, String password) async {
    try {
      final data = await _post('/auth/login', {'phone': phone, 'password': password});
      await saveToken(data['token']);
      return _parseUser(data['user']);
    } on ApiException {
      return null;
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    final data = await _post('/auth/register', {
      'fullName': fullName,
      'phone': phone,
      'password': password,
      if (email != null) 'email': email,
    });
    await saveToken(data['token']);
    return _parseUser(data['user']);
  }

  Future<UserModel> uploadIdImages({
    required String userId,
    required String frontUrl,
    required String backUrl,
  }) async {
    final data = await _post('/auth/id-images', {
      'frontUrl': frontUrl,
      'backUrl': backUrl,
    });
    return _parseUser(data['user']);
  }

  Future<UserModel> getProfile() async {
    final data = await _get('/auth/profile');
    return _parseUser(data['user']);
  }

  Future<UserModel> refreshUser(String userId) async {
    final data = await _get('/auth/refresh');
    return _parseUser(data['user']);
  }

  // ════════════════════════════════════════════════════
  // CARS
  // ════════════════════════════════════════════════════

  Future<CarInfo> addCar({
    required String make,
    required String model,
    required int year,
    required String color,
    required String plateNumber,
    String? imageUrl,
  }) async {
    final data = await _post('/cars', {
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'plateNumber': plateNumber,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    return _parseCar(data['car']);
  }

  Future<CarInfo> subscribeCar({
    required String carId,
    required String subscription,
    required int paymentMonths,
    required int repairsAllowedPerMonth,
  }) async {
    final data = await _post('/cars/$carId/subscribe', {
      'subscription': subscription,
      'paymentMonths': paymentMonths,
      'repairsAllowedPerMonth': repairsAllowedPerMonth,
    });
    return _parseCar(data['car']);
  }

  Future<void> incrementCarRepairs(String carId) async {
    await _post('/cars/$carId/increment-repairs', {});
  }

  // ════════════════════════════════════════════════════
  // ACCIDENT REPORTS
  // ════════════════════════════════════════════════════

  Future<List<AccidentReport>> getAccidentReports(String userId) async {
    final data = await _get('/reports');
    return (data['reports'] as List).map((r) => _parseReport(r)).toList();
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
    final data = await _post('/reports', {
      if (carId != null) 'carId': carId,
      'accidentDate': accidentDate.toIso8601String(),
      'location': location,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'description': description,
      'otherPartyInvolved': otherPartyInvolved,
      'photoUrls': photoUrls,
    });
    return _parseReport(data['report']);
  }

  Future<bool> submitRepairPhotos(String reportId, List<String> photoUrls) async {
    await _post('/reports/$reportId/repair-photos', {'photoUrls': photoUrls});
    return true;
  }

  // ════════════════════════════════════════════════════
  // APPOINTMENTS
  // ════════════════════════════════════════════════════

  Future<List<AppointmentModel>> getAppointments(String userId) async {
    final data = await _get('/appointments');
    return (data['appointments'] as List).map((a) => _parseAppointment(a)).toList();
  }

  Future<bool> requestAppointmentChange(String appointmentId, String note) async {
    await _post('/appointments/$appointmentId/request-change', {'note': note});
    return true;
  }

  // ════════════════════════════════════════════════════
  // PAYMENTS
  // ════════════════════════════════════════════════════

  Future<List<PaymentRecord>> getPaymentHistory(String userId) async {
    final data = await _get('/payments');
    return (data['payments'] as List).map((p) => _parsePayment(p)).toList();
  }

  Future<bool> markPaymentMade(String paymentId, PaymentMethod method, {String? proofImageUrl}) async {
    await _post('/payments/$paymentId/mark-paid', {
      'method': method.name,
      if (proofImageUrl != null) 'proofImageUrl': proofImageUrl,
    });
    return true;
  }

  Future<PaymentAccounts> getPaymentAccounts() async {
    final data = await _get('/payments/accounts');
    return PaymentAccounts.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<OnboardingPageData>> getOnboardingPages() async {
    try {
      final data = await _get('/config/onboarding');
      final list = (data['pages'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((e) => OnboardingPageData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ════════════════════════════════════════════════════
  // OIL CHANGES
  // ════════════════════════════════════════════════════

  Future<OilChangeBooking> bookOilChange({
    required String userId,
    required String carId,
    String? notes,
  }) async {
    final data = await _post('/oil-changes', {
      'carId': carId,
      if (notes != null) 'notes': notes,
    });
    return _parseOilChange(data['booking']);
  }

  Future<List<OilChangeBooking>> getOilChangeBookings(String userId) async {
    final data = await _get('/oil-changes');
    return (data['bookings'] as List).map((b) => _parseOilChange(b)).toList();
  }

  // ════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ════════════════════════════════════════════════════

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final data = await _get('/notifications');
    return (data['notifications'] as List).map((n) => _parseNotification(n)).toList();
  }

  /// Fire-and-forget: never throws. Marking a notification read should not
  /// break the UI if the server is briefly unreachable.
  Future<bool> markNotificationRead({required String userId, required String notifId}) async {
    try {
      await _post('/notifications/$notifId/read', {});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllNotificationsRead(String userId) async {
    try {
      await _post('/notifications/read-all', {});
      return true;
    } catch (_) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════
  // REQUESTS
  // ════════════════════════════════════════════════════

  Future<CarChangeRequest> submitCarChangeRequest({
    required String userId,
    required Map<String, String> requestedChanges,
    CarChangeRequestType type = CarChangeRequestType.carChange,
  }) async {
    final data = await _post('/car-change-requests', {
      'requestedChanges': requestedChanges,
      'type': type.name,
    });
    return _parseCarChangeRequest(data['request']);
  }

  Future<List<CarChangeRequest>> getCarChangeRequests(String userId) async {
    final data = await _get('/car-change-requests');
    return (data['requests'] as List).map((r) => _parseCarChangeRequest(r)).toList();
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
    final data = await _post('/upgrade-requests', {
      'carId': carId,
      'currentPlan': currentPlan.name,
      'currentPlanPriceIQD': currentPlanPriceIQD,
      'remainingMonths': remainingMonths,
      'creditIQD': creditIQD,
      'requestedPlan': requestedPlan.name,
      'requestedPlanPriceIQD': requestedPlanPriceIQD,
      'requestedMonths': requestedMonths,
      'newCostIQD': newCostIQD,
      'amountDueIQD': amountDueIQD,
      if (proofImageUrl != null) 'proofImageUrl': proofImageUrl,
    });
    return _parseUpgradeRequest(data['request']);
  }

  Future<List<UpgradeRequest>> getUpgradeRequests(String userId) async {
    final data = await _get('/upgrade-requests');
    return (data['requests'] as List).map((r) => _parseUpgradeRequest(r)).toList();
  }

  // ════════════════════════════════════════════════════
  // CONFIG (public)
  // ════════════════════════════════════════════════════

  Future<SupportInfo> getSupportInfo() async {
    final data = await _get('/config/support');
    return SupportInfo(
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      whatsapp: data['whatsapp'],
      address: data['address'],
      workingHours: data['workingHours'],
      instagram: data['instagram'],
      facebook: data['facebook'],
      telegram: data['telegram'],
      website: data['website'],
    );
  }

  Future<List<BranchModel>> getBranches() async {
    final data = await _get('/config/branches');
    return (data['branches'] as List).map((b) => BranchModel.fromJson(b as Map<String, dynamic>)).toList();
  }

  Future<PrivacyPolicy> getPrivacyPolicy() async {
    final data = await _get('/config/privacy');
    return PrivacyPolicy(
      content: data['content'] ?? '',
      updatedAt: data['updatedAt'] ?? '',
    );
  }

  Future<List<String>> getAvailableCities() async {
    final data = await _get('/config/cities');
    return List<String>.from(data['cities'] ?? []);
  }

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final data = await _get('/config/plans');
    return (data['plans'] as List).map((p) => _parsePlan(p)).toList();
  }

  Future<List<AdBanner>> getAdBanners() async {
    final data = await _get('/config/banners');
    return (data['banners'] as List).map((b) => AdBanner.fromJson(b as Map<String, dynamic>)).toList();
  }

  // ════════════════════════════════════════════════════
  // PARSERS
  // ════════════════════════════════════════════════════

  UserModel _parseUser(Map<String, dynamic> j) {
    return UserModel(
      id: j['id'],
      fullName: j['fullName'] ?? '',
      phone: j['phone'] ?? '',
      email: j['email'],
      idFrontUrl: j['idFrontUrl'],
      idBackUrl: j['idBackUrl'],
      status: _parseUserStatus(j['status']),
      paymentDue: j['paymentDue'] == true,
      cars: (j['cars'] as List?)?.map((c) => _parseCar(c)).toList() ?? [],
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  CarInfo _parseCar(Map<String, dynamic> j) {
    return CarInfo(
      id: j['id'],
      make: j['make'] ?? '',
      model: j['model'] ?? '',
      year: j['year'] ?? 0,
      color: j['color'] ?? '',
      plateNumber: j['plateNumber'] ?? '',
      imageUrl: _normalizeUrl(j['imageUrl']),
      subscription: _parseSubscriptionType(j['subscription']),
      subscriptionStart: DateTime.tryParse(j['subscriptionStart']?.toString() ?? ''),
      subscriptionExpiry: DateTime.tryParse(j['subscriptionExpiry']?.toString() ?? ''),
      paymentMonths: j['paymentMonths'] ?? 1,
      repairsAllowedPerMonth: j['repairsAllowedPerMonth'] ?? 0,
      repairsUsedThisMonth: j['repairsUsedThisMonth'] ?? 0,
    );
  }

  // Upgrade http:// → https:// when the API itself is served over HTTPS.
  // The backend behind a TLS-terminating proxy can mistakenly build http://
  // URLs for uploads; browsers block those as mixed content on https pages.
  static String? _normalizeUrl(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString();
    if (s.isEmpty) return null;
    if (_baseUrl.startsWith('https://') && s.startsWith('http://')) {
      return 'https://${s.substring('http://'.length)}';
    }
    return s;
  }

  AccidentReport _parseReport(Map<String, dynamic> j) {
    return AccidentReport(
      id: j['id'],
      userId: j['userId'] ?? '',
      carId: j['carId'],
      accidentDate: DateTime.tryParse(j['accidentDate']?.toString() ?? '') ?? DateTime.now(),
      location: j['location'] ?? '',
      lat: (j['lat'] as num?)?.toDouble(),
      lng: (j['lng'] as num?)?.toDouble(),
      description: j['description'] ?? '',
      photoUrls: List<String>.from(j['photoUrls'] ?? []),
      otherPartyInvolved: j['otherPartyInvolved'] == true,
      status: _parseReportStatus(j['status']),
      submittedAt: DateTime.tryParse(j['submittedAt']?.toString() ?? '') ?? DateTime.now(),
      maintenanceNotes: j['maintenanceNotes'],
      repairPhotoUrls: j['repairPhotoUrls'] != null ? List<String>.from(j['repairPhotoUrls']) : null,
      completedAt: DateTime.tryParse(j['completedAt']?.toString() ?? ''),
      appointmentId: j['appointmentId'],
      rejectionReason: j['rejectionReason'],
      repairArchive: (j['repairArchive'] as List?)?.map((e) => RepairEntry(
        date: DateTime.tryParse(e['date']?.toString() ?? '') ?? DateTime.now(),
        technician: e['technician'] ?? '',
        description: e['description'] ?? '',
        partsReplaced: List<String>.from(e['partsReplaced'] ?? []),
        photos: List<String>.from(e['photos'] ?? []),
        cost: e['cost'] ?? 0,
        isFinal: e['isFinal'] == true,
      )).toList() ?? [],
    );
  }

  AppointmentModel _parseAppointment(Map<String, dynamic> j) {
    return AppointmentModel(
      id: j['id'],
      userId: j['userId'] ?? '',
      reportId: j['reportId'] ?? '',
      scheduledDate: DateTime.tryParse(j['scheduledDate']?.toString() ?? '') ?? DateTime.now(),
      timeSlot: j['timeSlot'] ?? '',
      status: _parseAppointmentStatus(j['status']),
      userNote: j['userNote'],
      maintenanceNote: j['maintenanceNote'],
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      branchName: j['branchName'],
      locationLat: (j['locationLat'] as num?)?.toDouble(),
      locationLng: (j['locationLng'] as num?)?.toDouble(),
    );
  }

  PaymentRecord _parsePayment(Map<String, dynamic> j) {
    return PaymentRecord(
      id: j['id'],
      userId: j['userId'] ?? '',
      carId: j['carId'],
      carDesc: j['carDesc'],
      amountIQD: j['amountIQD'] ?? 0,
      dueDate: DateTime.tryParse(j['dueDate']?.toString() ?? '') ?? DateTime.now(),
      paidDate: DateTime.tryParse(j['paidDate']?.toString() ?? ''),
      status: _parsePaymentStatus(j['status']),
      method: _parsePaymentMethod(j['method']),
      month: j['month'] ?? '',
      proofImageUrl: j['proofImageUrl'],
    );
  }

  OilChangeBooking _parseOilChange(Map<String, dynamic> j) {
    return OilChangeBooking(
      id: j['id'],
      userId: j['userId'] ?? '',
      carId: j['carId'] ?? '',
      scheduledDate: DateTime.tryParse(j['scheduledDate']?.toString() ?? ''),
      timeSlot: j['timeSlot'],
      branchName: j['branchName'],
      locationLat: (j['locationLat'] as num?)?.toDouble(),
      locationLng: (j['locationLng'] as num?)?.toDouble(),
      status: _parseOilStatus(j['status']),
      notes: j['notes'],
      priceIQD: j['priceIQD'] ?? 15000,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  NotificationModel _parseNotification(Map<String, dynamic> j) {
    return NotificationModel(
      id: j['id'],
      userId: j['userId'] ?? '',
      title: j['title'] ?? '',
      body: j['body'] ?? '',
      type: _parseNotifType(j['type']),
      isRead: j['isRead'] == true,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      actionRoute: j['actionRoute'],
    );
  }

  CarChangeRequest _parseCarChangeRequest(Map<String, dynamic> j) {
    return CarChangeRequest(
      id: j['id'],
      userId: j['userId'] ?? '',
      type: j['type'] == 'profileEdit'
          ? CarChangeRequestType.profileEdit
          : CarChangeRequestType.carChange,
      requestedChanges: Map<String, String>.from(j['requestedChanges'] ?? {}),
      status: _parseCCRStatus(j['status']),
      submittedAt: DateTime.tryParse(j['submittedAt']?.toString() ?? '') ?? DateTime.now(),
      reviewedAt: DateTime.tryParse(j['reviewedAt']?.toString() ?? ''),
      reviewNote: j['reviewNote'],
    );
  }

  UpgradeRequest _parseUpgradeRequest(Map<String, dynamic> j) {
    return UpgradeRequest(
      id: j['id'],
      userId: j['userId'] ?? '',
      carId: j['carId'] ?? '',
      currentPlan: _parseSubscriptionType(j['currentPlan']),
      currentPlanPriceIQD: j['currentPlanPriceIQD'] ?? 0,
      remainingMonths: j['remainingMonths'] ?? 0,
      creditIQD: j['creditIQD'] ?? 0,
      requestedPlan: _parseSubscriptionType(j['requestedPlan']),
      requestedPlanPriceIQD: j['requestedPlanPriceIQD'] ?? 0,
      requestedMonths: j['requestedMonths'] ?? 0,
      newCostIQD: j['newCostIQD'] ?? 0,
      amountDueIQD: j['amountDueIQD'] ?? 0,
      proofImageUrl: j['proofImageUrl'],
      status: _parseUpgradeStatus(j['status']),
      submittedAt: DateTime.tryParse(j['submittedAt']?.toString() ?? '') ?? DateTime.now(),
      reviewedAt: DateTime.tryParse(j['reviewedAt']?.toString() ?? ''),
      adminNote: j['adminNote'],
    );
  }

  SubscriptionPlan _parsePlan(Map<String, dynamic> j) {
    return SubscriptionPlan(
      id: j['id'] ?? '',
      type: _parseSubscriptionType(j['type']),
      name: j['name'] ?? '',
      priceIQD: j['priceIQD'] ?? 0,
      coverageNote: j['coverageNote'] ?? '',
      coveredParts: List<String>.from(j['coveredParts'] ?? []),
      repairTiers: (j['repairTiers'] as List?)?.map((t) => RepairTier(
        label: t['label'] ?? '',
        months: t['months'] ?? 1,
        repairsPerMonth: t['repairsPerMonth'] ?? 0,
      )).toList() ?? [],
      isPopular: j['isPopular'] == true,
    );
  }

  // ── Enum parsers ──
  UserStatus _parseUserStatus(String? s) {
    switch (s) {
      case 'approved': return UserStatus.approved;
      case 'rejected': return UserStatus.rejected;
      case 'suspended': return UserStatus.suspended;
      default: return UserStatus.pending;
    }
  }

  SubscriptionType _parseSubscriptionType(String? s) {
    switch (s) {
      case 'standard': return SubscriptionType.standard;
      case 'shared': return SubscriptionType.shared;
      case 'vip': return SubscriptionType.vip;
      default: return SubscriptionType.none;
    }
  }

  ReportStatus _parseReportStatus(String? s) {
    switch (s) {
      case 'underReview': return ReportStatus.underReview;
      case 'approved': return ReportStatus.approved;
      case 'inRepair': return ReportStatus.inRepair;
      case 'completed': return ReportStatus.completed;
      case 'rejected': return ReportStatus.rejected;
      default: return ReportStatus.pending;
    }
  }

  AppointmentStatus _parseAppointmentStatus(String? s) {
    switch (s) {
      case 'changeRequested': return AppointmentStatus.changeRequested;
      case 'confirmed': return AppointmentStatus.confirmed;
      case 'completed': return AppointmentStatus.completed;
      case 'cancelled': return AppointmentStatus.cancelled;
      default: return AppointmentStatus.scheduled;
    }
  }

  PaymentStatus _parsePaymentStatus(String? s) {
    switch (s) {
      case 'paid': return PaymentStatus.paid;
      case 'overdue': return PaymentStatus.overdue;
      default: return PaymentStatus.unpaid;
    }
  }

  PaymentMethod? _parsePaymentMethod(String? s) {
    switch (s) {
      case 'zaincash': return PaymentMethod.zaincash;
      case 'superQi': return PaymentMethod.superQi;
      case 'other': return PaymentMethod.other;
      default: return null;
    }
  }

  OilChangeStatus _parseOilStatus(String? s) {
    switch (s) {
      case 'confirmed': return OilChangeStatus.confirmed;
      case 'completed': return OilChangeStatus.completed;
      case 'cancelled': return OilChangeStatus.cancelled;
      default: return OilChangeStatus.pending;
    }
  }

  NotificationType _parseNotifType(String? s) {
    switch (s) {
      case 'payment': return NotificationType.payment;
      case 'appointment': return NotificationType.appointment;
      case 'report': return NotificationType.report;
      case 'subscription': return NotificationType.subscription;
      default: return NotificationType.general;
    }
  }

  CarChangeRequestStatus _parseCCRStatus(String? s) {
    switch (s) {
      case 'approved': return CarChangeRequestStatus.approved;
      case 'rejected': return CarChangeRequestStatus.rejected;
      default: return CarChangeRequestStatus.pending;
    }
  }

  UpgradeRequestStatus _parseUpgradeStatus(String? s) {
    switch (s) {
      case 'approved': return UpgradeRequestStatus.approved;
      case 'rejected': return UpgradeRequestStatus.rejected;
      default: return UpgradeRequestStatus.pending;
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
