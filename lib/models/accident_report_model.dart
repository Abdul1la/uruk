enum ReportStatus { pending, underReview, approved, inRepair, completed, rejected }

class RepairEntry {
  final DateTime date;
  final String technician;
  final String description;
  final List<String> partsReplaced;
  final List<String> photos;
  final int cost; // IQD — optional (0 if not tracked)
  final bool isFinal;

  const RepairEntry({
    required this.date,
    required this.technician,
    required this.description,
    this.partsReplaced = const [],
    this.photos = const [],
    this.cost = 0,
    this.isFinal = false,
  });
}

class AccidentReport {
  final String id;
  final String userId;
  /// Car this accident report belongs to.
  final String? carId;
  final DateTime accidentDate;
  final String location;
  /// Latitude where the accident happened (set from the map picker).
  final double? lat;
  /// Longitude where the accident happened (set from the map picker).
  final double? lng;
  final String description;
  final List<String> photoUrls;
  final bool otherPartyInvolved;
  final ReportStatus status;
  final DateTime submittedAt;
  final String? maintenanceNotes;
  final List<String>? repairPhotoUrls;
  final DateTime? completedAt;
  final String? appointmentId;
  final List<RepairEntry> repairArchive;

  /// Set by the maintenance team when a report is rejected.
  final String? rejectionReason;

  const AccidentReport({
    required this.id,
    required this.userId,
    this.carId,
    required this.accidentDate,
    required this.location,
    this.lat,
    this.lng,
    required this.description,
    required this.photoUrls,
    this.otherPartyInvolved = false,
    this.status = ReportStatus.pending,
    required this.submittedAt,
    this.maintenanceNotes,
    this.repairPhotoUrls,
    this.completedAt,
    this.appointmentId,
    this.repairArchive = const [],
    this.rejectionReason,
  });

  /// Whether this report has navigable coordinates.
  bool get hasLocation => lat != null && lng != null;

  AccidentReport copyWith({
    ReportStatus? status,
    String? maintenanceNotes,
    List<String>? repairPhotoUrls,
    DateTime? completedAt,
    List<RepairEntry>? repairArchive,
    String? rejectionReason,
  }) {
    return AccidentReport(
      id: id,
      userId: userId,
      carId: carId,
      accidentDate: accidentDate,
      location: location,
      lat: lat,
      lng: lng,
      description: description,
      photoUrls: photoUrls,
      otherPartyInvolved: otherPartyInvolved,
      status: status ?? this.status,
      submittedAt: submittedAt,
      maintenanceNotes: maintenanceNotes ?? this.maintenanceNotes,
      repairPhotoUrls: repairPhotoUrls ?? this.repairPhotoUrls,
      completedAt: completedAt ?? this.completedAt,
      appointmentId: appointmentId,
      repairArchive: repairArchive ?? this.repairArchive,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  String get statusLabel {
    switch (status) {
      case ReportStatus.pending: return 'Pending';
      case ReportStatus.underReview: return 'Under Review';
      case ReportStatus.approved: return 'Approved';
      case ReportStatus.inRepair: return 'In Repair';
      case ReportStatus.completed: return 'Completed';
      case ReportStatus.rejected: return 'Rejected';
    }
  }
}
