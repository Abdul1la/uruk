import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';

class UrukLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool showTagline;

  const UrukLogo({
    super.key,
    this.fontSize = 36,
    this.color,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'URUK',
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: logoColor,
            letterSpacing: 6,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            context.l10n.appTagline,
            style: GoogleFonts.poppins(
              fontSize: fontSize * 0.28,
              fontWeight: FontWeight.w500,
              color: logoColor.withValues(alpha: 0.7),
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}

/// Horizontal logo variant (for app bar etc.)
class UrukLogoHorizontal extends StatelessWidget {
  final double size;
  final Color? color;

  const UrukLogoHorizontal({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppColors.textOnPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 1.2,
          height: size * 0.8,
          decoration: BoxDecoration(
            color: logoColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.directions_car, color: logoColor, size: size * 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          'URUK',
          style: GoogleFonts.poppins(
            fontSize: size * 0.7,
            fontWeight: FontWeight.w700,
            color: logoColor,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}
