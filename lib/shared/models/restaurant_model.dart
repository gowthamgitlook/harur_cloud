class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime; // e.g., "25-30 mins"
  final double priceForTwo;
  final String cuisine; // e.g., "Biryani, South Indian"
  final bool isVegetarian;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final String address;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.priceForTwo,
    required this.cuisine,
    this.isVegetarian = false,
    this.isOpen = true,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      deliveryTime: json['deliveryTime'] as String,
      priceForTwo: (json['priceForTwo'] as num).toDouble(),
      cuisine: json['cuisine'] as String,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isOpen: json['isOpen'] as bool? ?? true,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryTime': deliveryTime,
      'priceForTwo': priceForTwo,
      'cuisine': cuisine,
      'isVegetarian': isVegetarian,
      'isOpen': isOpen,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
