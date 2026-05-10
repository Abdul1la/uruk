enum NotificationType { payment, appointment, report, subscription, general }

class NotificationModel {
  final String id;
  /// Recipient user id, or `'all'` for broadcast.
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? actionRoute;

  const NotificationModel({
    required this.id,
    this.userId = 'all',
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.actionRoute,
  });

  NotificationModel markRead() => NotificationModel(
        id: id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        isRead: true,
        createdAt: createdAt,
        actionRoute: actionRoute,
      );

  /// Build a [NotificationModel] from an FCM data payload. Returns `null`
  /// when the payload is empty AND no fallback fields are provided (e.g. a
  /// pure visual-only `notification:`-only message we can't represent in the
  /// app's notification list).
  ///
  /// Expected payload shape (sent from the backend via FCM `data:`):
  /// ```json
  /// {
  ///   "id": "abc123",
  ///   "userId": "user_42",
  ///   "title": "Payment due",
  ///   "body": "Your subscription expires in 3 days",
  ///   "type": "payment",
  ///   "actionRoute": "/payment",
  ///   "createdAt": "2026-05-07T12:00:00Z"
  /// }
  /// ```
  /// All keys come through as Strings on the wire — FCM `data` is a
  /// `Map<String, String>`. We accept `Map<String, dynamic>` here so the
  /// same factory works when the payload is reconstructed from JSON.
  static NotificationModel? fromFcmData(
    Map<String, dynamic> data, {
    String? fallbackTitle,
    String? fallbackBody,
  }) {
    final title = (data['title'] as String?) ?? fallbackTitle;
    final body = (data['body'] as String?) ?? fallbackBody;
    if (title == null && body == null && data['id'] == null) return null;

    return NotificationModel(
      id: (data['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: (data['userId'] as String?) ?? 'all',
      title: title ?? '',
      body: body ?? '',
      type: _parseType(data['type'] as String?),
      isRead: false,
      createdAt: DateTime.tryParse((data['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      actionRoute: data['actionRoute'] as String?,
    );
  }

  static NotificationType _parseType(String? s) {
    switch (s) {
      case 'payment':
        return NotificationType.payment;
      case 'appointment':
        return NotificationType.appointment;
      case 'report':
        return NotificationType.report;
      case 'subscription':
        return NotificationType.subscription;
      default:
        return NotificationType.general;
    }
  }
}
