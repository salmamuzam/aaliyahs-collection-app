import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Manages the user's favorite products (wishlist) with local database persistence.
class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favorites = [];
  final DatabaseService _dbService = DatabaseService();

  /// Loads initial favorites from the database.
  FavoriteProvider() {
    _loadFavorites();
  }

  /// List of currently favorited products.
  List<Product> get favorites => _favorites;

  Future<void> _loadFavorites() async {
    final List<Product> savedFavorites = await _dbService.getFavorites();
    _favorites.clear();
    _favorites.addAll(savedFavorites);
    notifyListeners();
  }

  /// Toggles the favorite status of a product with optimistic UI updates.
  Future<void> toggleFavorite(Product product) async {
    // OPTIMISTIC UPDATE: Update UI immediately before waiting for DB
    if (isExists(product)) {
      _favorites.removeWhere((Product p) => (product.id != null && p.id == product.id) || p.name == product.name);
      notifyListeners();
      try {
        await _dbService.removeFavorite(product);
      } catch (e) {
        _favorites.add(product);
        notifyListeners();
        debugPrint("Error removing favorite: $e");
      }
    } else {
      _favorites.add(product);
      notifyListeners();
      try {
        await _dbService.addFavorite(product);
      } catch (e) {
        _favorites.removeWhere((Product p) => (product.id != null && p.id == product.id) || p.name == product.name);
        notifyListeners();
        debugPrint("Error adding favorite: $e");
      }
    }
  }

  /// Checks if a product exists in the favorites list.
  bool isExists(Product product) => _favorites.any((Product p) => (product.id != null && p.id == product.id) || p.name == product.name);

  /// Helper to access FavoriteProvider from the widget tree.
  static FavoriteProvider of(BuildContext context, {bool listen = true}) => Provider.of<FavoriteProvider>(context, listen: listen);
}
