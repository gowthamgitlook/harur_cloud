class AddonModel {
  final String id;
  final String name;
  final double price;

  AddonModel({
    required this.id,
    required this.name,
    required this.price,
  });

  // From JSON
  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  // Copy With
  AddonModel copyWith({
    String? id,
    String? name,
    double? price,
  }) {
    return AddonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  @override
  String toString() => 'AddonModel(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddonModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
