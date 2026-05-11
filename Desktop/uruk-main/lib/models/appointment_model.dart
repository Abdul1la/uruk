enum AppointmentStatus { scheduled, changeRequested, confirmed, completed, cancelled }

class AppointmentModel {
  final String id;
  final String userId;
  final String reportId;
  final DateTime scheduledDate;
  final String timeSlot;
  final AppointmentStatus status;
  final String? userNote;
  final String? maintenanceNote;
  final DateTime createdAt;

  /// Branch / service center name assigned by admin.
  final String? branchName;

  /// Latitude of the service center.
  final double? locationLat;

  /// Longitude of the service center.
  final double? locationLng;

  const AppointmentModel({
    required this.id,
    required this.userId,
    required this.reportId,
    required this.scheduledDate,
    required this.timeSlot,
    this.status = AppointmentStatus.scheduled,
    this.userNote,
    this.maintenanceNote,
    required this.createdAt,
    this.branchName,
    this.locationLat,
    this.locationLng,
  });

  /// Whether this appointment has a navigable location.
  bool get hasLocation => locationLat != null && locationLng != null;

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.scheduled: return 'Scheduled';
      case AppointmentStatus.changeRequested: return 'Change Requested';
      case AppointmentStatus.confirmed: return 'Confirmed';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
    }
  }
}
