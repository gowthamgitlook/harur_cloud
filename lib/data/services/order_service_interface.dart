import '../../shared/models/order_model.dart';
import '../../shared/models/cart_item_model.dart';
import '../../shared/models/address_model.dart';
import '../../shared/enums/payment_method.dart';

abstract class IOrderService {
  Future<List<OrderModel>> getUserOrders(String userId);
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
  });
  Future<OrderModel?> getOrderById(String orderId);
  Future<bool> cancelOrder(String orderId);
}
