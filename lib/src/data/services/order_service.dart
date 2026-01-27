import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Service managing Order placement via Stripe and Firebase Realtime Database.
/// Optimized using Firebase Best Practices: Timestamp sorting, Parameterized queries, and Flattening.
class OrderService {
  final Dio _dio = Dio();
  
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

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
         onError(e.error.localizedMessage ?? "Payment Failed");
      } else {
         onError(e.toString());
      }
    }
  }

  /// Store Order in Firebase Realtime Database.
  /// Optimization: Dates stored as Milliseconds (timestamps) for efficient sorting.
  Future<String?> storeOrderInFirebase({
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final dbUrl = dotenv.env['FIREBASE_DB_URL'];
      if (dbUrl == null) {
        debugPrint("Firebase DB URL not found in .env");
        return null;
      }
      final url = "${dbUrl}orders.json";
      
      // Ensure date is numeric for sorting as per Firebase Best Practices
      if (orderData['date'] is String) {
        try {
          orderData['timestamp'] = DateTime.parse(orderData['date']).millisecondsSinceEpoch;
        } catch (_) {
          orderData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        }
      } else {
        orderData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      }

      final response = await _dio.post(
        url,
        data: orderData,
      );
      
      if (response.statusCode == 200) {
        debugPrint("Order stored in Firebase: ${response.data['name']}");
        return response.data['name'];
      }
      return null;
    } catch (e) {
      debugPrint("Failed to store order in Firebase: $e");
      return null;
    }
  }

  /// Fetch orders from Firebase Realtime Database.
  /// Optimization: Server-side filtering using 'orderBy' and 'equalTo' to reduce bandwidth.
  Future<List<Map<String, dynamic>>> getOrders(String email) async {
    try {
      final dbUrl = dotenv.env['FIREBASE_DB_URL'];
      if (dbUrl == null) return [];
      
      // OPTIMIZATION: Use server-side filtering via REST API
      // Note: Requires ".indexOn": ["customer/email"] in Firebase Rules
      final String url = "${dbUrl}orders.json";
      final response = await _dio.get(
        url,
        queryParameters: {
          'orderBy': '"customer/email"',
          'equalTo': '"$email"',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = response.data;
        if (data == null) return [];

        List<Map<String, dynamic>> orders = [];
        data.forEach((key, value) {
          Map<String, dynamic> order = Map<String, dynamic>.from(value);
          order['id'] = key;
          orders.add(order);
        });
        
        // Final descending sort by timestamp in-memory
        orders.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
        return orders;
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      // Fallback to client-side filtering if index is missing (legacy support)
      return _getOrdersLegacy(email);
    }
  }

  /// Legacy fallback for client-side filtering (Avoid using for large datasets).
  Future<List<Map<String, dynamic>>> _getOrdersLegacy(String email) async {
    try {
      final dbUrl = dotenv.env['FIREBASE_DB_URL'];
      if (dbUrl == null) return [];
      final response = await _dio.get("${dbUrl}orders.json");
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data;
        List<Map<String, dynamic>> orders = [];
        data.forEach((key, value) {
          if (value['customer'] != null && value['customer']['email'] == email) {
            Map<String, dynamic> order = Map<String, dynamic>.from(value);
            order['id'] = key;
            orders.add(order);
          }
        });
        orders.sort((a, b) => (b['timestamp'] ?? b['date'] ?? '').toString().compareTo((a['timestamp'] ?? a['date'] ?? '').toString()));
        return orders;
      }
    } catch (_) {}
    return [];
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt();
    return calculatedAmount.toString();
  }
}
