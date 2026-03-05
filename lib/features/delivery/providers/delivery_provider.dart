import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/enums/order_status.dart';
import '../../../shared/models/order_model.dart';
import '../../customer/orders/data/services/mock_order_service.dart';

class DeliveryProvider with ChangeNotifier {
  final MockOrderService _orderService = MockOrderService();

  String? _partnerId;
  List<OrderModel> _assignedOrders = [];
  List<OrderModel> _activeDeliveries = [];
  List<OrderModel> _deliveryHistory = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _orderSubscription;

  // Delivery stats
  Map<String, dynamic> _deliveryStats = {};

  // Getters
  String? get partnerId => _partnerId;
  List<OrderModel> get assignedOrders => _assignedOrders;
  List<OrderModel> get activeDeliveries => _activeDeliveries;
  List<OrderModel> get deliveryHistory => _deliveryHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get deliveryStats => _deliveryStats;

  /// Get total deliveries completed
  int get totalDeliveriesCompleted {
    return _deliveryStats['totalDeliveries'] as int? ?? 0;
  }

  /// Get total earnings
  double get totalEarnings {
    return _deliveryStats['totalEarnings'] as double? ?? 0.0;
  }

  /// Get active deliveries count
  int get activeDeliveriesCount {
    return _deliveryStats['activeDeliveries'] as int? ?? 0;
  }

  DeliveryProvider() {
    // Subscribe to order updates
    _orderSubscription = _orderService.ordersStream.listen((orders) {
      if (_partnerId != null) {
        _updateOrderLists();
      }
    });
  }

  /// Set the current delivery partner ID
  void setPartnerId(String partnerId) {
    _partnerId = partnerId;
    _updateOrderLists();
    loadDeliveryStats();
  }

  /// Update order lists based on partner ID
  void _updateOrderLists() {
    if (_partnerId == null) return;

    _assignedOrders = _orderService.getOrdersByStatus(OrderStatus.outForDelivery)
        .where((order) => order.deliveryPartnerId == _partnerId)
        .toList();

    _activeDeliveries = _assignedOrders;

    _deliveryHistory = _orderService.getOrdersByStatus(OrderStatus.delivered)
        .where((order) => order.deliveryPartnerId == _partnerId)
        .toList();

    notifyListeners();
  }

  /// Fetch assigned orders
  Future<void> fetchAssignedOrders() async {
    if (_partnerId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assignedOrders = await _orderService.getAssignedDeliveries(_partnerId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch active deliveries
  Future<void> fetchActiveDeliveries() async {
    if (_partnerId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeDeliveries = await _orderService.getActiveDeliveries(_partnerId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch delivery history
  Future<void> fetchDeliveryHistory() async {
    if (_partnerId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveryHistory = await _orderService.getDeliveryHistory(_partnerId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark delivery as complete
  Future<bool> markDeliveryComplete(String orderId) async {
    try {
      final success = await _orderService.markDeliveryComplete(orderId);
      if (success) {
        // Update lists
        await fetchActiveDeliveries();
        await fetchDeliveryHistory();
        loadDeliveryStats();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load delivery partner statistics
  void loadDeliveryStats() {
    if (_partnerId == null) return;

    try {
      _deliveryStats = _orderService.getDeliveryPartnerStats(_partnerId!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get delivery partner location (mock)
  Future<Map<String, double>> getDeliveryPartnerLocation(String orderId) async {
    return await _orderService.getDeliveryPartnerLocation(orderId);
  }

  /// Group delivery history by date
  Map<String, List<OrderModel>> getHistoryGroupedByDate() {
    final grouped = <String, List<OrderModel>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var order in _deliveryHistory) {
      final orderDate = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );

      String key;
      if (orderDate == today) {
        key = 'Today';
      } else if (orderDate == yesterday) {
        key = 'Yesterday';
      } else if (orderDate.isAfter(today.subtract(const Duration(days: 7)))) {
        key = 'Last 7 days';
      } else if (orderDate.isAfter(today.subtract(const Duration(days: 30)))) {
        key = 'Last 30 days';
      } else {
        key = 'Older';
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(order);
    }

    return grouped;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
