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

class MockOrderService {
  static final MockOrderService _instance = MockOrderService._internal();
  factory MockOrderService() => _instance;
  MockOrderService._internal() {
    // Initialize with sample orders for testing
    _initializeSampleOrders();
  }

  final List<OrderModel> _orders = [];
  final Map<String, Timer> _statusTimers = {};
  final _orderStreamController = StreamController<List<OrderModel>>.broadcast();

  Stream<List<OrderModel>> get ordersStream => _orderStreamController.stream;

  /// Initialize sample orders for testing
  void _initializeSampleOrders() {
    final now = DateTime.now();
    final sampleAddress = AddressModel(
      id: 'addr1',
      label: 'Home',
      fullAddress: 'Main Street, Harur, Dharmapuri, Tamil Nadu 636903',
      landmark: 'Near Bus Stand',
      latitude: AppConfig.harurLatitude,
      longitude: AppConfig.harurLongitude,
    );

    // Sample Order 1: Active - Preparing
    final order1Items = [
      CartItemModel(
        id: 'cart_item_1',
        menuItem: MockMenuData.menuItems[0], // Chicken Biryani
        quantity: 2,
        selectedAddons: [],
        spiceLevel: SpiceLevel.medium,
      ),
      CartItemModel(
        id: 'cart_item_2',
        menuItem: MockMenuData.menuItems[5], // Egg Fried Rice
        quantity: 1,
        selectedAddons: [],
        spiceLevel: SpiceLevel.medium,
      ),
    ];
    _orders.add(OrderModel(
      id: 'ORD${now.millisecondsSinceEpoch - 1000}',
      userId: '1', // Customer user ID
      items: order1Items,
      subtotal: 540.0,
      deliveryFee: 30.0,
      tax: 27.0,
      discount: 0.0,
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
        menuItem: MockMenuData.menuItems[8], // Chicken Kothu Parotta
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
      discount: 0.0,
      totalPrice: 189.0,
      status: OrderStatus.placed,
      paymentMethod: PaymentMethod.upi,
      deliveryAddress: sampleAddress,
      createdAt: now.subtract(const Duration(minutes: 5)),
      updatedAt: now.subtract(const Duration(minutes: 5)),
    ));

    // Sample Order 3: History - Delivered
    final order3Items = [
      CartItemModel(
        id: 'cart_item_4',
        menuItem: MockMenuData.menuItems[1], // Mutton Biryani
        quantity: 1,
        selectedAddons: [],
        spiceLevel: SpiceLevel.spicy,
      ),
      CartItemModel(
        id: 'cart_item_5',
        menuItem: MockMenuData.menuItems[9], // Egg Parotta
        quantity: 2,
        selectedAddons: [],
        spiceLevel: SpiceLevel.mild,
      ),
    ];
    _orders.add(OrderModel(
      id: 'ORD${now.millisecondsSinceEpoch - 3000}',
      userId: '1',
      items: order3Items,
      subtotal: 380.0,
      deliveryFee: 30.0,
      tax: 20.5,
      discount: 0.0,
      totalPrice: 430.5,
      status: OrderStatus.delivered,
      paymentMethod: PaymentMethod.cashOnDelivery,
      deliveryAddress: sampleAddress,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ));

    // Sample Order 4: History - Delivered
    final order4Items = [
      CartItemModel(
        id: 'cart_item_6',
        menuItem: MockMenuData.menuItems[4], // Chicken Fried Rice
        quantity: 2,
        selectedAddons: [],
        spiceLevel: SpiceLevel.medium,
      ),
    ];
    _orders.add(OrderModel(
      id: 'ORD${now.millisecondsSinceEpoch - 4000}',
      userId: '1',
      items: order4Items,
      subtotal: 280.0,
      deliveryFee: 30.0,
      tax: 15.5,
      discount: 0.0,
      totalPrice: 325.5,
      status: OrderStatus.delivered,
      paymentMethod: PaymentMethod.upi,
      deliveryAddress: sampleAddress,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ));
  }

  /// Create a new order from cart data
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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    final order = OrderModel(
      id: orderId,
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
      createdAt: now,
      updatedAt: now,
    );

    _orders.insert(0, order); // Add to beginning for recent-first order
    _orderStreamController.add(_orders);

    // Start automatic status progression
    _scheduleStatusUpdates(orderId);

    return order;
  }

  /// Schedule automatic status updates for an order
  void _scheduleStatusUpdates(String orderId) {
    // Cancel any existing timer for this order
    _statusTimers[orderId]?.cancel();

    int progressStep = 0;
    const statusProgression = [
      OrderStatus.placed,      // 0 minutes
      OrderStatus.preparing,   // 5 minutes
      OrderStatus.outForDelivery, // 20 minutes (15 more)
      OrderStatus.delivered,   // 35 minutes (15 more)
    ];

    // For demo purposes, use shorter intervals (30 seconds between each status)
    // In production, use real time intervals (300s, 1200s, 2100s)
    _statusTimers[orderId] = Timer.periodic(const Duration(seconds: 30), (timer) {
      progressStep++;

      if (progressStep >= statusProgression.length) {
        timer.cancel();
        _statusTimers.remove(orderId);
        return;
      }

      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex == -1) {
        timer.cancel();
        _statusTimers.remove(orderId);
        return;
      }

      final updatedOrder = _orders[orderIndex].copyWith(
        status: statusProgression[progressStep],
        updatedAt: DateTime.now(),
      );

      _orders[orderIndex] = updatedOrder;
      _orderStreamController.add(_orders);
    });
  }

  /// Get all orders for a specific user
  Future<List<OrderModel>> getUserOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((order) => order.userId == userId).toList();
  }

  /// Get a specific order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Get active orders (not delivered or cancelled)
  Future<List<OrderModel>> getActiveOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((order) =>
      order.userId == userId &&
      order.status != OrderStatus.delivered &&
      order.status != OrderStatus.cancelled
    ).toList();
  }

  /// Get order history (delivered or cancelled)
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((order) =>
      order.userId == userId &&
      (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled)
    ).toList();
  }

  /// Cancel an order (only if not yet preparing)
  Future<bool> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) return false;

    final order = _orders[orderIndex];

    // Can only cancel if order is still in placed status
    if (order.status != OrderStatus.placed) {
      return false;
    }

    final updatedOrder = order.copyWith(
      status: OrderStatus.cancelled,
      updatedAt: DateTime.now(),
    );

    _orders[orderIndex] = updatedOrder;
    _orderStreamController.add(_orders);

    // Cancel status progression timer
    _statusTimers[orderId]?.cancel();
    _statusTimers.remove(orderId);

    return true;
  }

  /// Reorder - creates a new order with same items
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
      promoCode: previousOrder.promoCode,
    );
  }

  /// Get order count by status
  Map<OrderStatus, int> getOrderStats(String userId) {
    final userOrders = _orders.where((o) => o.userId == userId);
    final stats = <OrderStatus, int>{};

    for (var status in OrderStatus.values) {
      stats[status] = userOrders.where((o) => o.status == status).length;
    }

    return stats;
  }

  /// Simulate delivery partner location (mock)
  Future<Map<String, double>> getDeliveryPartnerLocation(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Mock location near Harur, Tamil Nadu
    final random = Random();
    return {
      'latitude': 12.0522 + (random.nextDouble() - 0.5) * 0.01,
      'longitude': 78.4844 + (random.nextDouble() - 0.5) * 0.01,
    };
  }

  /// Cleanup - cancel all timers
  void dispose() {
    for (var timer in _statusTimers.values) {
      timer.cancel();
    }
    _statusTimers.clear();
    _orderStreamController.close();
  }

  /// Clear all orders (for testing)
  void clearOrders() {
    _orders.clear();
    for (var timer in _statusTimers.values) {
      timer.cancel();
    }
    _statusTimers.clear();
    _orderStreamController.add(_orders);
  }

  // ========== ADMIN METHODS ==========

  /// Get all orders across all users
  Future<List<OrderModel>> getAllOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_orders);
  }

  /// Update order status (admin only)
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Order not found');
    }

    final updatedOrder = _orders[orderIndex].copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    _orders[orderIndex] = updatedOrder;
    _orderStreamController.add(_orders);

    // Cancel automatic progression if manually updated
    if (_statusTimers.containsKey(orderId)) {
      _statusTimers[orderId]?.cancel();
      _statusTimers.remove(orderId);
    }

    return updatedOrder;
  }

  /// Assign delivery partner to order
  Future<OrderModel> assignDeliveryPartner({
    required String orderId,
    required String partnerId,
    required String partnerName,
    required String partnerPhone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Order not found');
    }

    final updatedOrder = _orders[orderIndex].copyWith(
      deliveryPartnerId: partnerId,
      deliveryPartnerName: partnerName,
      deliveryPartnerPhone: partnerPhone,
      updatedAt: DateTime.now(),
    );

    _orders[orderIndex] = updatedOrder;
    _orderStreamController.add(_orders);

    return updatedOrder;
  }

  /// Get dashboard statistics
  Map<String, dynamic> getDashboardStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    // Today's stats
    final todayOrders = _orders.where((o) =>
      o.createdAt.isAfter(today) && o.createdAt.isBefore(now)
    ).toList();

    final todayRevenue = todayOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalPrice);

    // This week's stats
    final weekOrders = _orders.where((o) =>
      o.createdAt.isAfter(thisWeek) && o.createdAt.isBefore(now)
    ).toList();

    final weekRevenue = weekOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalPrice);

    // This month's stats
    final monthOrders = _orders.where((o) =>
      o.createdAt.isAfter(thisMonth) && o.createdAt.isBefore(now)
    ).toList();

    final monthRevenue = monthOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalPrice);

    // Active orders count
    final activeOrders = _orders.where((o) =>
      o.status != OrderStatus.delivered &&
      o.status != OrderStatus.cancelled
    ).length;

    // Popular items (from delivered orders)
    final deliveredOrders = _orders.where((o) => o.status == OrderStatus.delivered);
    final itemCounts = <String, Map<String, dynamic>>{};

    for (var order in deliveredOrders) {
      for (var item in order.items) {
        final itemId = item.menuItem.id;
        if (itemCounts.containsKey(itemId)) {
          itemCounts[itemId]!['count'] = itemCounts[itemId]!['count'] + item.quantity;
          itemCounts[itemId]!['revenue'] = itemCounts[itemId]!['revenue'] + item.totalPrice;
        } else {
          itemCounts[itemId] = {
            'menuItem': item.menuItem,
            'count': item.quantity,
            'revenue': item.totalPrice,
          };
        }
      }
    }

    // Sort by count and take top 5
    final sortedItems = itemCounts.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    final popularItems = sortedItems.take(5).toList();

    return {
      'todayOrders': todayOrders.length,
      'todayRevenue': todayRevenue,
      'weekOrders': weekOrders.length,
      'weekRevenue': weekRevenue,
      'monthOrders': monthOrders.length,
      'monthRevenue': monthRevenue,
      'activeOrders': activeOrders,
      'totalOrders': _orders.length,
      'popularItems': popularItems,
    };
  }

  /// Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // ========== DELIVERY PARTNER METHODS ==========

  /// Get orders assigned to a specific delivery partner
  Future<List<OrderModel>> getAssignedDeliveries(String partnerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) =>
      o.deliveryPartnerId == partnerId &&
      o.status == OrderStatus.outForDelivery
    ).toList();
  }

  /// Get active deliveries for a partner
  Future<List<OrderModel>> getActiveDeliveries(String partnerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) =>
      o.deliveryPartnerId == partnerId &&
      o.status == OrderStatus.outForDelivery
    ).toList();
  }

  /// Get delivery history for a partner
  Future<List<OrderModel>> getDeliveryHistory(String partnerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) =>
      o.deliveryPartnerId == partnerId &&
      o.status == OrderStatus.delivered
    ).toList();
  }

  /// Mark delivery as complete
  Future<bool> markDeliveryComplete(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) return false;

    final updatedOrder = _orders[orderIndex].copyWith(
      status: OrderStatus.delivered,
      updatedAt: DateTime.now(),
    );

    _orders[orderIndex] = updatedOrder;
    _orderStreamController.add(_orders);

    // Cancel any remaining timers
    _statusTimers[orderId]?.cancel();
    _statusTimers.remove(orderId);

    return true;
  }

  /// Get delivery partner stats
  Map<String, dynamic> getDeliveryPartnerStats(String partnerId) {
    final partnerOrders = _orders.where((o) => o.deliveryPartnerId == partnerId);
    final deliveredOrders = partnerOrders.where((o) => o.status == OrderStatus.delivered);

    final totalEarnings = deliveredOrders.fold(0.0, (sum, order) => sum + order.totalPrice);

    return {
      'totalDeliveries': deliveredOrders.length,
      'totalEarnings': totalEarnings,
      'activeDeliveries': partnerOrders.where((o) => o.status == OrderStatus.outForDelivery).length,
    };
  }
}
