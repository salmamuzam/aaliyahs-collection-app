import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/category.dart';
import 'package:aaliyahs_collection_estore/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _bestSellingProducts = [];
  List<Product> _shopProducts = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  String _errorMessage = '';

  List<Product> get bestSellingProducts => _bestSellingProducts;
  List<Product> get shopProducts => _shopProducts;
  List<Category> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchHomeData({String? token}) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      // Fetch both simultaneously
      final results = await Future.wait([
        _productService.getBestSellingProducts(token: token),
        _productService.getCategories(),
      ]);

      final productsResult = results[0];
      final categoriesResult = results[1];

      if (categoriesResult['status'] == 'success') {
        List<dynamic> data = categoriesResult['data'];
        _categories = data.map((json) => Category.fromJson(json)).toList();
        debugPrint("Loaded ${_categories.length} Categories");
      }

      if (productsResult['status'] == 'success') {
        List<dynamic> data = productsResult['data'];
        _bestSellingProducts = data.map((json) => Product.fromJson(json)).toList();
        debugPrint("Loaded ${_bestSellingProducts.length} Best Selling Products");
      } else {
        debugPrint("Best Selling API failed (Status: ${productsResult['statusCode']}). Attempting fallback...");
        // Fallback: If best-selling fails, try to fetch some products as fallback
        await _fetchBestSellingFallback();
      }

      if (categoriesResult['status'] == 'error' && _bestSellingProducts.isEmpty) {
        _errorMessage = "Failed to load data from server.";
      }
      
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error in fetchHomeData: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Fallback to fetch some products if Best Selling endpoint crashes
  Future<void> _fetchBestSellingFallback() async {
    try {
      // Try to get products from the first category as a fallback for the home page
      if (_categories.isNotEmpty) {
        final result = await _productService.getShopProducts(categoryId: _categories.first.id, page: 1);
        if (result['status'] == 'success') {
          List<dynamic> data = result['data'];
          _bestSellingProducts = data.map((json) => Product.fromJson(json)).take(4).toList();
          debugPrint("Fallback: Loaded ${_bestSellingProducts.length} products from Category ${_categories.first.name} for Best Sellers");
        }
      }
    } catch (e) {
      debugPrint("Best Selling Fallback failed: $e");
    }
  }

  Future<void> fetchShopProducts({int? categoryId}) async {
    _setLoading(true);
    _errorMessage = '';
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    _hasMore = true;
    _shopProducts = []; // Clear current products
    
    try {
      if (categoryId == null) {
        // --- CASE: Shop All ---
        debugPrint("Attempting to fetch ALL products via individual categories...");
        
        List<Product> allProducts = [];
        for (var category in _categories) {
          int page = 1;
          bool hasMoreData = true;
          
          while (hasMoreData) {
            debugPrint(">>> AUTO-FETCH: Cat ${category.name}, Page $page");
            final result = await _productService.getShopProducts(categoryId: category.id, page: page);
            
            if (result['status'] == 'success') {
              List<dynamic> data = result['data'];
              final List<Product> pageProducts = data.map((json) => Product.fromJson(json)).toList();
              
              if (pageProducts.isEmpty) {
                debugPrint(">>> End of data reached for category ${category.name} at page $page");
                hasMoreData = false;
                break;
              }

              allProducts.addAll(pageProducts);
              _shopProducts = List.from(allProducts); // Update UI
              notifyListeners();
              
              page++; // Always try the next page
            } else {
              debugPrint("Failed to fetch category ${category.name}, skipping...");
              hasMoreData = false;
            }
          }
        }
        _hasMore = false; 
      } else {
        // --- CASE: Specific Category ---
        int page = 1;
        bool hasMoreData = true;
        while (hasMoreData) {
          debugPrint(">>> AUTO-FETCH: Category $categoryId, Page $page");
          final result = await _productService.getShopProducts(categoryId: categoryId, page: page);
          
          if (result['status'] == 'success') {
            List<dynamic> data = result['data'];
            final List<Product> pageProducts = data.map((json) => Product.fromJson(json)).toList();
            
            if (pageProducts.isEmpty) {
              debugPrint(">>> End of data reached for category $categoryId at page $page");
              hasMoreData = false;
              break;
            }

            _shopProducts.addAll(pageProducts);
            notifyListeners();
            page++;
          } else {
            _errorMessage = result['message'];
            hasMoreData = false;
            notifyListeners();
          }
        }
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Exception in fetchShopProducts: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreShopProducts() async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();
    
    _currentPage++;
    
    try {
      final result = await _productService.getShopProducts(categoryId: _selectedCategoryId, page: _currentPage);
      if (result['status'] == 'success') {
        List<dynamic> data = result['data'];
        final newProducts = data.map((json) => Product.fromJson(json)).toList();
        _shopProducts.addAll(newProducts);
        
        if (result['meta'] != null) {
          _hasMore = result['meta']['current_page'] < result['meta']['last_page'];
        } else {
          _hasMore = false;
        }
        
        debugPrint("Loaded ${newProducts.length} more Shop Products (Page $_currentPage). Has more: $_hasMore");
      }
    } catch (e) {
      debugPrint("Error loading more products: $e");
      _currentPage--; // Revert page on error
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchBestSellingProducts({String? token}) async {
    // Keep for backward compatibility
    await fetchHomeData(token: token);
  }
}
