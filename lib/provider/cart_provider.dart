import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Cart Functionality using Provider State Management Library
class CartProvider extends ChangeNotifier {
  final List<Product> _cart = [];
  List<Product> get cart => _cart;

  void toggleFavorite(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.name == product.name);

    if (existingIndex != -1) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(
        Product(
          name: product.name,
          category: product.category,
          price: product.price,
          description: product.description,
          image: product.image,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // Remove product from cart

  void removeFromCart(int index) {
    _cart.removeAt(index);
    notifyListeners();
  }

// Increase the product quantity 

  incrementQtn(int index) {
    _cart[index].quantity++;
    notifyListeners();
  }

// Decrease the product quantity

  decrementQtn(int index) {
    if (_cart[index].quantity > 1) {
      _cart[index].quantity--;
    } else {
      removeFromCart(index);
    }
    notifyListeners();
  }

// Calculate the total price by multiplying price one product by quantity

  totalPrice() {
    double total1 = 0.0;
    for (Product element in _cart) {
      total1 += element.price * element.quantity;
    }
    return total1;
  }

// Clear products from the cart 

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  bool get isCartEmpty => _cart.isEmpty;

  static CartProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<CartProvider>(context, listen: listen);
  }
}
