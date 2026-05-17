import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/models/cart_item_model.dart';
import '../../../../../shared/models/address_model.dart';
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
        id: 'fallback',
        restaurantId: 'res_1',
        restaurantName: 'Harur Cloud Kitchen',
        name: 'Item Unavailable',
        description: 'Placeholder',
        price: 0,
        imageUrl: '',
        category: FoodCategory.biryani,
      );
    }
    return items[index % items.length];
  }

  void _initializeSampleOrders() {
    final now = DateTime.now();
    if (MockMenuData.menuItems.isEmpty) return;

    try {
      final homeAddress = AddressModel(
        id: 'addr1',
        label: 'Home',
        fullAddress: 'Main Street, Harur, Dharmapuri, Tamil Nadu 636903',
        landmark: 'Near Bus Stand',
        latitude: 12.0540,
        longitude: 78.4822,
      );

      // --- Today's Orders ---
      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 600000}',
        userId: '1',
        items: [
          CartItemModel(id: 'ci_1', menuItem: _safeGetMenuItem(0), quantity: 2, selectedAddons: [], spiceLevel: SpiceLevel.spicy),
          CartItemModel(id: 'ci_2', menuItem: _safeGetMenuItem(2), quantity: 1, selectedAddons: [], spiceLevel: SpiceLevel.medium),
        ],
        subtotal: 540.0,
        deliveryFee: 30.0,
        tax: 27.0,
        totalPrice: 597.0,
        status: OrderStatus.preparing,
        paymentMethod: PaymentMethod.cashOnDelivery,
        deliveryAddress: homeAddress,
        createdAt: now.subtract(const Duration(minutes: 15)),
        updatedAt: now.subtract(const Duration(minutes: 10)),
        estimatedDeliveryTime: now.add(const Duration(minutes: 20)),
      ));

      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 3600000}',
        userId: '1',
        items: [
          CartItemModel(id: 'ci_3', menuItem: _safeGetMenuItem(1), quantity: 1, selectedAddons: [], spiceLevel: SpiceLevel.mild),
        ],
        subtotal: 200.0,
        deliveryFee: 30.0,
        tax: 10.0,
        totalPrice: 240.0,
        status: OrderStatus.delivered,
        paymentMethod: PaymentMethod.upi,
        deliveryAddress: homeAddress,
        deliveryPartnerId: '3',
        deliveryPartnerName: 'Ravi Kumar',
        deliveryPartnerPhone: '+919876543212',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      ));

      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 7200000}',
        userId: '1',
        items: [
          CartItemModel(id: 'ci_4', menuItem: _safeGetMenuItem(3), quantity: 3, selectedAddons: [], spiceLevel: SpiceLevel.spicy),
          CartItemModel(id: 'ci_5', menuItem: _safeGetMenuItem(5), quantity: 2, selectedAddons: [], spiceLevel: SpiceLevel.medium),
        ],
        subtotal: 480.0,
        deliveryFee: 0.0,
        tax: 24.0,
        discount: 50.0,
        promoCode: 'FIRST50',
        totalPrice: 454.0,
        status: OrderStatus.outForDelivery,
        paymentMethod: PaymentMethod.phonePe,
        deliveryAddress: homeAddress,
        deliveryPartnerId: '3',
        deliveryPartnerName: 'Ravi Kumar',
        deliveryPartnerPhone: '+919876543212',
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(minutes: 25)),
        estimatedDeliveryTime: now.add(const Duration(minutes: 10)),
      ));

      // --- Yesterday's Orders ---
      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 86400000}',
        userId: '1',
        items: [
          CartItemModel(id: 'ci_6', menuItem: _safeGetMenuItem(0), quantity: 1, selectedAddons: [], spiceLevel: SpiceLevel.medium),
        ],
        subtotal: 270.0,
        deliveryFee: 30.0,
        tax: 13.5,
        totalPrice: 313.5,
        status: OrderStatus.delivered,
        paymentMethod: PaymentMethod.cashOnDelivery,
        deliveryAddress: homeAddress,
        deliveryPartnerId: '3',
        deliveryPartnerName: 'Ravi Kumar',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 1)),
      ));

      _orders.add(OrderModel(
        id: 'ORD${now.millisecondsSinceEpoch - 90000000}',
        userId: '1',
        items: [
          CartItemModel(id: 'ci_7', menuItem: _safeGetMenuItem(4), quantity: 2, selectedAddons: [], spiceLevel: SpiceLevel.mild),
          CartItemModel(id: 'ci_8', menuItem: _safeGetMenuItem(5), quantity: 1, selectedAddons: [], spiceLevel: SpiceLevel.medium),
        ],
        subtotal: 350.0,
        deliveryFee: 30.0,
        tax: 17.5,
        totalPrice: 397.5,
        status: OrderStatus.cancelled,
        paymentMethod: PaymentMethod.googlePay,
        deliveryAddress: homeAddress,
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 4, minutes: 55)),
      ));

      // --- Last week orders ---
      for (int i = 2; i <= 6; i++) {
        _orders.add(OrderModel(
          id: 'ORD_WEEK_$i',
          userId: '1',
          items: [
            CartItemModel(id: 'ci_w_$i', menuItem: _safeGetMenuItem(i), quantity: 1 + (i % 3), selectedAddons: [], spiceLevel: SpiceLevel.medium),
          ],
          subtotal: 180.0 + (i * 40),
          deliveryFee: 30.0,
          tax: 10.0 + i,
          totalPrice: 220.0 + (i * 40),
          status: OrderStatus.delivered,
          paymentMethod: PaymentMethod.cashOnDelivery,
          deliveryAddress: homeAddress,
          deliveryPartnerId: '3',
          deliveryPartnerName: 'Ravi Kumar',
          createdAt: now.subtract(Duration(days: i)),
          updatedAt: now.subtract(Duration(days: i, hours: -1)),
        ));
      }
    } catch (e) {
      debugPrint('MockOrderService init error: $e');
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _orders.where((o) => o.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
      promoCode: promoCode,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 35)),
    );
    _orders.insert(0, order);
    _orderStreamController.add(List.from(_orders));
    return order;
  }

  Future<bool> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 &&
        (_orders[index].status == OrderStatus.placed ||
            _orders[index].status == OrderStatus.preparing)) {
      _orders[index] = _orders[index].copyWith(
        status: OrderStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      _orderStreamController.add(List.from(_orders));
      return true;
    }
    return false;
  }

  Future<OrderModel> reorder(OrderModel previousOrder) async {
    return createOrder(
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

  Map<String, dynamic> getDashboardStats() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));
    final monthStart = DateTime(now.year, now.month, 1);

    final todayOrders = _orders.where((o) => o.createdAt.isAfter(todayStart)).toList();
    final weekOrders = _orders.where((o) => o.createdAt.isAfter(weekStart)).toList();
    final monthOrders = _orders.where((o) => o.createdAt.isAfter(monthStart)).toList();
    final activeOrders = _orders.where((o) =>
        o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();

    double todayRevenue = todayOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (s, o) => s + o.totalPrice);
    double weekRevenue = weekOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (s, o) => s + o.totalPrice);
    double monthRevenue = monthOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (s, o) => s + o.totalPrice);

    // Popular items
    final itemCounts = <String, Map<String, dynamic>>{};
    for (final order in _orders.where((o) => o.status == OrderStatus.delivered)) {
      for (final cartItem in order.items) {
        final id = cartItem.menuItem.id;
        itemCounts[id] ??= {'menuItem': cartItem.menuItem, 'count': 0, 'revenue': 0.0};
        itemCounts[id]!['count'] = (itemCounts[id]!['count'] as int) + cartItem.quantity;
        itemCounts[id]!['revenue'] =
            (itemCounts[id]!['revenue'] as double) + (cartItem.menuItem.price * cartItem.quantity);
      }
    }
    final popularItems = itemCounts.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return {
      'todayOrders': todayOrders.length,
      'todayRevenue': todayRevenue,
      'activeOrders': activeOrders.length,
      'monthRevenue': monthRevenue,
      'weekRevenue': weekRevenue,
      'weekOrders': weekOrders.length,
      'monthOrders': monthOrders.length,
      'popularItems': popularItems.take(5).toList(),
      'totalOrders': _orders.length,
    };
  }

  Future<List<OrderModel>> getAllOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_orders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: OrderStatus.outForDelivery,
        deliveryPartnerId: partnerId,
        deliveryPartnerName: partnerName ?? 'Delivery Partner',
        deliveryPartnerPhone: partnerPhone ?? '',
        updatedAt: DateTime.now(),
      );
      _orderStreamController.add(List.from(_orders));
    }
  }

  List<OrderModel> getOrdersByStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).toList();

  Future<List<OrderModel>> getAssignedDeliveries(String partnerId) async =>
      _orders
          .where((o) =>
              o.status == OrderStatus.outForDelivery &&
              (o.deliveryPartnerId == partnerId || o.deliveryPartnerId == null))
          .toList();

  Future<List<OrderModel>> getActiveDeliveries(String partnerId) async =>
      getAssignedDeliveries(partnerId);

  Future<List<OrderModel>> getDeliveryHistory(String partnerId) async =>
      _orders
          .where((o) =>
              o.status == OrderStatus.delivered &&
              (o.deliveryPartnerId == partnerId))
          .toList();

  Future<bool> markDeliveryComplete(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.delivered);
    return true;
  }

  Map<String, dynamic> getDeliveryPartnerStats(String partnerId) {
    final completed = _orders
        .where((o) => o.status == OrderStatus.delivered && o.deliveryPartnerId == partnerId)
        .length;
    final earnings = completed * 30.0;
    final active = _orders
        .where((o) => o.status == OrderStatus.outForDelivery && o.deliveryPartnerId == partnerId)
        .length;
    return {
      'totalDeliveries': completed,
      'totalEarnings': earnings,
      'activeDeliveries': active,
    };
  }

  Future<Map<String, double>> getDeliveryPartnerLocation(String orderId) async =>
      {'latitude': 12.0540, 'longitude': 78.4822};

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  Map<OrderStatus, int> getOrderStats(String userId) {
    final stats = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      stats[status] = _orders.where((o) => o.userId == userId && o.status == status).length;
    }
    return stats;
  }
}
