enum UserStatus { pending, approved, rejected, suspended }

enum SubscriptionType { none, standard, shared, vip }

class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? idFrontUrl;
  final String? idBackUrl;
  final UserStatus status;
  final bool paymentDue;
  final List<CarInfo> cars;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.idFrontUrl,
    this.idBackUrl,
    required this.status,
    this.paymentDue = false,
    this.cars = const [],
    required this.createdAt,
  });

  // ── Backward-compat getters ─────────────────────────────────────────────────

  /// First car with an active subscription, or `none`.
  SubscriptionType get subscription {
    for (final c in cars) {
      if (c.subscription != SubscriptionType.none) return c.subscription;
    }
    return SubscriptionType.none;
  }

  /// Expiry of the first active subscription.
  DateTime? get subscriptionExpiry {
    for (final c in cars) {
      if (c.subscriptionExpiry != null) return c.subscriptionExpiry;
    }
    return null;
  }

  /// First car (null if no cars) — kept for backward compat.
  CarInfo? get car => cars.isEmpty ? null : cars.first;

  // ── copyWith ────────────────────────────────────────────────────────────────

  UserModel copyWith({
    String? fullName,
    String? email,
    String? idFrontUrl,
    String? idBackUrl,
    UserStatus? status,
    bool? paymentDue,
    List<CarInfo>? cars,
    /// Kept for backward compat: replaces/inserts the first car.
    CarInfo? car,
  }) {
    List<CarInfo> newCars = cars ?? this.cars;
    if (car != null) {
      if (newCars.isEmpty) {
        newCars = [car];
      } else {
        newCars = [car, ...newCars.skip(1)];
      }
    }
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone,
      email: email ?? this.email,
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      status: status ?? this.status,
      paymentDue: paymentDue ?? this.paymentDue,
      cars: newCars,
      createdAt: createdAt,
    );
  }
}

// ── CarInfo ───────────────────────────────────────────────────────────────────

class CarInfo {
  final String id;
  final String make;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final String? imageUrl;
  final SubscriptionType subscription;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionExpiry;

  /// How many months were prepaid: 1 (monthly), 3, 6, or 12.
  final int paymentMonths;

  /// Repairs allowed per month — derived from plan + paymentMonths at subscribe time.
  final int repairsAllowedPerMonth;

  /// How many repairs have been submitted this month (server-tracked in real app).
  final int repairsUsedThisMonth;

  const CarInfo({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    this.imageUrl,
    this.subscription = SubscriptionType.none,
    this.subscriptionStart,
    this.subscriptionExpiry,
    this.paymentMonths = 1,
    this.repairsAllowedPerMonth = 0,
    this.repairsUsedThisMonth = 0,
  });

  /// Repairs remaining this month.
  int get repairsRemaining =>
      (repairsAllowedPerMonth - repairsUsedThisMonth).clamp(0, repairsAllowedPerMonth);

  /// True when the quota for this month is exhausted.
  bool get repairsExhausted =>
      subscription != SubscriptionType.none && repairsUsedThisMonth >= repairsAllowedPerMonth;

  CarInfo copyWith({
    String? make,
    String? model,
    int? year,
    String? color,
    String? plateNumber,
    String? imageUrl,
    SubscriptionType? subscription,
    DateTime? subscriptionStart,
    DateTime? subscriptionExpiry,
    int? paymentMonths,
    int? repairsAllowedPerMonth,
    int? repairsUsedThisMonth,
  }) {
    return CarInfo(
      id: id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      plateNumber: plateNumber ?? this.plateNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      subscription: subscription ?? this.subscription,
      subscriptionStart: subscriptionStart ?? this.subscriptionStart,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      paymentMonths: paymentMonths ?? this.paymentMonths,
      repairsAllowedPerMonth: repairsAllowedPerMonth ?? this.repairsAllowedPerMonth,
      repairsUsedThisMonth: repairsUsedThisMonth ?? this.repairsUsedThisMonth,
    );
  }
}
