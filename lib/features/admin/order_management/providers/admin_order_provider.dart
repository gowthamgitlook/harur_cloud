import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/enums/order_status.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../config/app_config.dart';
import '../../../customer/orders/data/services/mock_order_service.dart';
import '../../../../data/services/firestore_order_service.dart';

class AdminOrderProvider with ChangeNotifier {
  late final MockOrderService? _mock;
  late final FirestoreOrderService? _firestore;

  List<OrderModel> _allOrders = [];
  OrderStatus? _statusFilter;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _orderSubscription;
  Map<String, dynamic> _dashboardStats = {};

  List<OrderModel> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderStatus? get statusFilter => _statusFilter;
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  List<OrderModel> get filteredOrders => _statusFilter == null
      ? _allOrders
      : _allOrders.where((o) => o.status == _statusFilter).toList();

  AdminOrderProvider() {
    if (AppConfig.useMockServices) {
      _mock = MockOrderService();
      _firestore = null;
      final mock = _mock as MockOrderService;
      _orderSubscription = mock.ordersStream.listen((orders) {
        _allOrders = orders;
        _dashboardStats = mock.getDashboardStats();
        notifyListeners();
      });
    } else {
      _mock = null;
      _firestore = FirestoreOrderService();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (AppConfig.useMockServices) {
        final mock = _mock;
        _allOrders = await mock!.getAllOrders();
        _dashboardStats = mock.getDashboardStats();
      } else {
        _allOrders = await _firestore!.getAllOrders();
        _dashboardStats = _computeStats(_allOrders);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      if (AppConfig.useMockServices) {
        await _mock!.updateOrderStatus(orderId, newStatus);
      } else {
        await _firestore!.updateOrderStatus(orderId, newStatus);
        final idx = _allOrders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _allOrders[idx] =
              _allOrders[idx].copyWith(status: newStatus, updatedAt: DateTime.now());
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignDeliveryPartner({
    required String orderId,
    required String partnerId,
    required String partnerName,
    required String partnerPhone,
  }) async {
    try {
      if (AppConfig.useMockServices) {
        await _mock!.assignDeliveryPartner(
          orderId: orderId,
          partnerId: partnerId,
          partnerName: partnerName,
          partnerPhone: partnerPhone,
        );
      } else {
        await _firestore!.assignDeliveryPartner(
          orderId: orderId,
          partnerId: partnerId,
          partnerName: partnerName,
          partnerPhone: partnerPhone,
        );
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void filterByStatus(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilter() {
    _statusFilter = null;
    notifyListeners();
  }

  Future<void> loadDashboardStats() async {
    try {
      if (AppConfig.useMockServices) {
        _dashboardStats = _mock!.getDashboardStats();
      } else {
        _dashboardStats = _computeStats(_allOrders);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    if (AppConfig.useMockServices) return _mock!.getOrdersByStatus(status);
    return _allOrders.where((o) => o.status == status).toList();
  }

  int getOrderCountByStatus(OrderStatus status) =>
      _allOrders.where((o) => o.status == status).length;

  double getTotalRevenue() => _allOrders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (s, o) => s + o.totalPrice);

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Map<String, dynamic> _computeStats(List<OrderModel> orders) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));
    final monthStart = DateTime(now.year, now.month, 1);

    final today = orders.where((o) => o.createdAt.isAfter(todayStart)).toList();
    final week = orders.where((o) => o.createdAt.isAfter(weekStart)).toList();
    final month = orders.where((o) => o.createdAt.isAfter(monthStart)).toList();
    final active = orders
        .where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
        .toList();

    double rev(List<OrderModel> list) => list
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (s, o) => s + o.totalPrice);

    final itemCounts = <String, Map<String, dynamic>>{};
    for (final o in orders.where((o) => o.status == OrderStatus.delivered)) {
      for (final ci in o.items) {
        final id = ci.menuItem.id;
        itemCounts[id] ??= {'menuItem': ci.menuItem, 'count': 0, 'revenue': 0.0};
        itemCounts[id]!['count'] =
            (itemCounts[id]!['count'] as int) + ci.quantity;
        itemCounts[id]!['revenue'] = (itemCounts[id]!['revenue'] as double) +
            ci.menuItem.price * ci.quantity;
      }
    }
    final popular = itemCounts.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return {
      'todayOrders': today.length,
      'todayRevenue': rev(today),
      'activeOrders': active.length,
      'weekOrders': week.length,
      'weekRevenue': rev(week),
      'monthOrders': month.length,
      'monthRevenue': rev(month),
      'totalOrders': orders.length,
      'popularItems': popular.take(5).toList(),
    };
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
