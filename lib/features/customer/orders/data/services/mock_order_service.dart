import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/models/cart_item_model.dart';
import '../../../../../shared/models/address_model.dart';
import '../../../../../shared/models/user_model.dart';
import '../../../../../shared/enums/order_status.dart';
import '../../../../../shared/enums/payment_method.dart';
import '../../../../../shared/enums/spice_level.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../data/mock/mock_menu_data.dart';

class MockOrderService {
  static final MockOrderService _instance = MockOrderService._internal();
  factory MockOrderService() => _instance;
  
  MockOrderService._internal() {
    _initializeSampleOrders();
  }

  final List<OrderModel> _orders = [];
  final _orderStreamController = StreamController<List<OrderModel>>.broadcast();

  Stream<List<OrderModel>> get ordersStream => _orderStreamController.stream;

  MenuItemModel _safeGetMenuItem(int index) {
    final items = MockMenuData.menuItems;
    if (items.isEmpty) {
      return MenuItemModel(
        id: 'error_fallback',
        restaurantId: 'res_1',
        restaurantName: 'Harur Kitchen',
        name: 'Item Unavailable',
        description: 'Temporary placeholder',
        price: 0,
        imageUrl: '',
        category: FoodCategory.biryani,
      );
    }
    return items[index % items.length];
  }

  void _initializeSampleOrders() {
    final now = DateTime.now();
    if (MockMenuData.restaurants.isEmpty) return;

    try {
      final sampleAddress = AddressModel(
        id: 'addr1',
        label: 'Home',
        fullAddress: 'Harur, TN',
        latitude: 12.0540,
        longitude: 78.4822,
      );

      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 1000}',
        userId: '1',
        items: [
          CartItemModel(
            id: 'cart_item_1',
            menuItem: _safeGetMenuItem(0),
            quantity: 2,
            selectedAddons: [],
            spiceLevel: SpiceLevel.medium,
          ),
        ],
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
    } catch (e) {
      debugPrint('MockOrderService Error: $e');
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _orders.where((o) => o.userId == userId).toList();
  }

  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required double subtotal,
    required double deliveryFee,
    required double tax,
    required double discount,
    required double totalPrice,
    required PaymentMethod paymentMethod,
    required AddressModel deliveryAddress,
    String? promoCode,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final order = OrderModel(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
      discount: discount,
      totalPrice: totalPrice,
      status: OrderStatus.placed,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _orders.insert(0, order);
    _orderStreamController.add(List.from(_orders));
    return order;
  }

  Future<bool> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled, updatedAt: DateTime.now());
      _orderStreamController.add(List.from(_orders));
      return true;
    }
    return false;
  }

  Future<OrderModel> reorder(OrderModel previousOrder) async {
    return await createOrder(
      userId: previousOrder.userId,
      items: previousOrder.items,
      subtotal: previousOrder.subtotal,
      deliveryFee: previousOrder.deliveryFee,
      tax: previousOrder.tax,
      discount: previousOrder.discount,
      totalPrice: previousOrder.totalPrice,
      paymentMethod: previousOrder.paymentMethod,
      deliveryAddress: previousOrder.deliveryAddress,
    );
  }

  Map<String, dynamic> getDashboardStats() => {
    'totalOrders': _orders.length,
    'pendingOrders': _orders.where((o) => o.status == OrderStatus.placed).length,
    'revenue': _orders.fold(0.0, (sum, o) => sum + o.totalPrice),
  };

  Future<List<OrderModel>> getAllOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_orders);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status, updatedAt: DateTime.now());
      _orderStreamController.add(List.from(_orders));
    }
  }

  Future<void> assignDeliveryPartner({
    required String orderId,
    required String partnerId,
    String? partnerName,
    String? partnerPhone,
  }) async {
    await updateOrderStatus(orderId, OrderStatus.outForDelivery);
  }

  List<OrderModel> getOrdersByStatus(OrderStatus status) => _orders.where((o) => o.status == status).toList();

  Future<List<OrderModel>> getAssignedDeliveries(String partnerId) async => _orders.where((o) => o.status == OrderStatus.outForDelivery).toList();

  Future<List<OrderModel>> getActiveDeliveries(String partnerId) async => _orders.where((o) => o.status == OrderStatus.outForDelivery).toList();

  Future<List<OrderModel>> getDeliveryHistory(String partnerId) async => _orders.where((o) => o.status == OrderStatus.delivered).toList();

  Future<bool> markDeliveryComplete(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.delivered);
    return true;
  }

  Map<String, dynamic> getDeliveryPartnerStats(String partnerId) => {'completed': 5, 'earnings': 150.0};

  Future<Map<String, double>> getDeliveryPartnerLocation(String orderId) async => {'latitude': 12.0540, 'longitude': 78.4822};

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  Map<OrderStatus, int> getOrderStats(String userId) {
    final stats = <OrderStatus, int>{};
    for (var status in OrderStatus.values) {
      stats[status] = _orders.where((o) => o.userId == userId && o.status == status).length;
    }
    return stats;
  }
}
