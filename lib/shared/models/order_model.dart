import '../enums/order_status.dart';
import '../enums/payment_method.dart';
import 'address_model.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double totalPrice;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final AddressModel deliveryAddress;
  final String? deliveryPartnerId;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? promoCode;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedDeliveryTime;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    this.discount = 0.0,
    required this.totalPrice,
    this.status = OrderStatus.placed,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.deliveryPartnerId,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    this.promoCode,
    this.specialInstructions,
    DateTime? createdAt,
    this.updatedAt,
    this.estimatedDeliveryTime,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Check if order is active (not delivered or cancelled)
  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  // From JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: OrderStatus.fromString(json['status'] as String),
      paymentMethod: PaymentMethod.fromString(json['paymentMethod'] as String),
      deliveryAddress: AddressModel.fromJson(
        json['deliveryAddress'] as Map<String, dynamic>,
      ),
      deliveryPartnerId: json['deliveryPartnerId'] as String?,
      deliveryPartnerName: json['deliveryPartnerName'] as String?,
      deliveryPartnerPhone: json['deliveryPartnerPhone'] as String?,
      promoCode: json['promoCode'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'] as String)
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'totalPrice': totalPrice,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'deliveryAddress': deliveryAddress.toJson(),
      'deliveryPartnerId': deliveryPartnerId,
      'deliveryPartnerName': deliveryPartnerName,
      'deliveryPartnerPhone': deliveryPartnerPhone,
      'promoCode': promoCode,
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
    };
  }

  // Copy With
  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? discount,
    double? totalPrice,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    AddressModel? deliveryAddress,
    String? deliveryPartnerId,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    String? promoCode,
    String? specialInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedDeliveryTime,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryPartnerId: deliveryPartnerId ?? this.deliveryPartnerId,
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone ?? this.deliveryPartnerPhone,
      promoCode: promoCode ?? this.promoCode,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
    );
  }

  @override
  String toString() => 'OrderModel(id: $id, status: ${status.displayName}, total: ₹$totalPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
