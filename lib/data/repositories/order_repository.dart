
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service managing Order placement via Stripe and Cloud Firestore.

class OrderRepository {
  final Dio _dio = Dio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal();

  /// Creates a Payment Intent via Stripe API.
  Future<Map<String, dynamic>> createPaymentIntent(double amount, String currency) async {
    try {
      final Map<String, dynamic> body = {
        'amount': _calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      final response = await _dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      throw Exception('Stripe Payment Intent Error: ${e.message}');
    } catch (err) {
      throw Exception('Stripe Payment Intent Error: $err');
    }
  }

  /// Initialize and Display Stripe Payment Sheet.
  Future<void> processStripePayment({
    required double amount, 
    required String currency,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final paymentIntent = await createPaymentIntent(amount, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Aaliyah Collection',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      onSuccess();

    } catch (e) {
      if (e is StripeException) {
         onError(e.error.localizedMessage ?? 'Payment Failed');
      } else {
         onError(e.toString());
      }
    }
  }

  /// Store Order in Cloud Firestore.
  Future<String?> storeOrderInFirestore({
    required Map<String, dynamic> orderData,
  }) async {
    try {
      // Ensure date is numeric for sorting
      if (orderData['date'] is String) {
        try {
          orderData['timestamp'] = DateTime.parse(orderData['date']).millisecondsSinceEpoch;
          // Store actual Timestamp object for native Firestore sorting
          orderData['createdAt'] = FieldValue.serverTimestamp();
        } catch (_) {
          orderData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
          orderData['createdAt'] = FieldValue.serverTimestamp();
        }
      } else {
        orderData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        orderData['createdAt'] = FieldValue.serverTimestamp();
      }

      final docRef = await _firestore.collection('orders').add(orderData);
      debugPrint('Order stored in Firestore: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Failed to store order in Firestore: $e');
      return null;
    }
  }

  /// Fetch orders from Cloud Firestore.
  /// Uses index-optimized queries.
  Future<List<Map<String, dynamic>>> getOrders(String email) async {
    final String cleanEmail = email.toLowerCase().trim();
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('customer.email', isEqualTo: cleanEmail)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
    } catch (e) {
      debugPrint('Error fetching orders from Firestore: $e');
      // If index is missing, firestore will throw an error with a link to create it.
      return _getOrdersFallback(cleanEmail);
    }
  }

  /// Fallback for client-side filtering if indexes are not yet deployed.
  Future<List<Map<String, dynamic>>> _getOrdersFallback(String email) async {
    try {
      final querySnapshot = await _firestore.collection('orders').get();
      
      final List<Map<String, dynamic>> orders = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['customer'] != null && 
            data['customer']['email'] != null && 
            data['customer']['email'].toString().toLowerCase() == email.toLowerCase()) {
          data['id'] = doc.id;
          orders.add(data);
        }
      }
      
      orders.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
      return orders;
    } catch (e) {
      debugPrint('Fallback fetching failed: $e');
      return [];
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt();
    return calculatedAmount.toString();
  }
}
