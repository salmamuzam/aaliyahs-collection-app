import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favorites = [];
  final DatabaseService _dbService = DatabaseService();

  FavoriteProvider() {
    _loadFavorites();
  }

  List<Product> get favorites => _favorites;

  Future<void> _loadFavorites() async {
    final savedFavorites = await _dbService.getFavorites();
    _favorites.clear();
    _favorites.addAll(savedFavorites);
    notifyListeners();
  }

  Future<void> toggleFavorite(Product product) async {
    if (isExist(product)) {
      _favorites.removeWhere((p) => (product.id != null && p.id == product.id) || p.name == product.name);
      await _dbService.removeFavorite(product);
    } else {
      _favorites.add(product);
      await _dbService.addFavorite(product);
    }
    notifyListeners();
  }

  bool isExist(Product product) {
    return _favorites.any((p) => (product.id != null && p.id == product.id) || p.name == product.name);
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}
