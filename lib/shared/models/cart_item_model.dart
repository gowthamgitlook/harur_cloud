import '../enums/spice_level.dart';
import 'addon_model.dart';
import 'menu_item_model.dart';

class CartItemModel {
  final String id;
  final MenuItemModel menuItem;
  final int quantity;
  final List<AddonModel> selectedAddons;
  final SpiceLevel spiceLevel;
  final String? specialInstructions;

  CartItemModel({
    required this.id,
    required this.menuItem,
    this.quantity = 1,
    this.selectedAddons = const [],
    this.spiceLevel = SpiceLevel.medium,
    this.specialInstructions,
  });

  // Calculate total price including addons
  double get totalPrice {
    double basePrice = menuItem.price * quantity;
    double addonsPrice = selectedAddons.fold(
      0.0,
      (sum, addon) => sum + addon.price,
    ) * quantity;
    return basePrice + addonsPrice;
  }

  // From JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      menuItem: MenuItemModel.fromJson(json['menuItem'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedAddons: (json['selectedAddons'] as List<dynamic>?)
              ?.map((addon) => AddonModel.fromJson(addon as Map<String, dynamic>))
              .toList() ??
          [],
      spiceLevel: SpiceLevel.fromString(json['spiceLevel'] as String? ?? 'medium'),
      specialInstructions: json['specialInstructions'] as String?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
      'selectedAddons': selectedAddons.map((addon) => addon.toJson()).toList(),
      'spiceLevel': spiceLevel.name,
      'specialInstructions': specialInstructions,
    };
  }

  // Copy With
  CartItemModel copyWith({
    String? id,
    MenuItemModel? menuItem,
    int? quantity,
    List<AddonModel>? selectedAddons,
    SpiceLevel? spiceLevel,
    String? specialInstructions,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  String toString() => 'CartItemModel(id: $id, item: ${menuItem.name}, qty: $quantity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
