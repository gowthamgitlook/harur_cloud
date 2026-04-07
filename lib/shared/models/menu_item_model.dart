import '../enums/food_category.dart';
import 'addon_model.dart';

class MenuItemModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final FoodCategory category;
  final List<AddonModel> addons;
  final bool isAvailable;
  final bool isPopular;
  final bool isVeg; // Added for dietary preference
  final double? rating;
  final int? reviewCount;

  MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.addons = const [],
    this.isAvailable = true,
    this.isPopular = false,
    this.isVeg = false,
    this.rating,
    this.reviewCount,
  });

  // From JSON
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String? ?? 'res_1',
      restaurantName: json['restaurantName'] as String? ?? 'Harur Cloud Kitchen',
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: FoodCategory.fromString(json['category'] as String),
      addons: (json['addons'] as List<dynamic>?)
              ?.map((addon) => AddonModel.fromJson(addon as Map<String, dynamic>))
              .toList() ??
          [],
      isAvailable: json['isAvailable'] as bool? ?? true,
      isPopular: json['isPopular'] as bool? ?? false,
      isVeg: json['isVeg'] as bool? ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] as int?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category.name,
      'addons': addons.map((addon) => addon.toJson()).toList(),
      'isAvailable': isAvailable,
      'isPopular': isPopular,
      'isVeg': isVeg,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  // Copy With
  MenuItemModel copyWith({
    String? id,
    String? restaurantId,
    String? restaurantName,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    FoodCategory? category,
    List<AddonModel>? addons,
    bool? isAvailable,
    bool? isPopular,
    bool? isVeg,
    double? rating,
    int? reviewCount,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      addons: addons ?? this.addons,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      isVeg: isVeg ?? this.isVeg,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  String toString() => 'MenuItemModel(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
