import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/cart_item_model.dart';
import '../../../../shared/models/address_model.dart';
import '../../../../shared/enums/order_status.dart';
import '../../../../shared/enums/payment_method.dart';
import '../data/services/mock_order_service.dart';

class OrderProvider with ChangeNotifier {
  final MockOrderService _orderService = MockOrderService();

  List<OrderModel> _orders = [];
  List<OrderModel> _activeOrders = [];
  List<OrderModel> _orderHistory = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _orderSubscription;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get activeOrders => _activeOrders;
  List<OrderModel> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveOrders => _activeOrders.isNotEmpty;
  bool get hasOrderHistory => _orderHistory.isNotEmpty;

  OrderProvider() {
    _safeInitialize();
  }

  void _safeInitialize() {
    try {
      _orderSubscription = _orderService.ordersStream.listen(
        (updatedOrders) {
          _orders = updatedOrders;
          _categorizeOrders();
          notifyListeners();
        },
        onError: (err) {
          _error = 'Order update stream error: $err';
          notifyListeners();
        }
      );
    } catch (e) {
      debugPrint('OrderProvider setup failed: $e');
    }
  }

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getUserOrders(userId);
      _categorizeOrders();
    } catch (e) {
      _error = 'Failed to load orders: $e';
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> createOrder({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        userId: userId,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        tax: tax,
        discount: discount,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        promoCode: promoCode,
      );
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = 'Failed to create order: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return await _orderService.getOrderById(orderId);
    } catch (e) {
      _error = 'Failed to load order: $e';
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      return await _orderService.cancelOrder(orderId);
    } catch (e) {
      _error = 'Failed to cancel order: $e';
      return false;
    }
  }

  Future<OrderModel?> reorder(OrderModel previousOrder) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _orderService.reorder(previousOrder);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = 'Failed to reorder: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, double>> getDeliveryPartnerLocation(String orderId) async {
    try {
      return await _orderService.getDeliveryPartnerLocation(orderId);
    } catch (e) {
      return {'latitude': 12.0540, 'longitude': 78.4822};
    }
  }

  Map<OrderStatus, int> getOrderStats(String userId) {
    return _orderService.getOrderStats(userId);
  }

  void _categorizeOrders() {
    _activeOrders = _orders.where((order) =>
      order.status != OrderStatus.delivered &&
      order.status != OrderStatus.cancelled
    ).toList();

    _orderHistory = _orders.where((order) =>
      order.status == OrderStatus.delivered ||
      order.status == OrderStatus.cancelled
    ).toList();
  }

  double getTotalSpent() {
    return _orders
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  List<String> getMostOrderedItems({int limit = 5}) {
    final itemCounts = <String, int>{};
    for (var order in _orders) {
      if (order.status == OrderStatus.delivered) {
        for (var item in order.items) {
          final itemName = item.menuItem.name;
          itemCounts[itemName] = (itemCounts[itemName] ?? 0) + item.quantity;
        }
      }
    }
    final sortedItems = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedItems.take(limit).map((e) => e.key).toList();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
