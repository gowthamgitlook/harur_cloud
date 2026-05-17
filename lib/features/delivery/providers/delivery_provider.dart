import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/enums/order_status.dart';
import '../../../shared/models/order_model.dart';
import '../../../config/app_config.dart';
import '../../customer/orders/data/services/mock_order_service.dart';
import '../../../data/services/firestore_order_service.dart';

class DeliveryProvider with ChangeNotifier {
  late final MockOrderService? _mock;
  late final FirestoreOrderService? _firestore;

  String? _partnerId;
  List<OrderModel> _assignedOrders = [];
  List<OrderModel> _activeDeliveries = [];
  List<OrderModel> _deliveryHistory = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _orderSubscription;
  Map<String, dynamic> _deliveryStats = {};

  String? get partnerId => _partnerId;
  List<OrderModel> get assignedOrders => _assignedOrders;
  List<OrderModel> get activeDeliveries => _activeDeliveries;
  List<OrderModel> get deliveryHistory => _deliveryHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get deliveryStats => _deliveryStats;

  int get totalDeliveriesCompleted =>
      _deliveryStats['totalDeliveries'] as int? ?? 0;
  double get totalEarnings =>
      _deliveryStats['totalEarnings'] as double? ?? 0.0;
  int get activeDeliveriesCount =>
      _deliveryStats['activeDeliveries'] as int? ?? 0;

  DeliveryProvider() {
    if (AppConfig.useMockServices) {
      final mockInstance = MockOrderService();
      _mock = mockInstance;
      _firestore = null;
      _orderSubscription = mockInstance.ordersStream.listen((_) {
        if (_partnerId != null) _updateOrderLists();
      });
    } else {
      _mock = null;
      _firestore = FirestoreOrderService();
    }
  }

  void setPartnerId(String partnerId) {
    _partnerId = partnerId;
    _updateOrderLists();
    loadDeliveryStats();
  }

  void _updateOrderLists() {
    if (_partnerId == null) return;
    final mock = _mock;
    if (AppConfig.useMockServices && mock != null) {
      _assignedOrders = mock
          .getOrdersByStatus(OrderStatus.outForDelivery)
          .where((o) => o.deliveryPartnerId == _partnerId)
          .toList();
      _activeDeliveries = _assignedOrders;
      _deliveryHistory = mock
          .getOrdersByStatus(OrderStatus.delivered)
          .where((o) => o.deliveryPartnerId == _partnerId)
          .toList();
      notifyListeners();
    }
  }

  Future<void> fetchAssignedOrders() async {
    if (_partnerId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (AppConfig.useMockServices) {
        _assignedOrders = await _mock!.getAssignedDeliveries(_partnerId!);
      } else {
        _assignedOrders = await _firestore!.getAssignedDeliveries(_partnerId!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveDeliveries() async {
    if (_partnerId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (AppConfig.useMockServices) {
        _activeDeliveries = await _mock!.getActiveDeliveries(_partnerId!);
      } else {
        _activeDeliveries = await _firestore!.getAssignedDeliveries(_partnerId!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDeliveryHistory() async {
    if (_partnerId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (AppConfig.useMockServices) {
        _deliveryHistory = await _mock!.getDeliveryHistory(_partnerId!);
      } else {
        _deliveryHistory = await _firestore!.getDeliveryHistory(_partnerId!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markDeliveryComplete(String orderId) async {
    try {
      bool success;
      if (AppConfig.useMockServices) {
        success = await _mock!.markDeliveryComplete(orderId);
      } else {
        success = await _firestore!.markDeliveryComplete(orderId);
      }
      if (success) {
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

  void loadDeliveryStats() {
    if (_partnerId == null) return;
    try {
      if (AppConfig.useMockServices) {
        _deliveryStats = _mock!.getDeliveryPartnerStats(_partnerId!);
      } else {
        final completed =
            _deliveryHistory.where((o) => o.deliveryPartnerId == _partnerId).length;
        final active =
            _activeDeliveries.where((o) => o.deliveryPartnerId == _partnerId).length;
        _deliveryStats = {
          'totalDeliveries': completed,
          'totalEarnings': completed * 30.0,
          'activeDeliveries': active,
        };
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, double>> getDeliveryPartnerLocation(String orderId) async {
    if (AppConfig.useMockServices) {
      return await _mock!.getDeliveryPartnerLocation(orderId);
    }
    return await _firestore!.getDeliveryPartnerLocation(orderId);
  }

  Map<String, List<OrderModel>> getHistoryGroupedByDate() {
    final grouped = <String, List<OrderModel>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final order in _deliveryHistory) {
      final d = DateTime(order.createdAt.year, order.createdAt.month, order.createdAt.day);
      String key;
      if (d == today) {
        key = 'Today';
      } else if (d == yesterday) {
        key = 'Yesterday';
      } else if (d.isAfter(today.subtract(const Duration(days: 7)))) {
        key = 'Last 7 days';
      } else if (d.isAfter(today.subtract(const Duration(days: 30)))) {
        key = 'Last 30 days';
      } else {
        key = 'Older';
      }
      grouped.putIfAbsent(key, () => []).add(order);
    }
    return grouped;
  }

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
