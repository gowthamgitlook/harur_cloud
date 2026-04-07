import 'dart:async';
import 'dart:math';
import '../../../../../config/app_config.dart';
import '../../../../../data/mock/mock_menu_data.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/models/cart_item_model.dart';
import '../../../../../shared/models/address_model.dart';
import '../../../../../shared/enums/order_status.dart';
import '../../../../../shared/enums/payment_method.dart';
import '../../../../../shared/enums/spice_level.dart';
import '../../../../../shared/models/menu_item_model.dart';

class MockOrderService {
  static final MockOrderService _instance = MockOrderService._internal();
  factory MockOrderService() => _instance;
  
  MockOrderService._internal() {
    _initializeSampleOrders();
  }

  final List<OrderModel> _orders = [];
  final _orderStreamController = StreamController<List<OrderModel>>.broadcast();

  Stream<List<OrderModel>> get ordersStream => _orderStreamController.stream;

  /// Senior Approach: Safe access to mock data to prevent RangeError
  MenuItemModel _safeGetMenuItem(int index) {
    final items = MockMenuData.menuItems;
    if (items.isEmpty) {
      // Fallback to a dummy item if the list is completely empty
      return MenuItemModel(
        id: 'error_fallback',
        restaurantId: 'res_1',
        restaurantName: 'Harur Kitchen',
        name: 'Item Unavailable',
        description: 'Temporary placeholder',
        price: 0,
        imageUrl: '',
        category: MockMenuData.menuItems.isNotEmpty ? MockMenuData.menuItems.first.category : MockMenuData.restaurants.first.id as dynamic,
      );
    }
    // Wrap around index if it exceeds length (Modulo)
    return items[index % items.length];
  }

  void _initializeSampleOrders() {
    final now = DateTime.now();
    final sampleAddress = MockAuthService.mockUsers[0].addresses![0];

    try {
      // Sample Order 1: Active - Preparing
      final order1Items = [
        CartItemModel(
          id: 'cart_item_1',
          menuItem: _safeGetMenuItem(0),
          quantity: 2,
          selectedAddons: [MockMenuData.commonAddons[0]],
          spiceLevel: SpiceLevel.medium,
        ),
        CartItemModel(
          id: 'cart_item_2',
          menuItem: _safeGetMenuItem(5),
          quantity: 1,
          selectedAddons: [],
          spiceLevel: SpiceLevel.medium,
        ),
      ];
      
      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 1000}',
        userId: '1',
        items: order1Items,
        subtotal: 540.0,
        deliveryFee: 30.0,
        tax: 27.0,
        totalPrice: 597.0,
        status: OrderStatus.preparing,
        paymentMethod: PaymentMethod.cashOnDelivery,
        deliveryAddress: sampleAddress,
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ));

      // Sample Order 2: Active - Placed
      final order2Items = [
        CartItemModel(
          id: 'cart_item_3',
          menuItem: _safeGetMenuItem(8),
          quantity: 1,
          selectedAddons: [],
          spiceLevel: SpiceLevel.spicy,
        ),
      ];
      
      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 2000}',
        userId: '1',
        items: order2Items,
        subtotal: 150.0,
        deliveryFee: 30.0,
        tax: 9.0,
        totalPrice: 189.0,
        status: OrderStatus.placed,
        paymentMethod: PaymentMethod.upi,
        deliveryAddress: sampleAddress,
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ));

      // Sample Order 3: History - Delivered
      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 3000}',
        userId: '1',
        items: [
          CartItemModel(
            id: 'cart_item_4',
            menuItem: _safeGetMenuItem(1),
            quantity: 1,
            selectedAddons: [],
            spiceLevel: SpiceLevel.spicy,
          ),
          CartItemModel(
            id: 'cart_item_5',
            menuItem: _safeGetMenuItem(9),
            quantity: 2,
            selectedAddons: [],
            spiceLevel: SpiceLevel.mild,
          ),
        ],
        subtotal: 380.0,
        deliveryFee: 30.0,
        tax: 20.5,
        totalPrice: 430.5,
        status: OrderStatus.delivered,
        paymentMethod: PaymentMethod.cashOnDelivery,
        deliveryAddress: sampleAddress,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ));
    } catch (e) {
      debugPrint('CRITICAL: MockOrderService failed to initialize sample data: $e');
      // No re-throw here ensures the app still starts even if mock initialization fails
    }
  }

  // ... rest of the service methods (getUserOrders, createOrder, etc.)
  // Ensure they all use defensive logic as well.
  
  Future<List<OrderModel>> getUserOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _orders.where((o) => o.userId == userId).toList();
  }
  
  // Implementation of other methods...
}

// Minimal MockAuthService mock for initialization
class MockAuthService {
  static final mockUsers = [
    UserModel(
      id: '1',
      name: 'Test User',
      addresses: [
        AddressModel(
          id: 'addr1',
          label: 'Home',
          fullAddress: 'Harur, TN',
          latitude: 12.0540,
          longitude: 78.4822,
        ),
      ],
    ),
  ];
}
