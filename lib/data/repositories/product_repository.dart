import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/data/models/category_model.dart';
import 'package:aaliyahs_collection_estore/data/services/api/api_client.dart';
import 'package:aaliyahs_collection_estore/data/services/api/api_response.dart';
import 'package:aaliyahs_collection_estore/data/services/api/list_response.dart';
import 'package:aaliyahs_collection_estore/util/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/util/constants/api_endpoints.dart';



class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? DioClient(baseUrl: baseURL);

  // --- LOCAL DATA INTEGRATION ---

  /// Load products from Local JSON assets
  /// Uses compute isolate to prevent UI jank during parsing of large JSON files
  Future<List<ProductModel>> loadLocalProducts() async {
    try {
      final String response = await rootBundle.loadString('assets/data/products.json');
      debugPrint("📂 Loading products from local JSON: assets/data/products.json");
      return await compute(_parseProducts, response);
    } catch (e) {
      debugPrint("Error loading local products: $e");
      return [];
    }
  }

  // Static function for compute isolate
  static List<ProductModel> _parseProducts(String responseBody) {
    try {
      final List<dynamic> data = json.decode(responseBody);
      return data.map((json) {
         // Exceptional Handling: Gracefully skip malformed items if any
         try {
           return ProductModel.fromJson(json);
         } catch (e) {
           debugPrint("Skipping malformed product in JSON: $e");
           return null;
         }
      }).whereType<ProductModel>().toList();
    } catch (e) {
      debugPrint("Fatal JSON Parse Error: $e");
      return [];
    }
  }

  /// Load categories from Local JSON assets
  Future<List<CategoryModel>> loadLocalCategories() async {
    try {
      final String response = await rootBundle.loadString('assets/data/category.json');
      debugPrint("📂 Loading categories from local JSON: assets/data/category.json");
      final List<dynamic> data = json.decode(response);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error loading local categories: $e");
      return [];
    }
  }

  /// Load users from Local JSON assets
  Future<List<Map<String, dynamic>>> loadLocalUsers() async {
    try {
      final String response = await rootBundle.loadString('assets/data/user.json');
      final List<dynamic> data = json.decode(response);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint("Error loading local users: $e");
      return [];
    }
  }

  // Get Home Data (Categories, Featured, Latest)
  Future<ApiResponse<Map<String, dynamic>>> getHomeData() async {
    try {
      final response = await _apiClient.request(
        path: ApiEndpoints.home,
        method: MethodType.get,
        fromJson: (json) => json,
      );
      
      if (response.success) return response;
      throw Exception('API failed'); // Force fallback
    } catch (e) {
      debugPrint("⚠️ [OFFLINE MODE] Fetching home data from local assets");
      
      final categories = await loadLocalCategories();
      final products = await loadLocalProducts();
      
      // Construct a mock home response structure
      return ApiResponse(
        success: true,
        data: {
          'categories': categories.map((e) => e.toJson()).toList(),
          'best_selling': products.take(5).map((e) => e.toJson()).toList(),
          'latest': products.take(5).map((e) => e.toJson()).toList(),
        },
      );
    }
  }

  // Get Best Selling products
  Future<ApiResponse<Map<String, dynamic>>> getBestSellingProducts({String? token}) async {
    try {
      if (token != null) {
        _apiClient.setToken(token);
      }
      
      debugPrint("🚀 [LARAVEL API] Fetching best selling products from: ${ApiEndpoints.bestSelling}");
      final response = await _apiClient.request(
        path: ApiEndpoints.bestSelling,
        method: MethodType.get,
        fromJson: (json) => json,
      );

      if (response.success) return response;
      throw Exception('API failed');
    } catch (e) {
      debugPrint("⚠️ [OFFLINE MODE] Fetching best selling from local assets");
      final products = await loadLocalProducts();
      // Mock best selling by taking first few items
      return ApiResponse(
        success: true,
        data: {
          'data': products.take(6).map((e) => e.toJson()).toList()
        },
      );
    }
  }

  // Get Categories
  Future<ApiResponse<Map<String, dynamic>>> getCategories() async {
    try {
       debugPrint("🚀 [LARAVEL API] Fetching categories from: ${ApiEndpoints.categories}");
       final response = await _apiClient.request(
        path: ApiEndpoints.categories,
        method: MethodType.get,
        fromJson: (json) => json,
      );
      
      if (response.success) return response;
      throw Exception('API failed');
    } catch (e) {
      debugPrint("⚠️ [OFFLINE MODE] Fetching categories from local assets");
      final categories = await loadLocalCategories();
      return ApiResponse(
        success: true,
        data: {
          'data': categories.map((e) => e.toJson()).toList()
        },
      );
    }
  }

  // Get Shop products (Optionally filtered by Category IDs and Sorted)
  Future<ApiResponse<ListResponse<ProductModel>>> getShopProducts({List<int>? categoryIds, int page = 0, String? sort}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (page > 0) {
        queryParams['page'] = page;
      }
      
      if (categoryIds != null && categoryIds.isNotEmpty) {
        for (int i = 0; i < categoryIds.length; i++) {
          queryParams['selected_categories[$i]'] = categoryIds[i];
        }
      }
      
      if (sort != null) {
         if (sort == 'Price: Low to High') {
           queryParams['sort'] = 'price_asc';
         } else if (sort == 'Price: High to Low') {
           queryParams['sort'] = 'price_desc';
         } else if (sort == 'Newest') {
           queryParams['sort'] = 'latest';
         } else {
           queryParams['sort'] = sort;
         }
      }

      debugPrint("🚀 [LARAVEL API] Fetching shop products from: ${ApiEndpoints.shop} (Page: $page, Sort: $sort)");
      final response = await _apiClient.request<ListResponse<ProductModel>>(
        path: ApiEndpoints.shop,
        method: MethodType.get,
        queryParameters: queryParams,
        fromJson: (json) => ListResponse<ProductModel>.fromMap(json, (pJson) => ProductModel.fromJson(pJson)),
      );

      if (response.success && response.data != null) return response;
      throw Exception('API failed or returned null');

    } catch (e) {
      debugPrint("⚠️ [OFFLINE MODE] Shop products fetch failed: $e. Using local assets.");
      
      var products = await loadLocalProducts();
      
      // Client-side filtering for offline mode
      if (categoryIds != null && categoryIds.isNotEmpty) {
        products = products.where((p) => 
          p.categoryId != null && categoryIds.contains(p.categoryId!)
        ).toList();
      }
      
      // Client-side sorting for offline mode
      if (sort != null) {
        if (sort == 'Price: Low to High' || sort == 'price_asc') {
           products.sort((a, b) => a.priceDouble.compareTo(b.priceDouble));
        } else if (sort == 'Price: High to Low' || sort == 'price_desc') {
           products.sort((a, b) => b.priceDouble.compareTo(a.priceDouble));
        }
      }
      
      // Manual pagination
      // Assuming 10 items per page
      final startIndex = (page > 1 ? page - 1 : 0) * 10;
      if (startIndex >= products.length) {
        return ApiResponse(success: true, data: ListResponse(results: [], meta: {'total': products.length}));
      }
      
      final endIndex = (startIndex + 10) < products.length ? (startIndex + 10) : products.length;
      final paginatedProducts = products.sublist(startIndex, endIndex);

      return ApiResponse(
        success: true,
        data: ListResponse(
          results: paginatedProducts,
          meta: {'total': products.length, 'last_page': (products.length / 10).ceil()},
        ),
      );
    }
  }

  // Get Single product Details from GitHub API (with Local Fallback)
  Future<ApiResponse<ProductModel>> getProductDetails(int id) async {
    try {
      debugPrint("🔗 [GITHUB API] Fetching product details from: ${ApiEndpoints.githubApiBase}${ApiEndpoints.githubProductModels}");
      final response = await _apiClient.request<List>(
        path: '${ApiEndpoints.githubApiBase}${ApiEndpoints.githubProductModels}',
        method: MethodType.get,
        fromJson: (json) {
          if (json.containsKey('data') && json['data'] is List) {
             return json['data'] as List;
          }
          return [];
        },
      );

      if (response.success && response.data != null) {
        final List productsJson = response.data!;
        final productJson = productsJson.firstWhere(
          (p) => p['id'] == id,
          orElse: () => null,
        );

        if (productJson != null) {
          // Clone the JSON map to modify it safely
          final Map<String, dynamic> modifiedJson = Map<String, dynamic>.from(productJson);

          // Force GitHub URLs for images in Product Detail
          if (modifiedJson['images'] != null && modifiedJson['images'] is List) {
            final List<String> images = List<String>.from(modifiedJson['images']);
            modifiedJson['images'] = images.map((img) {
              if (img.startsWith('assets/')) {
                return "${ApiEndpoints.githubApiBase}$img";
              }
              return img;
            }).toList();
          } else if (modifiedJson['image'] != null) {
            final String img = modifiedJson['image'].toString();
            if (img.startsWith('assets/')) {
               modifiedJson['image'] = "${ApiEndpoints.githubApiBase}$img";
            }
          }

           debugPrint("✅ Data Fetched successfully from GitHub API for Product ID: $id");
           debugPrint("📸 GitHub Images: ${modifiedJson['images'] ?? modifiedJson['image']}");
           
           return ApiResponse<ProductModel>(
            success: true,
            data: ProductModel.fromJson(modifiedJson),
          );
        }
      }
    } catch (e) {
      debugPrint("GitHub API Detail Fetch Failed, trying local: $e");
    }

    // --- REQUIREMENT 3: LOCAL FALLBACK ---
    debugPrint("Fetching product detail from local JSON fallback...");
    final List<ProductModel> localProducts = await loadLocalProducts();
    try {
      final product = localProducts.firstWhere((p) => p.id == id);
      debugPrint("✅ Product found in local JSON: ${product.name}");
      return ApiResponse<ProductModel>(
        success: true,
        data: product,
      );
    } catch (e) {
      return ApiResponse<ProductModel>(
        success: false,
        statusMessage: "Product not found in Local Storage",
      );
    }
  }
}
