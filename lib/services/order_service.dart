import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';


class OrderService {
  
  // Singleton pattern for easier access if needed, or static methods
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  /// Creates a Payment Intent via Stripe API
  Future<Map<String, dynamic>> createPaymentIntent(double amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': _calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      throw Exception('Stripe Payment Intent Error: $err');
    }
  }

  /// Initialize and Display Stripe Payment Sheet
  Future<void> processStripePayment({
    required double amount, 
    required String currency,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // 1. Create Intent
      final paymentIntent = await createPaymentIntent(amount, currency);

      // 2. Initialize Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Aaliyah Collection',
          style: ThemeMode.system,
        ),
      );

      // 3. Display Sheet
      await Stripe.instance.presentPaymentSheet();
      
      // If we reach here, payment is successful
      onSuccess();

    } catch (e) {
      if (e is StripeException) {
         onError(e.error.localizedMessage ?? "Payment Failed");
      } else {
         onError(e.toString());
      }
    }
  }

  /// Store Order in Firebase Realtime Database
  Future<void> storeOrderInFirebase({
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final dbUrl = dotenv.env['FIREBASE_DB_URL'];
      if (dbUrl == null) {
        debugPrint("Firebase DB URL not found in .env");
        return;
      }
      final url = "${dbUrl}orders.json";
      
      await http.post(
        Uri.parse(url),
        body: json.encode(orderData),
      );
      debugPrint("Order stored in Firebase");
    } catch (e) {
      debugPrint("Failed to store order in Firebase: $e");
      // Rethrow if you want UI to handle it, but typically we fail silently/loggingly for data sync
    }
  }

  /// Fetch orders from Firebase Realtime Database filtered by email
  Future<List<Map<String, dynamic>>> getOrders(String email) async {
    try {
      final dbUrl = dotenv.env['FIREBASE_DB_URL'];
      if (dbUrl == null) return [];
      
      final url = "${dbUrl}orders.json";
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> orders = [];
        data.forEach((key, value) {
          if (value['customer'] != null && value['customer']['email'] == email) {
            Map<String, dynamic> order = Map<String, dynamic>.from(value);
            order['id'] = key; // Keep the firebase key as ID
            orders.add(order);
          }
        });
        
        // Sort by date descending
        orders.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));
        return orders;
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      return [];
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt();
    return calculatedAmount.toString();
  }
}
