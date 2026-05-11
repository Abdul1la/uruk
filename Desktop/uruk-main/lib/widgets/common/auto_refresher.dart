import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';

/// Wraps the whole authenticated app. While a user is logged in, silently
/// polls the backend for state the admin panel can change behind the user's
/// back — primarily the user's car subscription (approved/activated) and the
/// list of upgrade requests (approved/rejected).
///
/// Every screen that watches [AuthProvider] or [AppProvider] picks up these
/// updates automatically via notifyListeners(), so the UI flips from
/// "قيد المراجعة" to "نشطة" without requiring the user to refresh, re-enter
/// a screen, or restart the app.
class AutoRefresher extends StatefulWidget {
  final Widget child;
  const AutoRefresher({super.key, required this.child});

  @override
  State<AutoRefresher> createState() => _AutoRefresherState();
}

class _AutoRefresherState extends State<AutoRefresher>
    with WidgetsBindingObserver {
  Timer? _timer;

  // Short enough that admin approval feels near-instant; long enough that
  // we're not hammering the backend for every single user every few seconds.
  static const _pollInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user returns to the app after the admin approved their
    // request, fetch fresh data right away instead of waiting up to 20s
    // for the next tick.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return; // Not logged in — skip the tick.
    // Errors here are expected on flaky networks; we just skip the tick.
    try {
      await Future.wait([
        auth.refreshUser(),
        context.read<AppProvider>().loadUpgradeRequests(user.id),
      ]);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
