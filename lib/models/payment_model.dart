enum PaymentStatus { paid, unpaid, overdue }
enum PaymentMethod { zaincash, superQi, other }

class PaymentRecord {
  final String id;
  final String userId;
  /// The car this payment is for (subscriptions are per-car).
  final String? carId;
  /// Human-readable car description (e.g. "تويوتا كامري 2021").
  final String? carDesc;
  final int amountIQD;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentStatus status;
  final PaymentMethod? method;
  final String month; // e.g. "April 2026"
  /// Remote URL of the uploaded proof image (returned by the upload service).
  final String? proofImageUrl;

  const PaymentRecord({
    required this.id,
    required this.userId,
    this.carId,
    this.carDesc,
    required this.amountIQD,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.method,
    required this.month,
    this.proofImageUrl,
  });

  PaymentRecord copyWith({
    PaymentStatus? status,
    DateTime? paidDate,
    PaymentMethod? method,
    String? proofImageUrl,
  }) {
    return PaymentRecord(
      id: id,
      userId: userId,
      carId: carId,
      carDesc: carDesc,
      amountIQD: amountIQD,
      dueDate: dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      method: method ?? this.method,
      month: month,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
    );
  }
}
