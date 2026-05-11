enum CarChangeRequestStatus { pending, approved, rejected }

/// Discriminator so the admin panel knows whether the user is editing their
/// profile or their car details (both flow through this same model).
enum CarChangeRequestType { profileEdit, carChange }

class CarChangeRequest {
  final String id;
  final String userId;
  /// What kind of change this request represents.
  final CarChangeRequestType type;
  /// Fields the subscriber wants to change: {'make': 'BMW', 'color': 'أسود', ...}
  final Map<String, String> requestedChanges;
  final CarChangeRequestStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNote;

  const CarChangeRequest({
    required this.id,
    required this.userId,
    this.type = CarChangeRequestType.carChange,
    required this.requestedChanges,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewNote,
  });

  bool get isPending => status == CarChangeRequestStatus.pending;
  bool get isApproved => status == CarChangeRequestStatus.approved;
  bool get isRejected => status == CarChangeRequestStatus.rejected;

  String get statusLabel {
    switch (status) {
      case CarChangeRequestStatus.pending:
        return 'قيد المراجعة';
      case CarChangeRequestStatus.approved:
        return 'مقبول';
      case CarChangeRequestStatus.rejected:
        return 'مرفوض';
    }
  }

  static const fieldLabels = {
    'make': 'الشركة المصنّعة',
    'model': 'الموديل',
    'year': 'سنة الصنع',
    'color': 'اللون',
    'plateNumber': 'رقم اللوحة',
  };
}
