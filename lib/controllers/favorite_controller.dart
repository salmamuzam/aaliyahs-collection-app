import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/util/local_storage/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================================================
// FAVORITE CONTROLLER - Manages User's Wishlist/Favorites
// ============================================================================
// This controller handles the user's favorite products (wishlist)
// It stores favorites in SQLite database for persistence
//
// Features:
// - Add/remove products from favorites
// - Check if product is favorited
// - Optimistic UI updates (instant feedback)
// - Automatic rollback on errors
// - Persist favorites (survives app restart)
//
// Used in:
// - Product cards (heart icon)
// - Favorites/Wishlist screen
// ============================================================================

class FavoriteController extends ChangeNotifier {
  final List<ProductModel> _favorites = [];  // Private list of favorited products
  final DBHelper _dbHelper = DBHelper();     // Database helper for SQLite

  // Constructor - automatically loads favorites when controller is created
  FavoriteController() {
    _loadFavorites();
  }

  // Public getter - other parts of app can read favorites but not modify directly
  List<ProductModel> get favorites => _favorites;

  // ============================================================================
  // LOAD FAVORITES - Restore Favorites from Database
  // ============================================================================
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
      debugPrint("Error loading favorites: $e");
    }
  }

  // ============================================================================
  // TOGGLE FAVORITE - Add or Remove Product from Favorites
  // ============================================================================
  // This uses "Optimistic UI Update" pattern:
  // 1. Update UI immediately (feels instant to user)
  // 2. Save to database in background
  // 3. If database save fails, rollback the UI change
  Future<void> toggleFavorite(ProductModel product) async {
    // Check if product is already in favorites
    final isAlreadyFavorite = isExists(product);
    
    // STEP 1: OPTIMISTIC UPDATE - Update UI immediately (before database)
    if (isAlreadyFavorite) {
      // Remove from favorites list
      _favorites.removeWhere((p) => (product.id != null && p.id == product.id) || p.name == product.name);
    } else {
      // Add to favorites list
      _favorites.add(product);
    }
    
    // Update UI immediately (user sees instant feedback)
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
        // Add back to favorites (we removed it earlier)
        _favorites.add(product);
      } else {
        // Remove from favorites (we added it earlier)
        _favorites.removeWhere((p) => (product.id != null && p.id == product.id) || p.name == product.name);
      }
      
      // Update UI to show rollback
      notifyListeners();
      debugPrint("Error toggling favorite: $e");
    }
  }

  // ============================================================================
  // CHECK IF EXISTS - Is Product Already Favorited?
  // ============================================================================
  // Returns true if product is in favorites, false otherwise
  // Used to show filled heart icon vs outline heart icon
  bool isExists(ProductModel product) => 
    _favorites.any((p) => (product.id != null && p.id == product.id) || p.name == product.name);

  // ============================================================================
  // HELPER METHOD - Access Controller from Widget
  // ============================================================================
  // Shortcut to get FavoriteController from any widget
  // Usage: FavoriteController.of(context).toggleFavorite(product)
  static FavoriteController of(BuildContext context, {bool listen = true}) => 
    Provider.of<FavoriteController>(context, listen: listen);
}
