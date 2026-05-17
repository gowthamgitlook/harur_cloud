import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  Future<void> initiateUpiPayment({
    required String payeeVpa,
    required String payeeName,
    required double amount,
    required String transactionNote,
  }) async {
    final String upiUrl = 'upi://pay?pa=$payeeVpa&pn=${Uri.encodeComponent(payeeName)}&am=$amount&tn=${Uri.encodeComponent(transactionNote)}&cu=INR';
    
    try {
      final Uri uri = Uri.parse(upiUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch UPI apps. Please install GPay, PhonePe or any UPI app.';
      }
    } catch (e) {
      debugPrint('Payment Error: $e');
      rethrow;
    }
  }
}
