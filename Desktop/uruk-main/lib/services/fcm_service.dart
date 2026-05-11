import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_model.dart';

/// Background isolate handler. Must be a top-level / static function annotated
/// with `@pragma('vm:entry-point')` so the AOT compiler keeps it. The system
/// shows the banner automatically when the FCM payload includes `notification:
/// {...}` — we don't need to do anything heavy here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Re-init Firebase in the background isolate. Cheap when already initialized.
  await Firebase.initializeApp();
}

/// Singleton wrapper around `FirebaseMessaging` + `flutter_local_notifications`.
///
/// Responsibilities:
/// - Request notification permission (iOS prompts; Android 13+ runtime prompt).
/// - Fetch / refresh the FCM device token and expose it via [tokenStream].
/// - Listen for foreground messages and surface them as a heads-up local
///   notification (FCM does NOT show banners in foreground by default on
///   Android; iOS requires `presentAlert: true`).
/// - Convert incoming `RemoteMessage`s to [NotificationModel] and emit them on
///   [incomingNotifications] so `AppProvider` can prepend them to the list.
/// - When the user taps a notification (foreground tap, background tap, or
///   cold-start tap), emit the `actionRoute` on [notificationTaps] so the
///   router can navigate.
///
/// Usage:
/// ```dart
/// // In main.dart, before runApp:
/// await Firebase.initializeApp();
/// FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
/// await FcmService.instance.init();
///
/// // Inside the widget tree, subscribe once:
/// FcmService.instance.incomingNotifications.listen(provider.addIncomingNotification);
/// FcmService.instance.notificationTaps.listen(appRouter.go);
/// ```
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _localNotifications = FlutterLocalNotificationsPlugin();

  final _incomingController = StreamController<NotificationModel>.broadcast();
  final _tapController = StreamController<String>.broadcast();
  final _tokenController = StreamController<String>.broadcast();

  /// Notifications that arrived while the app is open. Subscribe once from a
  /// stateful widget mounted inside the provider tree and forward to
  /// `AppProvider.addIncomingNotification`.
  Stream<NotificationModel> get incomingNotifications =>
      _incomingController.stream;

  /// Routes to navigate to after the user taps a notification (any app state).
  Stream<String> get notificationTaps => _tapController.stream;

  /// Fires whenever FCM rotates the device token (re-register with the
  /// backend). The first token after [init] is also emitted here.
  Stream<String> get tokenStream => _tokenController.stream;

  bool _initialized = false;

  /// Default Android notification channel. Must match the value declared in
  /// AndroidManifest.xml (`com.google.firebase.messaging.default_notification_channel_id`)
  /// so notifications received while the app is in the background land in the
  /// same channel as foreground ones.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'uruk_default_channel',
    'Uruk Notifications',
    description: 'General notifications from Uruk Motors',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // ── 1. Permission ──────────────────────────────────────────────────────
    // iOS: shows the system prompt the first time. Android 13+: triggers the
    // POST_NOTIFICATIONS runtime prompt. Older Android: no-op (granted at
    // install time).
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS: surface banners while the app is in the foreground.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── 2. Local notifications (foreground display on Android) ─────────────
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      // We already request permission via FirebaseMessaging above. Don't
      // double-prompt here.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    // Create the default channel up-front so the system knows about it before
    // any background message lands.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // ── 3. Token ───────────────────────────────────────────────────────────
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) _tokenController.add(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(_tokenController.add);

    // ── 4. Message listeners ───────────────────────────────────────────────
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);

    // Cold-start: if the user tapped a notification while the app was
    // terminated, this returns the message that launched it.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      // Defer slightly so subscribers (router, providers) have time to attach.
      Future.delayed(const Duration(milliseconds: 250), () {
        _handleOpenedApp(initial);
      });
    }
  }

  /// Returns the current device token, or null if FCM hasn't issued one yet
  /// (e.g. iOS without APNs entitlement, Android without Play Services).
  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('FcmService.getToken failed: $e');
      return null;
    }
  }

  /// Tells FCM to forget the current token. Call on logout so the next login
  /// gets a fresh token (and the backend can revoke the old one).
  Future<void> deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('FcmService.deleteToken failed: $e');
    }
  }

  /// Platform string sent to the backend so it knows which FCM API to use
  /// for legacy/data-only payloads.
  String get platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  // ── Internals ──────────────────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    final notif = NotificationModel.fromFcmData(
      message.data,
      fallbackTitle: message.notification?.title,
      fallbackBody: message.notification?.body,
    );
    if (notif != null) _incomingController.add(notif);

    // Show a heads-up banner. iOS already shows one via
    // `setForegroundNotificationPresentationOptions`; we only need to do it
    // ourselves on Android (and, harmlessly, on iOS as well since FCM
    // de-duplicates).
    final n = message.notification;
    if (n != null) {
      _localNotifications.show(
        message.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        // Encode the action route so `_onLocalTap` can extract it when the
        // user taps the foreground heads-up banner.
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleOpenedApp(RemoteMessage message) {
    final route = message.data['actionRoute'] as String?;
    if (route != null && route.isNotEmpty) _tapController.add(route);
  }

  void _onLocalTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final route = data['actionRoute'] as String?;
      if (route != null && route.isNotEmpty) _tapController.add(route);
    } catch (_) {
      // ignore malformed payloads
    }
  }
}
