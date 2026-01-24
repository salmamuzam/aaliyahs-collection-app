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
    _sortOption = option;
    notifyListeners();
  }

  /// Returns a filtered and sorted version of the shop products list based on search and sort state.
  List<Product> get filteredShopProducts {
    final List<Product> products = List<Product>.from(_shopProducts);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      products.retainWhere((Product p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()));
    }

    // Sort logic
    if (_sortOption == 'Price: Low to High') {
      products.sort((Product a, Product b) => double.parse(a.price).compareTo(double.parse(b.price)));
    } else if (_sortOption == 'Price: High to Low') {
      products.sort((Product a, Product b) => double.parse(b.price).compareTo(double.parse(a.price)));
    } else if (_sortOption == 'Newest') {
      products.sort((Product a, Product b) => (b.id ?? 0).compareTo(a.id ?? 0));
    }

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
      // Fetch Categories from Backend and Best Sellers from Firebase
      final List<dynamic> results = await Future.wait([
        _productService.getCategories(),
        _fetchBestSellersFromFirebase(), 
      ]);

      final Map<String, dynamic>? categoriesResult = results[0] as Map<String, dynamic>?;

      if (categoriesResult != null && categoriesResult['status'] == 'success') {
        final List<dynamic> data = categoriesResult['data'];
        _categories = data.map((dynamic json) => Category.fromJson(json)).toList();
      }

      // Fallback if Firebase Best Sellers are empty
      if (_bestSellingProducts.isEmpty) {
         final Map<String, dynamic> apiResult = await _productService.getBestSellingProducts(token: token);
         if (apiResult['status'] == 'success') {
             final List<dynamic> data = apiResult['data'];
             _bestSellingProducts = data.map((dynamic json) => Product.fromJson(json)).toList();
         } else {
             await _fetchBestSellingFallback();
         }
      }
      
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error in fetchHomeData: $e");
    } finally {
      _setLoading(false);
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

  /// Fetches products for the shop view, filtered by category if provided.
  /// Automatically pages through results to load the full set for the selected category.
  Future<void> fetchShopProducts({int? categoryId}) async {
    _setLoading(true);
    _errorMessage = '';
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    _hasMore = true;
    _shopProducts = []; 
    
    try {
      if (categoryId == null) {
        // CASE: Shop All Categories
        List<Product> allProducts = [];
        for (final Category category in _categories) {
          int page = 1;
          bool hasMoreData = true;
          
          while (hasMoreData) {
            final Map<String, dynamic> result = await _productService.getShopProducts(categoryId: category.id, page: page);
            
            if (result['status'] == 'success') {
              final List<dynamic> data = result['data'];
              final List<Product> pageProducts = data.map((dynamic json) => Product.fromJson(json)).toList();
              
              if (pageProducts.isEmpty) {
                hasMoreData = false;
                break;
              }

              allProducts.addAll(pageProducts);
              _shopProducts = List<Product>.from(allProducts); 
              notifyListeners();
              
              page++; 
            } else {
              hasMoreData = false;
            }
          }
        }
        _hasMore = false; 
      } else {
        // CASE: Specific Category
        int page = 1;
        bool hasMoreData = true;
        while (hasMoreData) {
          final Map<String, dynamic> result = await _productService.getShopProducts(categoryId: categoryId, page: page);
          
          if (result['status'] == 'success') {
            final List<dynamic> data = result['data'];
            final List<Product> pageProducts = data.map((dynamic json) => Product.fromJson(json)).toList();
            
            if (pageProducts.isEmpty) {
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

  /// Loads the next page of products for the currently selected category (Pagination).
  Future<void> loadMoreShopProducts() async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();
    
    _currentPage++;
    
    try {
      final Map<String, dynamic> result = await _productService.getShopProducts(categoryId: _selectedCategoryId, page: _currentPage);
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

  /// Backward compatibility for fetching best sellers.
  Future<void> fetchBestSellingProducts({String? token}) async => await fetchHomeData(token: token);
}
