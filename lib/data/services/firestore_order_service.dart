import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/order_model.dart';
import '../../shared/models/cart_item_model.dart';
import '../../shared/models/address_model.dart';
import '../../shared/enums/payment_method.dart';
import '../../shared/enums/order_status.dart';
import 'order_service_interface.dart';

class FirestoreOrderService implements IOrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final _orderStreamController = StreamController<List<OrderModel>>.broadcast();
  Stream<List<OrderModel>> get ordersStream => _orderStreamController.stream;

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snap = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => _fromDoc(d)).toList();
  }

  @override
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
    final now = DateTime.now().toIso8601String();
    final data = {
      'userId': userId,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod.name,
      'deliveryAddress': deliveryAddress.toJson(),
      'status': OrderStatus.placed.name,
      'promoCode': promoCode,
      'createdAt': now,
      'updatedAt': now,
      'estimatedDeliveryTime':
          DateTime.now().add(const Duration(minutes: 35)).toIso8601String(),
    };
    final ref = await _db.collection('orders').add(data);
    data['id'] = ref.id;
    final order = OrderModel.fromJson(data);
    _orderStreamController.add([order]);
    return order;
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _db.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<OrderModel> reorder(OrderModel prev) => createOrder(
        userId: prev.userId,
        items: prev.items,
        subtotal: prev.subtotal,
        deliveryFee: prev.deliveryFee,
        tax: prev.tax,
        discount: prev.discount,
        totalPrice: prev.totalPrice,
        paymentMethod: prev.paymentMethod,
        deliveryAddress: prev.deliveryAddress,
      );

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> assignDeliveryPartner({
    required String orderId,
    required String partnerId,
    String? partnerName,
    String? partnerPhone,
  }) async {
    await _db.collection('orders').doc(orderId).update({
      'status': OrderStatus.outForDelivery.name,
      'deliveryPartnerId': partnerId,
      'deliveryPartnerName': partnerName ?? 'Delivery Partner',
      'deliveryPartnerPhone': partnerPhone ?? '',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snap = await _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => _fromDoc(d)).toList();
  }

  Future<List<OrderModel>> getAssignedDeliveries(String partnerId) async {
    final snap = await _db
        .collection('orders')
        .where('status', isEqualTo: OrderStatus.outForDelivery.name)
        .where('deliveryPartnerId', isEqualTo: partnerId)
        .get();
    return snap.docs.map((d) => _fromDoc(d)).toList();
  }

  Future<List<OrderModel>> getDeliveryHistory(String partnerId) async {
    final snap = await _db
        .collection('orders')
        .where('status', isEqualTo: OrderStatus.delivered.name)
        .where('deliveryPartnerId', isEqualTo: partnerId)
        .get();
    return snap.docs.map((d) => _fromDoc(d)).toList();
  }

  Future<bool> markDeliveryComplete(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.delivered);
    return true;
  }

  Future<Map<String, double>> getDeliveryPartnerLocation(String orderId) async =>
      {'latitude': 12.0540, 'longitude': 78.4822};

  Map<OrderStatus, int> getOrderStats(String userId) => {};

  Map<String, dynamic> getDashboardStats() => {};

  Map<String, dynamic> getDeliveryPartnerStats(String partnerId) => {
        'totalDeliveries': 0,
        'totalEarnings': 0.0,
        'activeDeliveries': 0,
      };

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromDoc(d)).toList());
  }

  static OrderModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    data['id'] = doc.id;
    return OrderModel.fromJson(data);
  }
}
