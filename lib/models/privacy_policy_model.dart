/// Privacy policy text edited by admin and shown to users on the login screen.
class PrivacyPolicy {
  /// The full policy text. Newlines are preserved.
  final String content;

  /// Date the admin last updated the policy (ISO yyyy-MM-dd or display string).
  final String updatedAt;

  const PrivacyPolicy({
    required this.content,
    required this.updatedAt,
  });
}
