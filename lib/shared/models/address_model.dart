class AddressModel {
  final String id;
  final String label; // Home, Work, Other
  final String fullAddress;
  final String? landmark;
  final double latitude;
  final double longitude;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.landmark,
    required this.latitude,
    required this.longitude,
  });

  // From JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['fullAddress'] as String,
      landmark: json['landmark'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Copy With
  AddressModel copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? landmark,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() => 'AddressModel(id: $id, label: $label, fullAddress: $fullAddress)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
