import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/category_model.dart';
import 'package:aaliyahs_collection_estore/data/repositories/product_repository.dart';
import 'package:aaliyahs_collection_estore/data/repositories/data_repository.dart';
import 'package:aaliyahs_collection_estore/utils/http/api_response.dart';
import 'package:aaliyahs_collection_estore/utils/http/list_response.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


// This is the MOST COMPLEX controller in the app
// It manages all product-related operations with multiple data sources



class ProductController extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  final DataRepository _dataRepository = DataRepository();
  
  // PRODUCT LISTS - Different categories of products
  List<ProductModel> _latestProducts = [];          // Newest products
  List<ProductModel> _featuredProducts = [];        // Featured/promoted products
  List<ProductModel> _bestSellingProducts = [];     // Top sellers
  List<ProductModel> _shopProducts = [];            // All shop products (paginated)
  final List<ProductModel> _recentlyViewedProducts = [];  // User's browsing history
  
  // CATEGORIES
  List<CategoryModel> _categories = [];             // Product categories (Abayas, Hijabs, etc.)
  final Set<int> _selectedCategoryIds = {};         // Multi-select category filters
  
  // STATE MANAGEMENT
  bool _isLoading = false;                          // Loading initial data
  bool _isUsingLocalData = false;                   // True when using offline JSON data
  String _errorMessage = '';                        // Error message to display
  
  // SEARCH & FILTER
  String _searchQuery = '';                         // Current search text
  String _sortOption = 'Newest';                    // Current sort option
  final List<String> _searchHistory = ['Silk Abayas', 'Chiffon Hijabs', 'Floral Dress']; // Mock history
  
  // PAGINATION
  int _nextPage = 1;                                // Next page to load
  bool _isFetchingMore = false;                     // Loading more products
  bool _hasMore = true;                             // More products available
  
  // CONSTANTS
  static const int maxDisplayProductModels = 4;     // Max products to show on home screen
  static const String defaultSort = 'Newest';


  List<ProductModel> get bestSellingProductModels => _bestSellingProducts;
  List<ProductModel> get latestProductModels => _latestProducts;
  List<ProductModel> get featuredProductModels => _featuredProducts;
  List<ProductModel> get shopProductModels => _shopProducts;
  List<CategoryModel> get categories => _categories;
  Set<int> get selectedCategoryIds => _selectedCategoryIds;
  int? get selectedCategoryId => _selectedCategoryIds.length == 1 ? _selectedCategoryIds.first : null;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  bool get isUsingLocalData => _isUsingLocalData;  // Shows offline banner
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;
  List<String> get searchHistory => _searchHistory;

  // ============================================================================
  // SEARCH - Update Search Query
  // ============================================================================
  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
    }
    notifyListeners();  // Update UI to filter products
  }

  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }

  // ============================================================================
  // SORT - Change Sort Option
  // ============================================================================
  void setSortOption(String option) {
    if (_sortOption != option) {
      _sortOption = option;
      // Re-fetch products with new sort order
      fetchShopProducts(categoryIds: _selectedCategoryIds.toList()); 
    }
  }

  void toggleCategorySelection(int categoryId) {
    if (_selectedCategoryIds.contains(categoryId)) {
      _selectedCategoryIds.remove(categoryId);
    } else {
      _selectedCategoryIds.add(categoryId);
    }
    fetchShopProducts(categoryIds: _selectedCategoryIds.toList(), refresh: true);
  }

  void toggleAllCategories(bool? selected) {
    if (selected == true) {
      _selectedCategoryIds.clear();
      for (var c in _categories) {
        if (c.id != null) _selectedCategoryIds.add(c.id!);
      }
    } else {
      _selectedCategoryIds.clear();
    }
    fetchShopProducts(categoryIds: _selectedCategoryIds.toList());
  }

  void clearAllFilters() {
    _selectedCategoryIds.clear();
    _searchQuery = '';
    _sortOption = defaultSort;
    notifyListeners();
  }

  // ============================================================================
  // FILTERED PRODUCTS - Apply Search Filter
  // ============================================================================
  // Returns products that match the search query
  List<ProductModel> get filteredShopProductModels {
    final List<ProductModel> productModels = List<ProductModel>.from(_shopProducts);
    if (_searchQuery.isNotEmpty) {
      // Filter by name or description
      productModels.retainWhere((ProductModel p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()));
    }
    return productModels;
  }

  // ============================================================================
  // LOADING STATE MANAGEMENT
  // ============================================================================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetchingMore(bool value) {
    _isFetchingMore = value;
    notifyListeners();
  }

  Future<void> fetchHomeData({String? token}) async {
    // Prevent concurrent home data fetches
    if (_isLoading) return;

    _setLoading(true);
    _errorMessage = '';
    _isUsingLocalData = false; 
    

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
       debugPrint('[OFFLINE DETECTED] No internet connection. Switching to local assets.');
       await _loadLocalDataAsFallback();
       _setLoading(false);
       return;
    }
    
    try {
      debugPrint('[ONLINE] Fetching Home Data from Laravel API...');
      await _fetchBestSellersFromFirebase();
      
      final results = await Future.wait([
         _productRepository.getCategories(),
         _productRepository.getBestSellingProducts(token: token),
         _productRepository.getShopProducts(page: 1, sort: 'latest'),
      ]);
      final categoriesResponse = results[0] as ApiResponse<Map<String, dynamic>>;
      if (categoriesResponse.success && categoriesResponse.data != null) {
         final data = categoriesResponse.data!;
         final list = data['data'] ?? (data is List ? data : []);
         if (list is List) {
           _categories = list.map((e) => CategoryModel.fromJson(e)).toList();
         }
      }

      // 2. Best Sellers (API)
      final bestSellingResponse = results[1] as ApiResponse<Map<String, dynamic>>;
       if (bestSellingResponse.success && bestSellingResponse.data != null) {
          final data = bestSellingResponse.data!;
          final list = data['data'] ?? (data is List ? data : []);
          final List<ProductModel> bestSellers = await compute(_extractProductModelsSync, list);
          if (bestSellers.isNotEmpty) {
            _bestSellingProducts = bestSellers.take(maxDisplayProductModels).toList();
          }
       } 

      // 3. Latest ProductModels (from Shop)
      final latestResponse = results[2] as ApiResponse<ListResponse<ProductModel>>;
      if (latestResponse.success && latestResponse.data != null) {
        _latestProducts = latestResponse.data!.results.take(maxDisplayProductModels).toList();
        // Also use latest as featured if needed
        _featuredProducts = _latestProducts;
      }

       // Fallbacks if data empty
       if (_bestSellingProducts.isEmpty) {
         if (_featuredProducts.isNotEmpty) {
           _bestSellingProducts = _featuredProducts.take(maxDisplayProductModels).toList();
         }
       }

      if (_categories.isEmpty) await _fetchCategoriesFallback();
      if (_bestSellingProducts.isEmpty && _categories.isNotEmpty) await _fetchBestSellingFallback();
      
      await _enrichBestSellersDetails();
      
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error in fetchHomeData: $e');
      // Load from Local JSON if API fails
      await _loadLocalDataAsFallback();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadLocalDataAsFallback() async {
    debugPrint('[OFFLINE] Loading local fallback data...');
    _isUsingLocalData = true; // Mark as offline fallback active
    
    // Reset pagination to prevent infinite scroll attempts on local data
    _hasMore = false; 
    _nextPage = 1;

    final localProductModels = await _productRepository.loadLocalProducts();
    final localCategories = await _productRepository.loadLocalCategories();
    
    if (localProductModels.isNotEmpty) {

      _latestProducts = localProductModels.take(4).toList();
      _featuredProducts = localProductModels.length > 4 
          ? localProductModels.skip(4).take(4).toList() 
          : localProductModels;
      _bestSellingProducts = localProductModels.length > 8 
          ? localProductModels.skip(8).take(4).toList() 
          : localProductModels.reversed.take(4).toList();
      
      // Shop Page Data 
      if (_selectedCategoryIds.isNotEmpty) {
        _shopProducts = localProductModels.where((p) => _selectedCategoryIds.contains(p.categoryId)).toList();
        debugPrint('🎯 [OFFLINE] Filtered ${localProductModels.length} products to ${_shopProducts.length} for Category IDs: $_selectedCategoryIds');
      } else {
        _shopProducts = localProductModels;
        debugPrint('🎯 [OFFLINE] Showing all ${localProductModels.length} products (No Category Filter)');
      }

      // Apply current sort option (Price, Newest etc)
      _applyClientSideSort();
    }

    if (localCategories.isNotEmpty) {
      _categories = localCategories;
    }

    notifyListeners();
  }

  /// Tracking recently viewed ProductModels 
  Future<void> addToRecentlyViewed(ProductModel productModel) async {
    if (productModel.id == null) return;
    
    // 1. Update in-memory list
    _recentlyViewedProducts.removeWhere((p) => p.id == productModel.id);
    _recentlyViewedProducts.insert(0, productModel);
    if (_recentlyViewedProducts.length > 10) _recentlyViewedProducts.removeLast();
    
    // 2. Persist IDs to local file system
    final ids = _recentlyViewedProducts.map((p) => p.id!).toList();
    await _dataRepository.saveRecentlyViewed(ids);
    notifyListeners();
  }

  List<ProductModel> get recentlyViewedProductModels => _recentlyViewedProducts;
  
  Future<void> clearRecentlyViewed() async {
    _recentlyViewedProducts.clear();
    await _dataRepository.clearRecentlyViewed();
    notifyListeners();
  }

  Future<void> loadRecentlyViewedProductModels() async {
     final ids = await _dataRepository.getRecentlyViewed();
     if (ids.isEmpty) return;
     
  
  }

  Future<void> fetchShopProducts({List<int>? categoryIds, bool refresh = false}) async {
    // If we're already loading and not forcing a refresh, ignore
    if (isLoading && !refresh) return;
    
    _setLoading(true);
    _errorMessage = '';
    
    // Reset data source flag when starting a fetch
    _isUsingLocalData = false; 

    if (categoryIds != null) {
      _selectedCategoryIds.clear();
      _selectedCategoryIds.addAll(categoryIds);
    }
    
    // Always clear existing products and reset pagination on a fresh/forced fetch
    _shopProducts = [];  
    _nextPage = 1;
    _hasMore = true;
    
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
       debugPrint(' [OFFLINE DETECTED] No internet connection. Switching Shop to local assets.');
       await _loadLocalDataAsFallback();
       _setLoading(false);
       return;
    }

    try {
      if (_selectedCategoryIds.isNotEmpty) {
        debugPrint(' [ONLINE] Fetching Shop Products for categories ${_selectedCategoryIds.toList()} from Laravel API...');
        final response = await _productRepository.getShopProducts(
          categoryIds: _selectedCategoryIds.toList(), 
          page: 1,
          sort: _sortOption
        );

        if (response.success && response.data != null) {
          _shopProducts = response.data!.results;
          _updatePagination(response.data!);
        }
      } else {
        debugPrint('[ONLINE] Fetching all Shop Products (Page 1) from Laravel API...');
        final response = await _productRepository.getShopProducts(
          page: 1,
          sort: _sortOption
        );

        if (response.success && response.data != null) {
          _shopProducts = response.data!.results;
          _updatePagination(response.data!);
          _hasMore = true; // Enable pagination for 'All'
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Exception in fetchShopProducts: $e');
      //Local Fallback for Shop Page
      await _loadLocalDataAsFallback();
    } finally {
      _setLoading(false);
    }
  }

  void _updatePagination(ListResponse<ProductModel> listResponse) {
    if (listResponse.meta != null) {
      final current = listResponse.meta!['current_page'] ?? 1;
      final last = listResponse.meta!['last_page'] ?? 1;
      _hasMore = current < last;
      _nextPage = current + 1;
    } else {
      _hasMore = false;
    }
  }

  void _applyClientSideSort() {
    if (_sortOption == 'Newest' || _sortOption == 'latest') {

       _shopProducts.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    } else if (_sortOption == 'Price: Low to High') {
       _shopProducts.sort((a, b) => a.priceDouble.compareTo(b.priceDouble));
    } else if (_sortOption == 'Price: High to Low') {
       _shopProducts.sort((a, b) => b.priceDouble.compareTo(a.priceDouble));
    }
  }

  Future<void> fetchAllBestSellingProducts({String? token}) async {
    _setLoading(true);
    _errorMessage = '';
    _selectedCategoryIds.clear();
    _shopProducts = [];
    _isUsingLocalData = false;
    
    try {
      final response = await _productRepository.getBestSellingProducts(token: token);
      if (response.success && response.data != null) {
        _shopProducts = await compute(_extractProductModelsSync, response.data!['data']);
      } else {
        // Fallback if API fails 
        await _fetchBestSellingFallback();
        // If fallback populates _bestSellingProducts, use that
         if (_bestSellingProducts.isNotEmpty) {
           _shopProducts = List.from(_bestSellingProducts);
         } else {
            _errorMessage = response.statusMessage ?? 'Failed to load best selling ProductModels';
         }
      }
    } catch (e) {
       // Fallback on error
       debugPrint('Exception in fetchAllBestSellingProducts: $e');
       await _loadLocalDataAsFallback();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreShopProducts() async {
    // Allow loading more even if categories are empty 
    if (_isFetchingMore || !_hasMore) return;
    
    _setFetchingMore(true);
    try {
      final response = await _productRepository.getShopProducts(
        categoryIds: _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds.toList() : null,
        page: _nextPage,
        sort: _sortOption
      );

      if (response.success && response.data != null) {
        _shopProducts.addAll(response.data!.results);
        _updatePagination(response.data!);
      }
    } catch (e) {
      debugPrint('Error loading more products: $e');
    } finally {
      _setFetchingMore(false);
    }
  }

  Future<void> _fetchBestSellersFromFirebase() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .limit(50) // Analyze last 50 orders
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final Map<String, int> productCounts = {};
      final Map<String, Map<String, dynamic>> productDetails = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['items'] != null && data['items'] is List) {
          for (final dynamic item in data['items']) {
            final String pid = item['productId'].toString();
            final int qty = item['quantity'] ?? 1;
            productCounts[pid] = (productCounts[pid] ?? 0) + qty;
            
            if (!productDetails.containsKey(pid)) {
              productDetails[pid] = {
                'id': int.tryParse(pid) ?? 0,
                'name': item['title'] ?? 'Unknown',
                'description': item['description'] ?? 'Best Seller',
                'price': item['price'].toString(), 
                'image_url': item['image'] ?? '',
              };
            }
          }
        }
      }

      final List<String> sortedKeys = productCounts.keys.toList()
        ..sort((String k1, String k2) => productCounts[k2]!.compareTo(productCounts[k1]!));

      final List<ProductModel> topProductModels = [];
      for (int i = 0; i < sortedKeys.length && i < maxDisplayProductModels; i++) {
        final String pid = sortedKeys[i];
        final Map<String, dynamic>? d = productDetails[pid];
        if (d != null) {
          topProductModels.add(ProductModel(
            id: d['id'], 
            name: d['name'], 
            description: d['description'] ?? 'Best Seller',
            price: d['price'], 
            images: <String>[ d['image_url'] ?? '' ],
            categoryName: 'Best Sellers',
          ));
        }
      }

      if (topProductModels.isNotEmpty) {
        _bestSellingProducts = topProductModels;
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        debugPrint('Firestore Best Sellers: Permission denied. Using API fallback.');
      } else {
        debugPrint(' Firestore Best Sellers Error: $e');
      }
    }
  }

  Future<void> _fetchBestSellingFallback() async {
    try {
      if (_categories.isNotEmpty && _categories.first.id != null) {
        final response = await _productRepository.getShopProducts(categoryIds: [_categories.first.id!], page: 1);
        if (response.success && response.data != null) {
          List<ProductModel> productModels = response.data!.results;
          _bestSellingProducts = productModels.take(maxDisplayProductModels).toList();
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchCategoriesFallback() async {
    final response = await _productRepository.getCategories();
    if (response.success && response.data != null) {
      _categories = (response.data!['data'] as List).map((e) => CategoryModel.fromJson(e)).toList();
    }
  }

  Future<void> _enrichBestSellersDetails() async {

    if (_bestSellingProducts.isNotEmpty && (_latestProducts.isNotEmpty || _featuredProducts.isNotEmpty)) {
      final Map<int, ProductModel> fullProductModelMap = {};
      for (var productModel in _latestProducts) {
        if (productModel.id != null) fullProductModelMap[productModel.id!] = productModel;
      }
      for (var productModel in _featuredProducts) {
        if (productModel.id != null) fullProductModelMap[productModel.id!] = productModel;
      }
      for (int i = 0; i < _bestSellingProducts.length; i++) {
        final bestProductModel = _bestSellingProducts[i];
        if ((bestProductModel.description == 'Best Seller' || bestProductModel.images.length <= 1) && 
            fullProductModelMap.containsKey(bestProductModel.id)) {
          _bestSellingProducts[i] = fullProductModelMap[bestProductModel.id]!;
        }
      }
    }

    // 2. Fetch missing details from API 
    List<Future<void>> futures = [];
    for (int i = 0; i < _bestSellingProducts.length; i++) {
       final p = _bestSellingProducts[i];
       if ((p.description == 'Best Seller' || p.images.length <= 1) && p.id != null) {
          futures.add(() async {
             try {
               final response = await _productRepository.getProductDetails(p.id!);
               if (response.success && response.data != null) {
                  _bestSellingProducts[i] = response.data!;
               }
             } catch (e) {
                debugPrint('Failed to enrich ProductModel ${p.id}: $e');
             }
          }());
       }
    }
    if (futures.isNotEmpty) {
       await Future.wait(futures);
       notifyListeners(); // Notify again after enrichment
    }
  }

  Future<void> fetchBestSellingProducts({String? token}) async => await fetchHomeData(token: token);

  static List<ProductModel> _extractProductModelsSync(dynamic data) {
    List<dynamic> items = [];
    if (data is List) {
      items = data;
    } else if (data is Map && data['ProductModels'] is List) {
      items = data['ProductModels'];
    } else if (data is Map && data['items'] is List) {
      items = data['items'];
    } else if (data is Map && data['data'] is List) {
      items = data['data'];
    }
    return items.map((dynamic json) => ProductModel.fromJson(json)).toList();
  }
  Future<ProductModel?> getProductDetails(int id) async {
    final response = await _productRepository.getProductDetails(id);
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }
}
