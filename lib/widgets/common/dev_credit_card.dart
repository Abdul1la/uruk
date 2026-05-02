import 'package:flutter/material.dart';

/// Dark navy "developed by" card shown at the bottom of the profile / support
/// screens. Matches the design provided by the client: logo in the center and
/// dev contact phone below.
class DevCreditCard extends StatelessWidget {
  const DevCreditCard({super.key});

  @override
  Widget build(BuildContext context) {
    const darkNavy = Color(0xFF0E1A33);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'تم تطوير هذا التطبيق بواسطة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFCCD3E4),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          // Dev logo (white-on-dark asset)
          Image.asset(
            'images/dev_logo.png',
            height: 56,
            fit: BoxFit.contain,
            // If the asset can't be loaded for any reason, fall back to a
            // neutral placeholder rather than crashing.
            errorBuilder: (_, __, ___) => const SizedBox(height: 56),
          ),
          const SizedBox(height: 14),
          const SelectableText(
            '07511130503',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
