import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/order_model.dart';
import '../../shared/models/cart_item_model.dart';
import '../../shared/models/address_model.dart';
import '../../shared/enums/payment_method.dart';
import '../../shared/enums/order_status.dart';
import 'order_service_interface.dart';

class FirestoreOrderService implements IOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return OrderModel.fromJson(data);
    }).toList();
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
    final orderData = {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod.name,
      'deliveryAddress': deliveryAddress.toJson(),
      'status': OrderStatus.placed.name,
      'promoCode': promoCode,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final docRef = await _firestore.collection('orders').add(orderData);
    orderData['id'] = docRef.id;
    return OrderModel.fromJson(orderData);
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return OrderModel.fromJson(data);
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
