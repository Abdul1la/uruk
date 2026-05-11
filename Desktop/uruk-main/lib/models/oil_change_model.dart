enum OilChangeStatus { pending, confirmed, completed, cancelled }

class OilChangeBooking {
  final String id;
  final String userId;
  final String carId;
  /// Scheduled date — set by admin after the request is submitted.
  final DateTime? scheduledDate;
  /// Time slot — set by admin after the request is submitted.
  final String? timeSlot;
  /// Branch / service center name — set by admin after request is submitted.
  final String? branchName;
  /// Latitude of the assigned branch.
  final double? locationLat;
  /// Longitude of the assigned branch.
  final double? locationLng;
  final OilChangeStatus status;
  final String? notes;
  final int priceIQD;
  final DateTime createdAt;

  const OilChangeBooking({
    required this.id,
    required this.userId,
    required this.carId,
    this.scheduledDate,
    this.timeSlot,
    this.branchName,
    this.locationLat,
    this.locationLng,
    this.status = OilChangeStatus.pending,
    this.notes,
    this.priceIQD = 15000,
    required this.createdAt,
  });

  /// Whether this booking has navigable coordinates set by admin.
  bool get hasLocation => locationLat != null && locationLng != null;

  String get statusLabel {
    switch (status) {
      case OilChangeStatus.pending:   return 'قيد الانتظار';
      case OilChangeStatus.confirmed: return 'مؤكد';
      case OilChangeStatus.completed: return 'مكتمل';
      case OilChangeStatus.cancelled: return 'ملغي';
    }
  }
}
