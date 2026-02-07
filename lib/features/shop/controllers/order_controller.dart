import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/data/repositories/order_repository.dart';

// ============================================================================
// ORDER CONTROLLER - Manages User's Order History
// ============================================================================
// This controller handles fetching and displaying user's past orders
// It communicates with the Laravel API to get order data
//
// Features:
// - Fetch user's order history
// - Loading state management
// - Display orders in order history screen
//
// Used in:
// - Order History screen
// - Profile section
// ============================================================================

class OrderController extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();  // Handles API calls
  List<Map<String, dynamic>> _orders = [];  // Private list of orders
  bool _isLoading = false;                   // Tracks if orders are being fetched
  String? _selectedOrderId;                  // Currently selected order (for list-detail pattern)

  // Public getters - other parts of app can read but not modify directly
  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get selectedOrderId => _selectedOrderId;

  // ============================================================================
  // SELECT ORDER - For List-Detail Pattern
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

  // ============================================================================
  // FETCH USER ORDERS - Get Order History from API
  // ============================================================================
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
      // If API call fails, keep existing orders (or empty list)
      debugPrint('Error fetching orders: $e');
    } finally {
      // STEP 3: Stop loading (whether success or error)
      _isLoading = false;
      notifyListeners();  // Update UI to hide loading spinner and show orders
    }
  }
}
