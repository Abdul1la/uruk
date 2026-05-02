/// A service center / branch managed by the admin panel.
class BranchModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? address;
  final String? phone;
  final bool isActive;

  const BranchModel({
    this.id = '',
    required this.name,
    required this.lat,
    required this.lng,
    this.address,
    this.phone,
    this.isActive = true,
  });

  /// Create a BranchModel from a JSON map (backend payload).
  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
        address: json['address']?.toString(),
        phone: json['phone']?.toString(),
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'address': address,
        'phone': phone,
        'isActive': isActive,
      };
}
