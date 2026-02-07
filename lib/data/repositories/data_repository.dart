import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/cart_item.dart';

/// Service for reading/writing to the local file system (Requirement 3: Local Data Source).
class DataRepository {
  
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _recentlyViewedFile async {
    final path = await _localPath;
    return File('$path/recently_viewed.json');
  }

  Future<File> get _notesFile async {
    final path = await _localPath;
    return File('$path/product_notes.json');
  }

  Future<File> get _cartFile async {
    final path = await _localPath;
    return File('$path/cart.json');
  }


  /// Writes a list of product IDs to local storage.
  Future<void> saveRecentlyViewed(List<int> productIds) async {
    try {
      final file = await _recentlyViewedFile;
      await file.writeAsString(jsonEncode(productIds));
    } catch (e) {
      debugPrint('Error writing to local storage: $e');
    }
  }

  /// Reads product IDs from local storage.
  Future<List<int>> getRecentlyViewed() async {
    try {
      final file = await _recentlyViewedFile;
      if (file.existsSync()) {
        final content = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(content);
        return List<int>.from(decoded);
      }
      return [];
    } catch (e) {
      debugPrint('Error reading from local storage: $e');
      return [];
    }
  }

  /// Requirement 3: Write data to Local Data Source
  Future<void> saveProductNote(int productId, String note) async {
    try {
      final file = await _notesFile;
      Map<String, String> notes = {};
      if (file.existsSync()) {
        notes = Map<String, String>.from(jsonDecode(await file.readAsString()));
      }
      notes[productId.toString()] = note;
      await file.writeAsString(jsonEncode(notes));
    } catch (e) {
      debugPrint('Error saving note: $e');
    }
  }

  /// Requirement 3: Read data from Local Data Source
  Future<String> getProductNote(int productId) async {
    try {
      final file = await _notesFile;
      if (file.existsSync()) {
        final Map<String, dynamic> notes = jsonDecode(await file.readAsString());
        return notes[productId.toString()] ?? '';
      }
    } catch (_) {}
    return '';
  }

  // ============================================================================
  // CART MANAGEMENT METHODS
  // ============================================================================

  /// Get all cart items from local storage
  Future<List<CartItem>> getCart() async {
    try {
      final file = await _cartFile;
      if (file.existsSync()) {
        final content = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(content);
        return decoded.map((json) => CartItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error reading cart from local storage: $e');
      return [];
    }
  }

  /// Add item to cart
  Future<void> addToCart(CartItem item) async {
    try {
      final cart = await getCart();
      cart.add(item);
      final file = await _cartFile;
      await file.writeAsString(jsonEncode(cart.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  /// Remove item from cart by product ID
  Future<void> removeFromCart(int productId) async {
    try {
      final cart = await getCart();
      cart.removeWhere((item) => item.id == productId);
      final file = await _cartFile;
      await file.writeAsString(jsonEncode(cart.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItemQuantity(int productId, int quantity) async {
    try {
      final cart = await getCart();
      final index = cart.indexWhere((item) => item.id == productId);
      if (index != -1) {
        cart[index].quantity = quantity;
        final file = await _cartFile;
        await file.writeAsString(jsonEncode(cart.map((e) => e.toJson()).toList()));
      }
    } catch (e) {
      debugPrint('Error updating cart quantity: $e');
    }
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    try {
      final file = await _cartFile;
      await file.writeAsString(jsonEncode([]));
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}

