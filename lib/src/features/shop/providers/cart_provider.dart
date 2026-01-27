import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/utils/local_storage/db_helper.dart';
import 'package:intl/intl.dart';

/// Manages the shopping cart state with local sqflite persistence.
class CartProvider extends ChangeNotifier {
  final List<Product> _cart = [];
  final DBHelper _dbHelper = DBHelper();

  /// List of products currently in the cart.
  List<Product> get cart => _cart;

  /// Loads cart items from the local database upon initialization.
  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final List<Product> items = await _dbHelper.getCartItems();
      _cart.clear();
      _cart.addAll(items);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }

  /// Adds a product to the cart or increments its quantity if already present.
  Future<void> addToCart(Product product) async {
    final int existingIndex = _cart.indexWhere((Product item) => item.name == product.name);

    if (existingIndex != -1) {
      _cart[existingIndex].quantity++;
      await _dbHelper.updateCartQuantity(product.name, _cart[existingIndex].quantity);
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
      await _dbHelper.insertCart(newItem);
    }
    notifyListeners();
  }

  /// Removes a product from the cart at the specified index.
  Future<void> removeFromCart(int index) async {
    if (index >= 0 && index < _cart.length) {
      await _dbHelper.deleteFromCart(_cart[index].name);
      _cart.removeAt(index);
      notifyListeners();
    }
  }

  /// Increments the quantity of a product in the cart.
  Future<void> incrementQtn(int index) async {
    _cart[index].quantity++;
    await _dbHelper.updateCartQuantity(_cart[index].name, _cart[index].quantity);
    notifyListeners();
  }

  /// Decrements the quantity of a product in the cart or removes it if quantity becomes zero.
  Future<void> decrementQtn(int index) async {
    if (_cart[index].quantity > 1) {
      _cart[index].quantity--;
      await _dbHelper.updateCartQuantity(_cart[index].name, _cart[index].quantity);
    } else {
      await removeFromCart(index);
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

  /// Returns the total price as a professionally formatted string.
  String get formattedTotalPrice {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'LKR ',
      decimalDigits: 2,
    );
    return formatter.format(totalPrice());
  }

  double _parsePrice(String price) {
    final String cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  /// Clears all products from the cart and local database.
  Future<void> clearCart() async {
    await _dbHelper.clearCart();
    _cart.clear();
    notifyListeners();
  }

  bool get isCartEmpty => _cart.isEmpty;

  static CartProvider of(BuildContext context, {bool listen = true}) => Provider.of<CartProvider>(context, listen: listen);
}
