class SupportInfo {
  final String phone;
  final String email;
  final String? whatsapp;
  final String? address;
  final String? workingHours;
  final String? instagram;
  final String? facebook;
  final String? telegram;
  final String? website;

  const SupportInfo({
    required this.phone,
    required this.email,
    this.whatsapp,
    this.address,
    this.workingHours,
    this.instagram,
    this.facebook,
    this.telegram,
    this.website,
  });
}
