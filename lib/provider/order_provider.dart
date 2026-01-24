import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchUserOrders(String email) async {
    _isLoading = true;
    notifyListeners();
    
    _orders = await _orderService.getOrders(email);
    
    _isLoading = false;
    notifyListeners();
  }
}
