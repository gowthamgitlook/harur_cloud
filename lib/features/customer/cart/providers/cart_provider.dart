import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/enums/spice_level.dart';
import '../../../../shared/models/addon_model.dart';
import '../../../../shared/models/cart_item_model.dart';
import '../../../../shared/models/menu_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  String? _promoCode;
  double _promoDiscount = 0.0;

  // Getters
  List<CartItemModel> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;
  String? get promoCode => _promoCode;

  // Price calculations
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee {
    if (subtotal == 0) return 0.0;
    if (subtotal < AppConfig.minimumOrderAmount) return 0.0;
    if (_promoCode == 'FREESHIP') return 0.0;
    return AppConfig.deliveryFeeFlat;
  }

  double get tax {
    return subtotal * (AppConfig.taxPercentage / 100);
  }

  double get discount {
    return _promoDiscount;
  }

  double get total {
    return subtotal + deliveryFee + tax - discount;
  }

  bool get meetsMinimumOrder {
    return subtotal >= AppConfig.minimumOrderAmount;
  }

  double get amountNeededForMinimum {
    if (meetsMinimumOrder) return 0.0;
    return AppConfig.minimumOrderAmount - subtotal;
  }

  // Add item to cart
  void addItem({
    required MenuItemModel menuItem,
    List<AddonModel> selectedAddons = const [],
    SpiceLevel spiceLevel = SpiceLevel.medium,
    String? specialInstructions,
  }) {
    // Check if exact same item already exists
    final existingIndex = _items.indexWhere((item) =>
        item.menuItem.id == menuItem.id &&
        _areAddonsEqual(item.selectedAddons, selectedAddons) &&
        item.spiceLevel == spiceLevel);

    if (existingIndex != -1) {
      // Increase quantity
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      // Add new item
      final cartItem = CartItemModel(
        id: const Uuid().v4(),
        menuItem: menuItem,
        quantity: 1,
        selectedAddons: selectedAddons,
        spiceLevel: spiceLevel,
        specialInstructions: specialInstructions,
      );
      _items.add(cartItem);
    }

    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  // Increase quantity
  void increaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
      notifyListeners();
    }
  }

  // Decrease quantity
  void decreaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index] = _items[index].copyWith(
          quantity: _items[index].quantity - 1,
        );
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Remove item
  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _promoCode = null;
    _promoDiscount = 0.0;
    notifyListeners();
  }

  // Apply promo code
  bool applyPromoCode(String code) {
    final upperCode = code.toUpperCase();

    switch (upperCode) {
      case 'FIRST50':
        // 50% off, max ₹100
        if (subtotal >= 150) {
          // Minimum order for this promo
          final discountAmount = subtotal * 0.5;
          _promoDiscount = discountAmount > 100 ? 100 : discountAmount;
          _promoCode = upperCode;
          notifyListeners();
          return true;
        }
        return false;

      case 'BIRYANI20':
        // ₹20 off on Biryani items
        final hasBiryani = _items.any((item) =>
            item.menuItem.category.displayName.toLowerCase().contains('biryani'));
        if (hasBiryani) {
          _promoDiscount = 20;
          _promoCode = upperCode;
          notifyListeners();
          return true;
        }
        return false;

      case 'FREESHIP':
        // Free delivery
        _promoCode = upperCode;
        _promoDiscount = 0;
        notifyListeners();
        return true;

      default:
        return false;
    }
  }

  // Remove promo code
  void removePromoCode() {
    _promoCode = null;
    _promoDiscount = 0.0;
    notifyListeners();
  }

  // Get cart item count for a specific menu item
  int getItemQuantityInCart(String menuItemId) {
    return _items
        .where((item) => item.menuItem.id == menuItemId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // Helper: Check if two addon lists are equal
  bool _areAddonsEqual(List<AddonModel> list1, List<AddonModel> list2) {
    if (list1.length != list2.length) return false;

    final ids1 = list1.map((a) => a.id).toSet();
    final ids2 = list2.map((a) => a.id).toSet();

    return ids1.containsAll(ids2) && ids2.containsAll(ids1);
  }
}
