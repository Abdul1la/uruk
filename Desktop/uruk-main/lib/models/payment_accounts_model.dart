/// Dynamic payment account numbers shown to users in the payment screen.
/// Managed by finance/admin from the dashboard.
///
/// Each account can be displayed as either:
///   - a plain account number (zainCash / superQi), OR
///   - a QR-code image (zainCashQrUrl / superQiQrUrl).
/// If both are set for the same method, the QR image takes precedence — the
/// admin controls which one the customer sees by filling one field and
/// leaving the other empty.
class PaymentAccounts {
  final String zainCash;
  final String superQi;
  final String? zainCashQrUrl;
  final String? superQiQrUrl;

  const PaymentAccounts({
    required this.zainCash,
    required this.superQi,
    this.zainCashQrUrl,
    this.superQiQrUrl,
  });

  /// True when the admin has uploaded a QR code for ZainCash.
  bool get hasZainCashQr => zainCashQrUrl != null && zainCashQrUrl!.isNotEmpty;

  /// True when the admin has uploaded a QR code for Super QI.
  bool get hasSuperQiQr => superQiQrUrl != null && superQiQrUrl!.isNotEmpty;

  factory PaymentAccounts.fromJson(Map<String, dynamic> json) => PaymentAccounts(
        zainCash: (json['zainCash'] ?? '').toString(),
        superQi: (json['superQi'] ?? '').toString(),
        zainCashQrUrl: _emptyToNull(json['zainCashQrUrl']?.toString()),
        superQiQrUrl: _emptyToNull(json['superQiQrUrl']?.toString()),
      );

  Map<String, dynamic> toJson() => {
        'zainCash': zainCash,
        'superQi': superQi,
        if (zainCashQrUrl != null) 'zainCashQrUrl': zainCashQrUrl,
        if (superQiQrUrl != null) 'superQiQrUrl': superQiQrUrl,
      };

  static String? _emptyToNull(String? s) =>
      (s == null || s.isEmpty) ? null : s;
}
