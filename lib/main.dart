import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/draft_provider.dart';
import 'services/api_service.dart';
import 'services/fcm_service.dart';
import 'widgets/common/auto_refresher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean URLs on Flutter web (/login instead of /#/login). No-op on mobile.
  usePathUrlStrategy();
  // Eagerly load the saved JWT before runApp so the router's first auth
  // check sees the token. Without this, refreshing a deep link (e.g.
  // /home, /accidents/123) on Flutter web bounces the user to /login
  // because the redirect runs before SplashScreen has a chance to
  // restore the session asynchronously.
  await ApiService().loadToken();

  // Initialize Firebase + push notifications. Skipped on web for now (FCM
  // web needs an extra VAPID key in firebase_options.dart and a service
  // worker; ship that separately when the dashboard is ready). Failures
  // here must NOT prevent the app from starting — a phone without Play
  // Services or with FCM blocked should still open and work.
  //
  // We `await` Firebase.initializeApp() (cheap, ~50ms) but DO NOT await
  // FcmService.init(): it calls FirebaseMessaging.getToken(), which hangs
  // forever on the iOS simulator (no APNs token available there). Letting
  // it run unawaited means the UI surfaces immediately and FCM wires
  // itself up in the background once the token arrives — or never, on
  // simulator, which is fine.
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      unawaited(
        FcmService.instance.init().catchError(
          (e) => debugPrint('FcmService.init failed: $e'),
        ),
      );
    } catch (e) {
      debugPrint('Firebase init failed (continuing without push): $e');
    }
  }

  runApp(const UrukMotorsApp());
}

class UrukMotorsApp extends StatelessWidget {
  const UrukMotorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => DraftProvider()..loadDrafts()),
      ],
      // _FcmBridge wires FCM streams (incoming + tap) into the provider tree
      // and the router. It MUST live below MultiProvider so it can read
      // AppProvider.
      child: const _FcmBridge(
        child: _AppShell(),
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Uruk Motors',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (_, child) => AutoRefresher(child: child ?? const SizedBox()),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// Subscribes to [FcmService] streams once the provider tree is mounted and:
///   - prepends arriving push notifications to [AppProvider] so the bell
///     badge ([AppProvider.unreadCount]) ticks up live;
///   - navigates the router to `actionRoute` when the user taps a push
///     (foreground heads-up, background banner, or cold-start tap).
class _FcmBridge extends StatefulWidget {
  final Widget child;
  const _FcmBridge({required this.child});

  @override
  State<_FcmBridge> createState() => _FcmBridgeState();
}

class _FcmBridgeState extends State<_FcmBridge> {
  StreamSubscription? _incomingSub;
  StreamSubscription? _tapSub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return; // FCM disabled on web for now; nothing to wire up.

    _incomingSub = FcmService.instance.incomingNotifications.listen((n) {
      if (!mounted) return;
      context.read<AppProvider>().addIncomingNotification(n);
    });

    _tapSub = FcmService.instance.notificationTaps.listen((route) {
      if (!mounted) return;
      // Use go() rather than push(): action routes from notifications usually
      // point at top-level destinations (/notifications, /payment, /home),
      // and we want a single entry on the back stack — not a stack of
      // duplicates if the user taps several pushes.
      appRouter.go(route);
    });
  }

  @override
  void dispose() {
    _incomingSub?.cancel();
    _tapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
