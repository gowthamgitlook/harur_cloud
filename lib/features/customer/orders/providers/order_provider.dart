import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/cart_item_model.dart';
import '../../../../shared/models/address_model.dart';
import '../../../../shared/enums/order_status.dart';
import '../../../../shared/enums/payment_method.dart';
import '../../../../config/app_config.dart';
import '../data/services/mock_order_service.dart';
import '../../../../data/services/firestore_order_service.dart';

class OrderProvider with ChangeNotifier {
  late final MockOrderService? _mockService;
  late final FirestoreOrderService? _firestoreService;

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
    if (AppConfig.useMockServices) {
      _mockService = MockOrderService();
      _firestoreService = null;
      _subscribeToMockStream();
    } else {
      _mockService = null;
      _firestoreService = FirestoreOrderService();
    }
  }

  void _subscribeToMockStream() {
    try {
      _orderSubscription = _mockService!.ordersStream.listen(
        (updated) {
          _orders = updated;
          _categorizeOrders();
          notifyListeners();
        },
        onError: (err) {
          _error = 'Order stream error: $err';
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('OrderProvider stream setup failed: $e');
    }
  }

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (AppConfig.useMockServices) {
        _orders = await _mockService!.getUserOrders(userId);
      } else {
        _orders = await _firestoreService!.getUserOrders(userId);
      }
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
      final OrderModel order;
      if (AppConfig.useMockServices) {
        order = await _mockService!.createOrder(
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
      } else {
        order = await _firestoreService!.createOrder(
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
        _orders.insert(0, order);
        _categorizeOrders();
      }
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
      if (AppConfig.useMockServices) {
        return await _mockService!.getOrderById(orderId);
      }
      return await _firestoreService!.getOrderById(orderId);
    } catch (e) {
      _error = 'Failed to load order: $e';
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final bool result;
      if (AppConfig.useMockServices) {
        result = await _mockService!.cancelOrder(orderId);
      } else {
        result = await _firestoreService!.cancelOrder(orderId);
        if (result) {
          final idx = _orders.indexWhere((o) => o.id == orderId);
          if (idx != -1) {
            _orders[idx] = _orders[idx].copyWith(
                status: OrderStatus.cancelled, updatedAt: DateTime.now());
            _categorizeOrders();
            notifyListeners();
          }
        }
      }
      return result;
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
      final OrderModel order;
      if (AppConfig.useMockServices) {
        order = await _mockService!.reorder(previousOrder);
      } else {
        order = await _firestoreService!.reorder(previousOrder);
        _orders.insert(0, order);
        _categorizeOrders();
      }
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
      if (AppConfig.useMockServices) {
        return await _mockService!.getDeliveryPartnerLocation(orderId);
      }
      return await _firestoreService!.getDeliveryPartnerLocation(orderId);
    } catch (_) {
      return {'latitude': AppConfig.harurLatitude, 'longitude': AppConfig.harurLongitude};
    }
  }

  Map<OrderStatus, int> getOrderStats(String userId) {
    if (AppConfig.useMockServices) {
      return _mockService!.getOrderStats(userId);
    }
    final stats = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      stats[status] = _orders.where((o) => o.userId == userId && o.status == status).length;
    }
    return stats;
  }

  void _categorizeOrders() {
    _activeOrders = _orders
        .where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
        .toList();
    _orderHistory = _orders
        .where((o) =>
            o.status == OrderStatus.delivered ||
            o.status == OrderStatus.cancelled)
        .toList();
  }

  double getTotalSpent() {
    return _orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, o) => sum + o.totalPrice);
  }

  List<String> getMostOrderedItems({int limit = 5}) {
    final counts = <String, int>{};
    for (final o in _orders) {
      if (o.status == OrderStatus.delivered) {
        for (final item in o.items) {
          counts[item.menuItem.name] = (counts[item.menuItem.name] ?? 0) + item.quantity;
        }
      }
    }
    return (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(limit)
        .map((e) => e.key)
        .toList();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
