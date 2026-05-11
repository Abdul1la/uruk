import 'package:flutter/material.dart';

enum AdBannerMediaType { none, image, video }

class AdBanner {
  final String id;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String? actionLabel;
  final String? actionRoute;
  /// Optional uploaded image/video URL. When set, it replaces the icon+color
  /// layout — text is overlaid on top of the media.
  final String? mediaUrl;
  final AdBannerMediaType mediaType;
  final bool isActive;

  const AdBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.textColor = Colors.white,
    required this.icon,
    this.actionLabel,
    this.actionRoute,
    this.mediaUrl,
    this.mediaType = AdBannerMediaType.none,
    this.isActive = true,
  });

  bool get hasMedia =>
      mediaUrl != null && mediaUrl!.isNotEmpty && mediaType != AdBannerMediaType.none;

  /// Parse a payload coming from the dashboard / backend.
  /// Dashboard stores: bgColor as hex string ("#1A3A8F"), icon as Lucide name.
  factory AdBanner.fromJson(Map<String, dynamic> json) => AdBanner(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        subtitle: (json['subtitle'] ?? '').toString(),
        backgroundColor: _parseHexColor(json['bgColor'] ?? json['backgroundColor']),
        textColor: _parseHexColor(json['textColor'], fallback: Colors.white),
        icon: _iconFromName((json['icon'] ?? '').toString()),
        actionLabel: json['actionLabel']?.toString(),
        actionRoute: json['actionRoute']?.toString(),
        mediaUrl: (json['mediaUrl']?.toString().isEmpty ?? true) ? null : json['mediaUrl']?.toString(),
        mediaType: _parseMediaType(json['mediaType']?.toString()),
        isActive: json['isActive'] as bool? ?? true,
      );

  static AdBannerMediaType _parseMediaType(String? raw) {
    switch (raw) {
      case 'image':
        return AdBannerMediaType.image;
      case 'video':
        return AdBannerMediaType.video;
      default:
        return AdBannerMediaType.none;
    }
  }

  /// Convert "#1A3A8F" → Color. Accepts "1A3A8F", "#1A3A8F", "0xFF1A3A8F".
  static Color _parseHexColor(dynamic raw, {Color fallback = const Color(0xFF1A3A8F)}) {
    if (raw == null) return fallback;
    var hex = raw.toString().trim().replaceAll('#', '').replaceAll('0x', '');
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16);
    return value == null ? fallback : Color(value);
  }

  /// Map Lucide-style icon names (used in the dashboard) to Material IconData.
  static IconData _iconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'tag':
      case 'local_offer':
        return Icons.local_offer_outlined;
      case 'wrench':
      case 'build':
        return Icons.build_circle_outlined;
      case 'star':
        return Icons.star_outline;
      case 'car':
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'credit-card':
      case 'credit_card':
        return Icons.credit_card_outlined;
      case 'calendar':
        return Icons.calendar_today_outlined;
      case 'siren':
      case 'bell':
        return Icons.notifications_outlined;
      case 'clipboard-list':
      case 'list':
        return Icons.list_alt_outlined;
      case 'shield':
        return Icons.shield_outlined;
      case 'info':
        return Icons.info_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }
}
