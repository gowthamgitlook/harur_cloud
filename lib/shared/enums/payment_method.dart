import 'package:flutter/material.dart';

enum PaymentMethod {
  upi,
  googlePay,
  phonePe,
  razorpay,
  cashOnDelivery;

  String get displayName {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.phonePe:
        return 'PhonePe';
      case PaymentMethod.razorpay:
        return 'Razorpay';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.upi:
        return Icons.account_balance;
      case PaymentMethod.googlePay:
        return Icons.g_mobiledata;
      case PaymentMethod.phonePe:
        return Icons.phone_android;
      case PaymentMethod.razorpay:
        return Icons.credit_card;
      case PaymentMethod.cashOnDelivery:
        return Icons.money;
    }
  }

  bool get requiresOnlinePayment {
    return this != PaymentMethod.cashOnDelivery;
  }

  static PaymentMethod fromString(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return PaymentMethod.upi;
      case 'googlepay':
      case 'google pay':
        return PaymentMethod.googlePay;
      case 'phonepe':
      case 'phone pe':
        return PaymentMethod.phonePe;
      case 'razorpay':
        return PaymentMethod.razorpay;
      case 'cashondelivery':
      case 'cash on delivery':
      case 'cod':
        return PaymentMethod.cashOnDelivery;
      default:
        return PaymentMethod.cashOnDelivery;
    }
  }
}
