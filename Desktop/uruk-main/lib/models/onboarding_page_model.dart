/// A single onboarding slide. Either uses a custom [imageUrl] uploaded by the
/// admin, or falls back to a built-in icon when [imageUrl] is null/empty.
class OnboardingPageData {
  final String title;
  final String desc;
  final String? imageUrl;

  const OnboardingPageData({
    required this.title,
    required this.desc,
    this.imageUrl,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory OnboardingPageData.fromJson(Map<String, dynamic> json) =>
      OnboardingPageData(
        title: (json['title'] ?? '').toString(),
        desc: (json['desc'] ?? json['description'] ?? '').toString(),
        imageUrl: _emptyToNull(json['imageUrl']?.toString()),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'desc': desc,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  static String? _emptyToNull(String? s) =>
      (s == null || s.isEmpty) ? null : s;
}
