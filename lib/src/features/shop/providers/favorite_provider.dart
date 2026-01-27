import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/utils/local_storage/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Manages the user's favorite products (wishlist) with local sqflite persistence.
class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favorites = [];
  final DBHelper _dbHelper = DBHelper();

  /// Loads initial favorites from the database.
  FavoriteProvider() {
    _loadFavorites();
  }

  /// List of currently favorited products.
  List<Product> get favorites => _favorites;

  Future<void> _loadFavorites() async {
    try {
      final List<Product> savedFavorites = await _dbHelper.getFavorites();
      _favorites.clear();
      _favorites.addAll(savedFavorites);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    }
  }

  /// Toggles the favorite status of a product with optimistic UI updates.
  Future<void> toggleFavorite(Product product) async {
    // OPTIMISTIC UPDATE: Update UI immediately
    final isAlreadyFavorite = isExists(product);
    
    if (isAlreadyFavorite) {
      _favorites.removeWhere((Product p) => (product.id != null && p.id == product.id) || p.name == product.name);
    } else {
      _favorites.add(product);
    }
    notifyListeners();

    try {
      if (isAlreadyFavorite) {
        await _dbHelper.deleteFavorite(product);
      } else {
        await _dbHelper.insertFavorite(product);
      }
    } catch (e) {
      // ROLLBACK on error
      if (isAlreadyFavorite) {
        _favorites.add(product);
      } else {
        _favorites.removeWhere((Product p) => (product.id != null && p.id == product.id) || p.name == product.name);
      }
      notifyListeners();
      debugPrint("Error toggling favorite: $e");
    }
  }

  /// Checks if a product exists in the favorites list.
  bool isExists(Product product) => _favorites.any((Product p) => (product.id != null && p.id == product.id) || p.name == product.name);

  /// Helper to access FavoriteProvider from the widget tree.
  static FavoriteProvider of(BuildContext context, {bool listen = true}) => Provider.of<FavoriteProvider>(context, listen: listen);
}
