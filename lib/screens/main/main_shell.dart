import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(String location) {
    if (location.startsWith('/accidents')) return 1;
    if (location.startsWith('/appointments')) return 2;
    if (location.startsWith('/my-cars')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isHome = location.startsWith('/home');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isHome) {
          // On home tab with empty stack: minimize the app (don't exit)
          SystemNavigator.pop();
        } else {
          // On other tabs with empty stack: push home so the stack builds up.
          context.push('/home');
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: UrukBottomNavBar(currentIndex: _currentIndex(location)),
      ),
    );
  }
}
