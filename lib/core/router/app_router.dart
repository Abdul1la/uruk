import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../screens/accident/accident_detail_screen.dart';
import '../../screens/car/add_car_screen.dart';
import '../../screens/accident/accident_history_screen.dart';
import '../../screens/accident/report_accident_screen.dart';
import '../../models/draft_report_model.dart';
import '../../screens/appointments/appointments_screen.dart';
import '../../screens/auth/id_upload_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/auth/pending_approval_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/garage/garage_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/main/main_shell.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/privacy/privacy_policy_screen.dart';
import '../../screens/my_cars/car_detail_screen.dart';
import '../../screens/my_cars/my_cars_screen.dart';
import '../../screens/payment/payment_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/services/oil_change_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/subscription/plans_screen.dart';
import '../../screens/support/support_screen.dart';

/// Paths that don't require the user to be logged in.
const _publicRoutes = {
  '/splash',
  '/onboarding',
  '/privacy',
  '/login',
  '/register',
  '/otp',
};

/// Paths a NOT-yet-approved user is still allowed to see (finish signup flow).
const _pendingAllowed = {
  '/id-upload',
  '/pending',
};

final appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final path = state.uri.path;
    // Let splash do its own async auth restore on cold start.
    if (path == '/splash') return null;
    // Allow any public route without a token.
    if (_publicRoutes.contains(path)) return null;
    // No token at all → kick to login. (ApiService keeps the token in memory
    // after loadToken() is called once; the splash screen calls it first.)
    if (!ApiService().hasToken) return '/login';
    // Otherwise allow — per-screen checks (pending/suspended/rejected) are
    // handled by MainShell and individual screens that read AuthProvider.
    if (_pendingAllowed.contains(path)) return null;
    return null;
  },
  routes: [
    // Splash
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

    // Onboarding
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

    // Privacy Policy (accessible from login)
    GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),

    // Auth
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, state) => OtpScreen(extra: state.extra as Map<String, dynamic>?),
    ),
    GoRoute(path: '/id-upload', builder: (_, __) => const IdUploadScreen()),
    GoRoute(path: '/pending', builder: (_, __) => const PendingApprovalScreen()),

    // Garage — standalone entry point after login (no bottom nav)
    GoRoute(path: '/garage', builder: (_, __) => const GarageScreen()),

    // Subscription (standalone — no bottom nav)
    GoRoute(path: '/subscription', builder: (_, __) => const PlansScreen()),

    // Add / Edit car
    GoRoute(path: '/add-car', builder: (_, __) => const AddCarScreen()),
    GoRoute(path: '/add-car/new', builder: (_, __) => const AddCarScreen(isNewCar: true)),
    GoRoute(path: '/add-car/post-subscription', builder: (_, __) => const AddCarScreen(isPostSubscription: true)),

    // Oil change booking (standalone)
    GoRoute(path: '/oil-change', builder: (_, __) => const OilChangeScreen()),

    // Car detail (standalone — accessed from My Cars)
    GoRoute(
      path: '/car/:carId',
      builder: (_, state) => CarDetailScreen(carId: state.pathParameters['carId']!),
    ),

    // Payment (standalone — accessed from My Cars). Optional ?carId scopes to one car.
    GoRoute(
      path: '/payment',
      builder: (_, state) => PaymentScreen(carId: state.uri.queryParameters['carId']),
    ),

    // Support (standalone)
    GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),

    // Notifications (standalone)
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),

    // Accident report (standalone) — accepts optional DraftReport via extra
    GoRoute(
      path: '/accidents/report',
      builder: (_, state) => ReportAccidentScreen(
        draft: state.extra is DraftReport ? state.extra as DraftReport : null,
      ),
    ),

    // Accident detail (standalone)
    GoRoute(
      path: '/accidents/:id',
      builder: (_, state) => AccidentDetailScreen(reportId: state.pathParameters['id']!),
    ),

    // Main shell with bottom nav (car-specific context)
    ShellRoute(
      builder: (_, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/accidents', builder: (_, __) => const AccidentHistoryScreen()),
        GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsScreen()),
        GoRoute(path: '/my-cars', builder: (_, __) => const MyCarsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
