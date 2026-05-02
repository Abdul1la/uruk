import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum AuthState {
  unauthenticated,
  loading,
  authenticated,
  pending,
  suspended,
  rejected,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.unauthenticated;
  UserModel? _user;
  String? _errorMessage;
  bool _otpSent = false;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get otpSent => _otpSent;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isPending => _user?.status == UserStatus.pending;
  bool get isSuspended => _user?.status == UserStatus.suspended;
  bool get isRejected => _user?.status == UserStatus.rejected;

  final _service = ApiService();

  /// Map a user's backend status onto an AuthState. Used by [login],
  /// [register] and [refreshUser] so the three paths stay consistent.
  AuthState _stateForStatus(UserStatus status) {
    switch (status) {
      case UserStatus.approved:
        return AuthState.authenticated;
      case UserStatus.pending:
        return AuthState.pending;
      case UserStatus.suspended:
        return AuthState.suspended;
      case UserStatus.rejected:
        return AuthState.rejected;
    }
  }

  Future<bool> login(String phone, String password) async {
    _setState(AuthState.loading);
    try {
      final user = await _service.login(phone, password);
      if (user != null) {
        _user = user;
        _setState(_stateForStatus(user.status));
        // Callers can check isAuthenticated to decide on navigation. A
        // suspended / rejected user is NOT considered "logged in".
        return user.status == UserStatus.approved ||
            user.status == UserStatus.pending;
      }
      _errorMessage = 'Invalid phone number or password';
      _setState(AuthState.unauthenticated);
      return false;
    } catch (_) {
      _errorMessage = 'Login failed. Please try again.';
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> sendOtp(String phone) async {
    _setState(AuthState.loading);
    try {
      _otpSent = await _service.sendOtp(phone);
      _setState(AuthState.unauthenticated);
      return _otpSent;
    } catch (_) {
      _errorMessage = 'Failed to send OTP. Please try again.';
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _setState(AuthState.loading);
    try {
      final ok = await _service.verifyOtp(phone, otp);
      _setState(AuthState.unauthenticated);
      return ok;
    } catch (_) {
      _errorMessage = 'OTP verification failed.';
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    _setState(AuthState.loading);
    try {
      _user = await _service.register(
        fullName: fullName,
        phone: phone,
        password: password,
        email: email,
      );
      _setState(_stateForStatus(_user!.status));
      return true;
    } catch (_) {
      _errorMessage = 'Registration failed. Please try again.';
      _setState(AuthState.error);
      return false;
    }
  }

  /// Try to restore a previous session from the saved JWT token.
  /// Returns `true` if a valid session was restored (check [isAuthenticated]
  /// or [isPending] to decide where to navigate).
  Future<bool> tryRestoreSession() async {
    try {
      await _service.loadToken();
      if (!_service.hasToken) return false;
      final user = await _service.getProfile();
      _user = user;
      _setState(_stateForStatus(user.status));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Pull the latest user record from the backend (used by the pending
  /// approval screen, the splash screen, and after app resume to detect
  /// admin approvals / suspensions).
  Future<void> refreshUser() async {
    if (_user == null) return;
    try {
      final updated = await _service.refreshUser(_user!.id);
      _user = updated;
      _setState(_stateForStatus(updated.status));
    } catch (_) {
      // swallow — best-effort refresh
    }
  }

  /// Persist the uploaded national-ID images on the backend and keep the
  /// local user in sync.
  Future<bool> submitIdImages({
    required String frontUrl,
    required String backUrl,
  }) async {
    if (_user == null) return false;
    try {
      final updated = await _service.uploadIdImages(
        userId: _user!.id,
        frontUrl: frontUrl,
        backUrl: backUrl,
      );
      _user = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Add a new car to the user's car list.
  void addCar(CarInfo car) {
    if (_user != null) {
      _user = _user!.copyWith(cars: [..._user!.cars, car]);
      notifyListeners();
    }
  }

  /// Backward-compat: replaces the first car (or adds if list is empty).
  void updateCar(CarInfo car) {
    if (_user != null) {
      _user = _user!.copyWith(car: car);
      notifyListeners();
    }
  }

  /// Replace a specific car by id.
  void updateCarById(CarInfo updated) {
    if (_user == null) return;
    final idx = _user!.cars.indexWhere((c) => c.id == updated.id);
    if (idx == -1) return;
    final newCars = List<CarInfo>.from(_user!.cars);
    newCars[idx] = updated;
    _user = _user!.copyWith(cars: newCars);
    notifyListeners();
  }

  /// Apply a subscription plan + payment period to a specific car.
  void subscribeCar({
    required String carId,
    required SubscriptionType type,
    required int paymentMonths,
    required int repairsAllowedPerMonth,
  }) {
    if (_user == null) return;
    final idx = _user!.cars.indexWhere((c) => c.id == carId);
    if (idx == -1) return;
    final expiry = DateTime.now().add(Duration(days: 30 * paymentMonths));
    final newCars = List<CarInfo>.from(_user!.cars);
    newCars[idx] = _user!.cars[idx].copyWith(
      subscription: type,
      subscriptionExpiry: expiry,
      paymentMonths: paymentMonths,
      repairsAllowedPerMonth: repairsAllowedPerMonth,
      repairsUsedThisMonth: 0,
    );
    _user = _user!.copyWith(cars: newCars);
    notifyListeners();
  }

  /// Increment the repair counter for a specific car (called after accident report submitted).
  void incrementCarRepairs(String carId) {
    if (_user == null) return;
    final idx = _user!.cars.indexWhere((c) => c.id == carId);
    if (idx == -1) return;
    final newCars = List<CarInfo>.from(_user!.cars);
    newCars[idx] = _user!.cars[idx].copyWith(
      repairsUsedThisMonth: _user!.cars[idx].repairsUsedThisMonth + 1,
    );
    _user = _user!.copyWith(cars: newCars);
    notifyListeners();
  }

  void logout() {
    _user = null;
    _otpSent = false;
    _errorMessage = null;
    _service.clearToken();
    _setState(AuthState.unauthenticated);
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }
}
