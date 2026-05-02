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
      child: MaterialApp.router(
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
      ),
    );
  }
}
