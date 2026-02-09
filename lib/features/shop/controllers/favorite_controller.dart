import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/utils/local_storage/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// This controller handles the user's favorite products (wishlist)
// It stores favorites in SQLite database for persistence


class FavoriteController extends ChangeNotifier {
  final List<ProductModel> _favorites = [];  
  final DBHelper _dbHelper = DBHelper();     // Database helper for SQLite

  FavoriteController() {
    _loadFavorites();
  }


  List<ProductModel> get favorites => _favorites;


  // Called when app starts to restore previously saved favorites
  Future<void> _loadFavorites() async {
    try {
      // Get saved favorites from SQLite database
      final List<ProductModel> savedFavorites = await _dbHelper.getFavorites();
      
      // Clear current list and add saved favorites
      _favorites.clear();
      _favorites.addAll(savedFavorites);
      
      // Update UI with loaded favorites
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // ============================================================================
  // TOGGLE FAVORITE - Add or Remove Product from Favorites
  // ============================================================================

  Future<void> toggleFavorite(ProductModel product) async {
    // Check if product is already in favorites
    final isAlreadyFavorite = isExists(product);
    
    // Update UI immediately 
    if (isAlreadyFavorite) {
      // Remove from favorites list
      _favorites.removeWhere((p) => (product.id != null && p.id == product.id) || p.name == product.name);
    } else {
      // Add to favorites list
      _favorites.add(product);
    }
    
    // Update UI immediately 
    notifyListeners();

    // STEP 2: SAVE TO DATABASE
    try {
      if (isAlreadyFavorite) {
        // Remove from database
        await _dbHelper.deleteFavorite(product);
      } else {
        // Add to database
        await _dbHelper.insertFavorite(product);
      }
    } catch (e) {
      // STEP 3: ROLLBACK - If database save failed, undo the UI change
      if (isAlreadyFavorite) {
        // Add back to favorites 
        _favorites.add(product);
      } else {
        // Remove from favorites 
        _favorites.removeWhere((p) => (product.id != null && p.id == product.id) || p.name == product.name);
      }
      
      // Update UI to show rollback
      notifyListeners();
      debugPrint('Error toggling favorite: $e');
    }
  }


  // Returns true if product is in favorites, false otherwise
  // Used to show filled heart icon vs outline heart icon
  bool isExists(ProductModel product) => 
    _favorites.any((p) => (product.id != null && p.id == product.id) || p.name == product.name);

  // Clear all favorites (used on logout)
  Future<void> clearFavorites() async {
    _favorites.clear();
    notifyListeners();
  }

  static FavoriteController of(BuildContext context, {bool listen = true}) => 
    Provider.of<FavoriteController>(context, listen: listen);
}
