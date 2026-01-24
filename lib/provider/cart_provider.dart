import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/utils/db_helper.dart';
import 'package:intl/intl.dart';

// Cart Functionality using Provider State Management Library
/// Manages the shopping cart state with local persistence and price calculations.
class CartProvider extends ChangeNotifier {
  final List<Product> _cart = [];

  /// List of products currently in the cart.
  List<Product> get cart => _cart;

  /// Loads cart items from the local database upon initialization.
  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final List<Product> items = await DBHelper().getCartItems();
      _cart.clear();
      _cart.addAll(items);
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
    notifyListeners();
  }

  /// Adds a product to the cart or increments its quantity if already present.
  void addToCart(Product product) {
    final int existingIndex = _cart.indexWhere((Product item) => item.name == product.name);

    if (existingIndex != -1) {
      _cart[existingIndex].quantity++;
      DBHelper().updateQuantity(product.name, _cart[existingIndex].quantity);
    } else {
      final Product newItem = Product(
        id: product.id,
        name: product.name,
        categoryName: product.categoryName,
        price: product.price,
        description: product.description,
        images: product.images,
        quantity: 1,
      );
      _cart.add(newItem);
      DBHelper().insert(newItem);
    }
    notifyListeners();
  }

  /// Removes a product from the cart at the specified index.
  void removeFromCart(int index) {
    if (index >= 0 && index < _cart.length) {
      DBHelper().delete(_cart[index].name);
      _cart.removeAt(index);
      notifyListeners();
    }
  }

  /// Increments the quantity of a product in the cart.
  void incrementQtn(int index) {
    _cart[index].quantity++;
    DBHelper().updateQuantity(_cart[index].name, _cart[index].quantity);
    notifyListeners();
  }

  /// Decrements the quantity of a product in the cart or removes it if quantity becomes zero.
  void decrementQtn(int index) {
    if (_cart[index].quantity > 1) {
      _cart[index].quantity--;
      DBHelper().updateQuantity(_cart[index].name, _cart[index].quantity);
    } else {
      removeFromCart(index);
    }
    notifyListeners();
  }

  /// Calculates the total price of all items in the cart.
  double totalPrice() {
    double total = 0.0;
    for (final Product element in _cart) {
      total += _parsePrice(element.price) * element.quantity;
    }
    return total;
  }

  /// Returns the total price as a professionally formatted string (e.g., Rs. 1,200.00).
  String get formattedTotalPrice {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'Rs. ',
      decimalDigits: 2,
    );
    return formatter.format(totalPrice());
  }

  /// Helper to clean and parse price strings into doubles.
  double _parsePrice(String price) {
    final String cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  /// Clears all products from the cart and local database.
  void clearCart() {
    DBHelper().clear();
    _cart.clear();
    notifyListeners();
  }

  /// Checks if the cart contains any items.
  bool get isCartEmpty => _cart.isEmpty;

  /// Helper to access CartProvider from the widget tree.
  static CartProvider of(BuildContext context, {bool listen = true}) => Provider.of<CartProvider>(context, listen: listen);
}
