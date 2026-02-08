import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/cart_item.dart';
import 'package:aaliyahs_collection_estore/utils/local_storage/db_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// ============================================================================
// CART CONTROLLER - Manages Shopping Cart State
// ============================================================================
// This controller handles all shopping cart operations using Provider pattern
// It stores cart items in SQLite database for persistence
//
// Features:
// - Add products to cart
// - Remove products from cart
// - Increase/decrease quantity
// - Calculate total price
// - Clear entire cart
// - Persist cart data (survives app restart)
// ============================================================================

class CartController extends ChangeNotifier {
  // Private list of cart items (only this controller can modify)
  List<CartItem> _cart = [];
  
  // Database helper for saving/loading cart
  final DBHelper _dbHelper = DBHelper();
  
  // Selection logic for bulk actions (Requirement: MD3 Checkbox Usage)
  final Set<int> _selectedItemIds = {};

  // Public getter - other parts of app can read cart but not modify directly
  List<CartItem> get cart => _cart;

  // Get total number of items in cart
  int get itemCount => _cart.length;

  // Check if cart is empty
  bool get isCartEmpty => _cart.isEmpty;

  // Selection Getters
  Set<int> get selectedItemIds => _selectedItemIds;
  bool? get allSelectedState {
    if (_cart.isEmpty) return false;
    if (_selectedItemIds.isEmpty) return false;
    if (_selectedItemIds.length == _cart.length) return true;
    return null; // Indeterminate
  }

  // Constructor - automatically loads cart when controller is created
  CartController() {
    loadCart();
  }

  // ============================================================================
  // LOAD CART - Restore Cart from Database
  // ============================================================================
  // Called when app starts to restore previously saved cart items
  Future<void> loadCart() async {
    try {
      _cart = await _dbHelper.getCartItems();  // Get saved cart from SQLite
      notifyListeners();  // Tell UI to update with loaded data
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // ============================================================================
  // ADD TO CART - Add Product or Increase Quantity
  // ============================================================================
  Future<void> addToCart(ProductModel product) async {
    try {
      // Check if product already exists in cart
      final int existingIndex = _cart.indexWhere((item) => item.id == product.id);

      if (existingIndex != -1) {
        // Product already in cart - just increase quantity
        _cart[existingIndex].quantity++;
        await _dbHelper.updateCartQuantity(
          _cart[existingIndex].id, 
          _cart[existingIndex].quantity
        );
      } else {
        // New product - add to cart with quantity 1
        final CartItem newItem = CartItem(
          id: product.id ?? 0,
          name: product.name,
          price: product.priceDouble,
          image: product.image,
          categoryName: product.categoryName,
          description: product.description,
        );
        _cart.add(newItem);
        await _dbHelper.insertCart(newItem);
      }
      
      // Update UI to show new cart count
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  // ============================================================================
  // REMOVE FROM CART - Delete Item
  // ============================================================================
  Future<void> removeFromCart(int index) async {
    try {
      // Validate index is within range
      if (index >= 0 && index < _cart.length) {
        final int itemId = _cart[index].id;
        
        // Remove from database
        await _dbHelper.deleteFromCart(itemId);
        
        // Remove from local list
        _cart.removeAt(index);
        
        // Update UI
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  // ============================================================================
  // INCREMENT QUANTITY - Increase Item Count
  // ============================================================================
  Future<void> incrementQtn(int index) async {
    try {
      // Increase quantity by 1
      _cart[index].quantity++;
      
      // Save to database
      await _dbHelper.updateCartQuantity(
        _cart[index].id, 
        _cart[index].quantity
      );
      
      // Update UI to show new quantity and total price
      notifyListeners();
    } catch (e) {
      debugPrint('Error incrementing quantity: $e');
    }
  }

  // ============================================================================
  // DECREMENT QUANTITY - Decrease Item Count or Remove
  // ============================================================================
  Future<void> decrementQtn(int index) async {
    try {
      if (_cart[index].quantity > 1) {
        // Decrease quantity by 1
        _cart[index].quantity--;
        
        // Save to database
        await _dbHelper.updateCartQuantity(
          _cart[index].id, 
          _cart[index].quantity
        );
      } else {
        // Quantity is 1, so remove item completely
        await removeFromCart(index);
      }
      
      // Update UI
      notifyListeners();
    } catch (e) {
      debugPrint('Error decrementing quantity: $e');
    }
  }

  // ============================================================================
  // CALCULATE TOTAL PRICE - Sum of All Items
  // ============================================================================
  double totalPrice() {
    double total = 0.0;
    
    // Loop through all cart items and add up (price × quantity)
    for (final CartItem item in _cart) {
      total += item.price * item.quantity;
    }
    
    return total;
  }

  // ============================================================================
  // FORMATTED TOTAL PRICE - Display-Ready Price String
  // ============================================================================
  // Returns price in format: "LKR 1,234.56"
  String get formattedTotalPrice {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_LK',      // Sri Lankan locale
      symbol: 'LKR ',       // Currency symbol
      decimalDigits: 2,     // Show 2 decimal places
    );
    return formatter.format(totalPrice());
  }


  // ============================================================================
  // CLEAR CART - Remove All Items
  // ============================================================================
  // Used after successful checkout
  Future<void> clearCart() async {
    try {
      // Clear from database
      await _dbHelper.clearCart();
      
      // Clear local list
      _cart.clear();
      _selectedItemIds.clear(); // Reset selection
      
      // Update UI to show empty cart
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }

  // Selection Methods
  void toggleItemSelection(int itemId) {
    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
    } else {
      _selectedItemIds.add(itemId);
    }
    notifyListeners();
  }

  void toggleAll(bool? selected) {
    if (selected == true) {
      _selectedItemIds.clear();
      for (var item in _cart) {
        _selectedItemIds.add(item.id);
      }
    } else {
      _selectedItemIds.clear();
    }
    notifyListeners();
  }

  Future<void> removeSelected() async {
    final List<int> idsToRemove = _selectedItemIds.toList();
    for (int id in idsToRemove) {
      final int index = _cart.indexWhere((item) => item.id == id);
      if (index != -1) await removeFromCart(index);
    }
    _selectedItemIds.clear();
  }

  // ============================================================================
  // HELPER METHOD - Access Controller from Widget
  // ============================================================================
  // Shortcut to get CartController from any widget
  // Usage: CartController.of(context).addToCart(product)
  static CartController of(BuildContext context, {bool listen = true}) => 
    Provider.of<CartController>(context, listen: listen);
}
