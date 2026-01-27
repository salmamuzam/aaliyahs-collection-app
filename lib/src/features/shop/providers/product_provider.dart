import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/category.dart';
import 'package:aaliyahs_collection_estore/src/data/services/product_service.dart';
import 'package:aaliyahs_collection_estore/src/data/services/api/api_response.dart';
import 'package:aaliyahs_collection_estore/src/data/services/api/list_response.dart';
import 'package:flutter/foundation.dart' hide Category;
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

  String _errorMessage = '';
  String _searchQuery = '';
  String _sortOption = 'Newest'; 
  
  static const int maxDisplayProducts = 4;
  static const String defaultSort = 'Newest';

  List<Product> get bestSellingProducts => _bestSellingProducts;
  List<Product> get latestProducts => _latestProducts;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get shopProducts => _shopProducts;
  List<Category> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => false;
  bool get hasMore => false;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(String option) {
    if (_sortOption != option) {
      _sortOption = option;
      fetchShopProducts(categoryId: _selectedCategoryId); 
    }
  }

  List<Product> get filteredShopProducts {
    final List<Product> products = List<Product>.from(_shopProducts);
    if (_searchQuery.isNotEmpty) {
      products.retainWhere((Product p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()));
    }
    return products;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchHomeData({String? token}) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      await _fetchBestSellersFromFirebase();
      
      final results = await Future.wait([
         _productService.getCategories(),
         _productService.getBestSellingProducts(token: token),
         _productService.getShopProducts(page: 0, sort: 'latest'),
      ]);
      
      // 1. Categories
      final categoriesResponse = results[0] as ApiResponse<Map<String, dynamic>>;
      if (categoriesResponse.success && categoriesResponse.data != null) {
         final data = categoriesResponse.data!;
         final list = data['data'] ?? (data is List ? data : []);
         if (list is List) {
           _categories = list.map((e) => Category.fromJson(e)).toList();
         }
      }

      // 2. Best Sellers (API)
      final bestSellingResponse = results[1] as ApiResponse<Map<String, dynamic>>;
       if (bestSellingResponse.success && bestSellingResponse.data != null) {
          final data = bestSellingResponse.data!;
          final list = data['data'] ?? (data is List ? data : []);
          final List<Product> bestSellers = await compute(_extractProductsSync, list);
          if (bestSellers.isNotEmpty) {
            _bestSellingProducts = bestSellers.take(maxDisplayProducts).toList();
          }
       } 

      // 3. Latest Products (from Shop)
      final latestResponse = results[2] as ApiResponse<ListResponse<Product>>;
      if (latestResponse.success && latestResponse.data != null) {
        _latestProducts = latestResponse.data!.results.take(maxDisplayProducts).toList();
        // Also use latest as featured if needed
        _featuredProducts = _latestProducts;
      }

       // Fallbacks if data empty
       if (_bestSellingProducts.isEmpty) {
         if (_featuredProducts.isNotEmpty) {
           _bestSellingProducts = _featuredProducts.take(maxDisplayProducts).toList();
         }
       }

      if (_categories.isEmpty) await _fetchCategoriesFallback();
      if (_bestSellingProducts.isEmpty && _categories.isNotEmpty) await _fetchBestSellingFallback();

      _enrichBestSellersDetails();
      
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error in fetchHomeData: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchShopProducts({int? categoryId}) async {
    _setLoading(true);
    _errorMessage = '';
    _selectedCategoryId = categoryId;
    _shopProducts = [];  
    
    try {
      if (categoryId != null) {
        // Single Category: Fetch without page param first (try to get all)
        _shopProducts = await _fetchRecursive([categoryId], 0);
      } else {
        // "All" Filter: Workaround for backend 500 error on "No Filter" or "Multiple Filters"
        // We fetch ALL categories individually in parallel and merge them deduplicated.
        List<Future<List<Product>>> futures = [];
        
        // Use existing categories or fetch if empty
        if (_categories.isEmpty) {
           await _fetchCategoriesFallback();
        }

        for (var category in _categories) {
           if (category.id != null) {
             futures.add(_fetchRecursive([category.id!], 0));
           }
        }
        
        final results = await Future.wait(futures);
        final Map<int, Product> uniqueProducts = {};
        
        for (var list in results) {
          for (var p in list) {
            if (p.id != null) uniqueProducts[p.id!] = p;
          }
        }
        
        _shopProducts = uniqueProducts.values.toList();
        
        // Client-side sort since we merged manually
        _applyClientSideSort();
      }
      
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Exception in fetchShopProducts: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _applyClientSideSort() {
    if (_sortOption == 'Newest' || _sortOption == 'latest') {
       // Assuming ID correlates with newness if date not available, or just keep order
       _shopProducts.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    } else if (_sortOption == 'Price: Low to High') {
       _shopProducts.sort((a, b) => a.priceDouble.compareTo(b.priceDouble));
    } else if (_sortOption == 'Price: High to Low') {
       _shopProducts.sort((a, b) => b.priceDouble.compareTo(a.priceDouble));
    }
  }

  Future<List<Product>> _fetchRecursive(List<int>? categoryIds, int page) async {
       List<Product> collected = [];
       
       try {
         // CRITICAL FIX: The backend crashes if we explicitily send ?page=1.
         // We pass '0' here, and the Service layer is configured to OMIT the param if <= 0.
         // This lets the backend handle the default first page logic safely.
         final int safePage = (page == 1) ? 0 : page;

         final response = await _productService.getShopProducts(
            categoryIds: categoryIds, 
            page: safePage,
            sort: _sortOption == 'Newest' ? 'latest' : 
                   (_sortOption == 'Price: Low to High' ? 'price_asc' : 
                   (_sortOption == 'Price: High to Low' ? 'price_desc' : _sortOption))
         );
        
        if (response.success && response.data != null) {
          final newProducts = response.data!.results;
          collected.addAll(newProducts);
          
          bool hasNext = false;
          int nextPage = 0;

          if (response.data!.meta != null) {
             final current = response.data!.meta!['current_page'];
             final last = response.data!.meta!['last_page'];
             
             // If we are on page 1 (current=1), next should be 2.
             // If we requested page 0, current is likely 1.
             if (current < last) {
               hasNext = true;
               nextPage = current + 1;
             }
          }

          if (hasNext) {
             collected.addAll(await _fetchRecursive(categoryIds, nextPage));
          }
        }
       } catch (e) {
         debugPrint("Error in recursive fetch: $e");
       }
       
       return collected;
  }

  Future<void> fetchAllBestSellingProducts({String? token}) async {
    _setLoading(true);
    _errorMessage = '';
    _selectedCategoryId = null;
    _shopProducts = [];
    
    try {
      final response = await _productService.getBestSellingProducts(token: token);
      if (response.success && response.data != null) {
        _shopProducts = await compute(_extractProductsSync, response.data!['data']);
      } else {
        // Fallback if API fails (500 error seen in logs)
        await _fetchBestSellingFallback();
        // If fallback populates _bestSellingProducts, use that
         if (_bestSellingProducts.isNotEmpty) {
           _shopProducts = List.from(_bestSellingProducts);
         } else {
            _errorMessage = response.statusMessage ?? 'Failed to load best selling products';
         }
      }
    } catch (e) {
       // Fallback on error
       if (_bestSellingProducts.isNotEmpty) {
           _shopProducts = List.from(_bestSellingProducts);
       } else {
           _errorMessage = e.toString();
       }
       debugPrint("Exception in fetchAllBestSellingProducts: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Load More is now redundant for Shop with recursive fetch, 
  // but kept for compatibility or safe-guard.
  Future<void> loadMoreShopProducts() async {
     // No-op as we fetch all at once now
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

        final List<Product> topProducts = await compute(_parseFirebaseData, data);
        if (topProducts.isNotEmpty) _bestSellingProducts = topProducts;
    } catch (e) {
        debugPrint("Firebase Best Sellers Error: $e");
    }
  }

  static List<Product> _parseFirebaseData(dynamic data) {
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
                            'description': item['description'] ?? 'Best Seller',
                            'price': item['price'].toString(), 
                            'image_url': item['image'] ?? '',
                        };
                    }
                }
            }
         });
    }
    final List<String> sortedKeys = productCounts.keys.toList()
      ..sort((String k1, String k2) => productCounts[k2]!.compareTo(productCounts[k1]!));

    final List<Product> products = [];
    for (int i = 0; i < sortedKeys.length && i < 4; i++) {
         final String pid = sortedKeys[i];
         final Map<String, dynamic>? d = productDetails[pid];
         if (d != null) {
             products.add(Product(
                id: d['id'], name: d['name'], description: d['description'] ?? 'Best Seller',
                price: d['price'], images: <String>[ d['image_url'] ?? '' ],
                categoryName: 'Best Sellers',
             ));
         }
    }
    return products;
  }

  Future<void> _fetchBestSellingFallback() async {
    try {
      if (_categories.isNotEmpty && _categories.first.id != null) {
        final response = await _productService.getShopProducts(categoryIds: [_categories.first.id!], page: 1);
        if (response.success && response.data != null) {
          List<Product> products = response.data!.results;
          _bestSellingProducts = products.take(maxDisplayProducts).toList();
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchCategoriesFallback() async {
    final response = await _productService.getCategories();
    if (response.success && response.data != null) {
      _categories = (response.data!['data'] as List).map((e) => Category.fromJson(e)).toList();
    }
  }

  void _enrichBestSellersDetails() {
    if (_bestSellingProducts.isNotEmpty && (_latestProducts.isNotEmpty || _featuredProducts.isNotEmpty)) {
      final Map<int, Product> fullProductMap = {};
      for (var product in _latestProducts) {
        if (product.id != null) {
          fullProductMap[product.id!] = product;
        }
      }
      for (var product in _featuredProducts) {
        if (product.id != null) {
          fullProductMap[product.id!] = product;
        }
      }
      for (int i = 0; i < _bestSellingProducts.length; i++) {
        final bestProduct = _bestSellingProducts[i];
        if ((bestProduct.description == 'Best Seller' || bestProduct.description.isEmpty) && 
            fullProductMap.containsKey(bestProduct.id)) {
          _bestSellingProducts[i] = fullProductMap[bestProduct.id]!;
        }
      }
    }
  }

  Future<void> fetchBestSellingProducts({String? token}) async => await fetchHomeData(token: token);

  static List<Product> _extractProductsSync(dynamic data) {
    List<dynamic> items = [];
    if (data is List) {
      items = data;
    } else if (data is Map && data['products'] is List) {
      items = data['products'];
    } else if (data is Map && data['items'] is List) {
      items = data['items'];
    } else if (data is Map && data['data'] is List) {
      items = data['data'];
    }
    return items.map((dynamic json) => Product.fromJson(json)).toList();
  }
}
