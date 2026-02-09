import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/data/repositories/order_repository.dart';


// This controller handles fetching and displaying user's past orders
// It communicates with the Laravel API to get order data


class OrderController extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();  // Handles API calls
  List<Map<String, dynamic>> _orders = [];  // Private list of orders
  bool _isLoading = false;                   // Tracks if orders are being fetched
  String? _selectedOrderId;                  // Currently selected order 

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get selectedOrderId => _selectedOrderId;

  // ============================================================================
  // SELECT ORDER 
  // ============================================================================
  void selectOrder(String? orderId) {
    _selectedOrderId = orderId;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedOrderId = null;
    notifyListeners();
  }


  // Fetches all orders for a specific user from the Laravel backend
  // Shows loading indicator while fetching
  Future<void> fetchUserOrders(String email) async {
    // STEP 1: Start loading
    _isLoading = true;
    notifyListeners();  // Update UI to show loading spinner
    
    try {
      // STEP 2: Fetch orders from API
      _orders = await _orderRepository.getOrders(email);
      
      // Orders are sorted by newest first in the repository
      // Each order contains: order ID, items, total, status, date, etc.
    } catch (e) {
      // If API call fails, keep existing orders 
      debugPrint('Error fetching orders: $e');
    } finally {
      // STEP 3: Stop loading 
      _isLoading = false;
      notifyListeners();  // Update UI to hide loading spinner and show orders
    }
  }

  // Clear all orders 
  void clearOrders() {
    _orders = [];
    notifyListeners();
  }
}
