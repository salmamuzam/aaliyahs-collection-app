import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/category.dart';
import 'package:aaliyahs_collection_estore/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Manages product catalog, categories, search, sorting and best-seller logic.
class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _latestProducts = [];
  List<Product> _featuredProducts = [];
  List<Product> _bestSellingProducts = [];
  List<Product> _shopProducts = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _sortOption = 'Newest'; 

  /// List of products displayed on the home screen as best sellers.
  List<Product> get bestSellingProducts => _bestSellingProducts;

  /// List of latest products.
  List<Product> get latestProducts => _latestProducts;

  /// List of featured products.
  List<Product> get featuredProducts => _featuredProducts;
  
  /// List of products available in the shop/category view.
  List<Product> get shopProducts => _shopProducts;
  
  /// All available product categories.
  List<Category> get categories => _categories;
  
  /// The ID of the currently selected category (null for 'All').
  int? get selectedCategoryId => _selectedCategoryId;
  
  /// Indicates if initial data loading is in progress.
  bool get isLoading => _isLoading;
  
  /// Indicates if more products are being fetched during pagination.
  bool get isFetchingMore => _isFetchingMore;
  
  /// Flag to determine if more products exist for the current view.
  bool get hasMore => _hasMore;
  
  /// The most recent error message from a data operation.
  String get errorMessage => _errorMessage;
  
  /// The active search term used for filtering products.
  String get searchQuery => _searchQuery;
  
  /// The current sorting criteria applied to the product list.
  String get sortOption => _sortOption;

  /// Updates the search query and refreshes the filtered view.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Updates the sort criteria and refreshes the view.
  void setSortOption(String option) {
    if (_sortOption != option) {
      _sortOption = option;
      // Reload shop products with new sort option
      fetchShopProducts(categoryId: _selectedCategoryId); 
    }
  }

  /// Returns a filtered version of shop products (Search is local, Sorting is Server-side now)
  List<Product> get filteredShopProducts {
    final List<Product> products = List<Product>.from(_shopProducts);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      products.retainWhere((Product p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()));
    }
    
    // NOTE: Sorting is now handled by the API, so we don't sort locally unless necessary.
    // However, for consistency in case of mixed local data or search, we can keep local sort enabled 
    // IF the API didn't already sort it. But since we clear list on sort change, API sort is primary.
    // We will trust the API order.

    return products;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetches essential data for the home screen, including categories and best sellers.
  Future<void> fetchHomeData({String? token}) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      // 1. Try to fetch from Firebase first (Offline/Realtime cache)
      await _fetchBestSellersFromFirebase();
      
      // 2. Fetch Home Data from Laravel API (Categories + Featured/Latest Products)
      final List<dynamic> results = await Future.wait([
         _productService.getHomeData(),
         _productService.getBestSellingProducts(token: token) // Explicitly calling correct endpoint now
      ]);
      
      final Map<String, dynamic> homeResult = results[0];
      final Map<String, dynamic> bestSellingResult = results[1];

      // Parse Categories, Latest and Featured from Home Data
      if (homeResult['status'] == 'success') {
        final Map<String, dynamic> data = homeResult['data'];
        
        // Categories
        if (data['categories'] != null) {
          final List<dynamic> cats = data['categories'];
          _categories = cats.map((dynamic json) => Category.fromJson(json)).toList();
        }

        // Latest Products
        if (data['latest_products'] != null) {
          final List<dynamic> latest = data['latest_products'];
          _latestProducts = latest.map((dynamic json) => Product.fromJson(json)).toList();
        }

        // Featured Products
        if (data['featured_products'] != null) {
          final List<dynamic> featured = data['featured_products'];
          _featuredProducts = featured.map((dynamic json) => Product.fromJson(json)).toList();
        }

        // Best Sellers from home data if available
        if (data['best_sellers'] != null) {
          final List<dynamic> best = data['best_sellers'];
          _bestSellingProducts = best.map((dynamic json) => Product.fromJson(json)).toList();
        }
      }

      // Parse Best Sellers from dedicated endpoint (Priority)
      if (bestSellingResult['status'] == 'success') {
         final List<dynamic> data = bestSellingResult['data'];
         final List<Product> bestSellers = data.map((dynamic json) => Product.fromJson(json)).toList();
         if (bestSellers.isNotEmpty) {
           _bestSellingProducts = bestSellers.take(4).toList();
         }
      } 
      
      // Fallback: If best selling products are still empty (e.g. endpoint failed or returned empty)
      if (_bestSellingProducts.isEmpty) {
        if (_featuredProducts.isNotEmpty) {
          _bestSellingProducts = _featuredProducts.take(4).toList();
        } else if (_latestProducts.isNotEmpty) {
          _bestSellingProducts = _latestProducts.take(4).toList();
        }
      }

      // 3. Fallback logic: Ensure categories are loaded if home API failed to provide them
      if (_categories.isEmpty) {
           debugPrint("Home data missing categories, fetching from dedicated endpoint...");
           final Map<String, dynamic> cats = await _productService.getCategories();
           if (cats['status'] == 'success') {
               _categories = (cats['data'] as List).map((e) => Category.fromJson(e)).toList();
           }
      }

      // 4. Fallback logic for best sellers if missing
      if (_bestSellingProducts.isEmpty && _categories.isNotEmpty) {
           await _fetchBestSellingFallback();
      }

      // 5. Enrich Best Sellers with full details from other loaded products (Latest/Featured)
      // This fixes the issue where Firebase/Order-derived best sellers lack descriptions.
      if (_bestSellingProducts.isNotEmpty && (_latestProducts.isNotEmpty || _featuredProducts.isNotEmpty)) {
         final Map<int, Product> fullProductMap = {};
         for (var p in _latestProducts) fullProductMap[p.id] = p;
         for (var p in _featuredProducts) fullProductMap[p.id] = p;
         
         for (int i = 0; i < _bestSellingProducts.length; i++) {
            final bp = _bestSellingProducts[i];
            // If description is generic/missing and we have a full version, replace it
            if ((bp.description == 'Best Seller' || bp.description.isEmpty) && fullProductMap.containsKey(bp.id)) {
               _bestSellingProducts[i] = fullProductMap[bp.id]!;
            }
         }
      }
      
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error in fetchHomeData: $e");
    } finally {
      _setLoading(false);
    }
  }
  
  // ... (Firebase fetch remains same)

  // ... (Fallback remains same)

  /// Fetches products for the shop view, filtered by category if provided.
  Future<void> fetchShopProducts({int? categoryId}) async {
    _setLoading(true);
    _errorMessage = '';
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    _hasMore = true;
    _shopProducts = []; 
    
    try {
      // Simplified Logic: Just call getShopProducts. 
      // If categoryId is null, API returns all shop items.
      // We pass the current sort option.
      
      final Map<String, dynamic> result = await _productService.getShopProducts(
          categoryId: categoryId, 
          page: _currentPage,
          sort: _sortOption
      );
      
      if (result['status'] == 'success') {
        final List<dynamic> data = result['data'];
        _shopProducts = data.map((dynamic json) => Product.fromJson(json)).toList();
        
        // Handle Pagination Meta
        if (result['meta'] != null) {
          _hasMore = result['meta']['current_page'] < result['meta']['last_page'];
        } else {
           _hasMore = false;
        }
      } else {
        _errorMessage = result['message'] ?? 'Failed to load shop products';
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Exception in fetchShopProducts: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches all best selling products into the shop view.
  Future<void> fetchAllBestSellingProducts({String? token}) async {
    _setLoading(true);
    _errorMessage = '';
    _selectedCategoryId = null; // Reset category filter
    _currentPage = 1;
    _hasMore = false; // Dedicated endpoint usually doesn't have pagination meta in same way
    _shopProducts = [];
    
    try {
      final Map<String, dynamic> result = await _productService.getBestSellingProducts(token: token);
      
      if (result['status'] == 'success') {
        final List<dynamic> data = result['data'];
        _shopProducts = data.map((dynamic json) => Product.fromJson(json)).toList();
      } else {
        _errorMessage = result['message'] ?? 'Failed to load best selling products';
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Exception in fetchAllBestSellingProducts: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Loads the next page of products
  Future<void> loadMoreShopProducts() async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();
    
    _currentPage++;
    
    try {
      final Map<String, dynamic> result = await _productService.getShopProducts(
          categoryId: _selectedCategoryId, 
          page: _currentPage,
          sort: _sortOption
      );
      
      if (result['status'] == 'success') {
        final List<dynamic> data = result['data'];
        final List<Product> newProducts = data.map((dynamic json) => Product.fromJson(json)).toList();
        _shopProducts.addAll(newProducts);
        
        if (result['meta'] != null) {
          _hasMore = result['meta']['current_page'] < result['meta']['last_page'];
        } else {
          _hasMore = false;
        }
      }
    } catch (e) {
      debugPrint("Error loading more products: $e");
      _currentPage--; 
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> _fetchBestSellersFromFirebase() async {
    final String? dbUrl = dotenv.env['FIREBASE_DB_URL'];
    if (dbUrl == null) return;
    
    try {
        final String url = "${dbUrl}orders.json";
        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) return;
        
        final dynamic data = json.decode(response.body);
        if (data == null) return;

        final Map<String, int> productCounts = {};
        final Map<String, Map<String, dynamic>> productDetails = {};
        
        if (data is Map) {
             data.forEach((dynamic orderId, dynamic orderData) {
                if (orderData['items'] != null && orderData['items'] is List) {
                    for (final dynamic item in orderData['items']) {
                        final String pid = item['productId'].toString();
                        final int qty = item['quantity'] ?? 1;
                        
                        productCounts[pid] = (productCounts[pid] ?? 0) + qty;
                        
                        if (!productDetails.containsKey(pid)) {
                            productDetails[pid] = {
                                'id': int.tryParse(pid) ?? 0,
                                'name': item['title'] ?? 'Unknown',
                                'price': item['price'].toString(), 
                                'image_url': item['image'] ?? '',
                                'description': 'Best Seller',
                                'slug': 'best-seller-$pid',
                                'colors': <String>[], 
                                'sizes': <String>[],
                                'category_id': 0,
                                'stock': 100,
                            };
                        }
                    }
                }
             });
        }

        final List<String> sortedKeys = productCounts.keys.toList()
          ..sort((String k1, String k2) => productCounts[k2]!.compareTo(productCounts[k1]!));

        final List<Product> topProducts = [];
        for (int i = 0; i < sortedKeys.length && i < 4; i++) {
             final String pid = sortedKeys[i];
             final Map<String, dynamic>? details = productDetails[pid];
             if (details != null) {
                 topProducts.add(Product(
                    id: details['id'],
                    name: details['name'],
                    description: details['description'],
                    price: details['price'],
                    images: <String>[ details['image_url'] ?? '' ],
                    categoryName: 'Best Sellers',
                 ));
             }
        }
        
        if (topProducts.isNotEmpty) {
           _bestSellingProducts = topProducts;
        }

    } catch (e) {
        debugPrint("Firebase Best Sellers Error: $e");
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


  /// Backward compatibility for fetching best sellers.
  Future<void> fetchBestSellingProducts({String? token}) async => await fetchHomeData(token: token);
}
