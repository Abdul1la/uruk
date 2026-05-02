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
}
