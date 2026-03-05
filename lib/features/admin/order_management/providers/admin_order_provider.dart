import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/enums/order_status.dart';
import '../../../../shared/models/order_model.dart';
import '../../../customer/orders/data/services/mock_order_service.dart';

class AdminOrderProvider with ChangeNotifier {
  final MockOrderService _orderService = MockOrderService();

  List<OrderModel> _allOrders = [];
  OrderStatus? _statusFilter;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _orderSubscription;

  // Dashboard stats
  Map<String, dynamic> _dashboardStats = {};

  // Getters
  List<OrderModel> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderStatus? get statusFilter => _statusFilter;
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  /// Get filtered orders based on status filter
  List<OrderModel> get filteredOrders {
    if (_statusFilter == null) {
      return _allOrders;
    }
    return _allOrders.where((order) => order.status == _statusFilter).toList();
  }

  AdminOrderProvider() {
    // Subscribe to order updates
    _orderSubscription = _orderService.ordersStream.listen((orders) {
      _allOrders = orders;
      notifyListeners();
    });
  }

  /// Fetch all orders across all users
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allOrders = await _orderService.getAllOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Assign delivery partner to an order
  Future<bool> assignDeliveryPartner({
    required String orderId,
    required String partnerId,
    required String partnerName,
    required String partnerPhone,
  }) async {
    try {
      await _orderService.assignDeliveryPartner(
        orderId: orderId,
        partnerId: partnerId,
        partnerName: partnerName,
        partnerPhone: partnerPhone,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Filter orders by status
  void filterByStatus(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Clear status filter
  void clearFilter() {
    _statusFilter = null;
    notifyListeners();
  }

  /// Load dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      _dashboardStats = _orderService.getDashboardStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get orders by specific status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orderService.getOrdersByStatus(status);
  }

  /// Get order count by status
  int getOrderCountByStatus(OrderStatus status) {
    return _allOrders.where((order) => order.status == status).length;
  }

  /// Get total revenue from delivered orders
  double getTotalRevenue() {
    return _allOrders
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalPrice);
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
