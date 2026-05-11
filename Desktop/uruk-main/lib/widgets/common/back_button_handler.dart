import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Wraps a child widget with back-button handling.
///
/// On hardware/system back press:
/// 1. If the navigator can pop, it pops (normal back).
/// 2. If [fallbackRoute] is given, it navigates there.
/// 3. Otherwise it minimises the app (like pressing the home button).
class BackButtonHandler extends StatelessWidget {
  final Widget child;

  /// Optional route to navigate to when the back stack is empty.
  /// When null, the app minimises instead.
  final String? fallbackRoute;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else if (fallbackRoute != null) {
          context.go(fallbackRoute!);
        } else {
          // Minimise app — avoids hard exit
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
