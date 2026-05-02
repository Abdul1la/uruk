import 'dart:convert';

class DraftReport {
  final String id;
  final String location;
  final double? latitude;
  final double? longitude;
  final String description;
  final DateTime accidentDate;
  final bool otherPartyInvolved;
  final List<String> photoPaths; // local file paths from image_picker
  final DateTime savedAt;

  const DraftReport({
    required this.id,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.accidentDate,
    required this.otherPartyInvolved,
    required this.photoPaths,
    required this.savedAt,
  });

  DraftReport copyWith({
    String? location,
    double? latitude,
    double? longitude,
    String? description,
    DateTime? accidentDate,
    bool? otherPartyInvolved,
    List<String>? photoPaths,
    DateTime? savedAt,
  }) {
    return DraftReport(
      id: id,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      accidentDate: accidentDate ?? this.accidentDate,
      otherPartyInvolved: otherPartyInvolved ?? this.otherPartyInvolved,
      photoPaths: photoPaths ?? this.photoPaths,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'accidentDate': accidentDate.toIso8601String(),
        'otherPartyInvolved': otherPartyInvolved,
        'photoPaths': photoPaths,
        'savedAt': savedAt.toIso8601String(),
      };

  factory DraftReport.fromJson(Map<String, dynamic> json) => DraftReport(
        id: json['id'] as String,
        location: json['location'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        description: json['description'] as String? ?? '',
        accidentDate: DateTime.parse(json['accidentDate'] as String),
        otherPartyInvolved: json['otherPartyInvolved'] as bool? ?? false,
        photoPaths: List<String>.from(json['photoPaths'] as List? ?? []),
        savedAt: DateTime.parse(json['savedAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());
  factory DraftReport.fromJsonString(String s) => DraftReport.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
