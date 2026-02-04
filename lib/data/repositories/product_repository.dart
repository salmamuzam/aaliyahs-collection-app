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
  Future<List<ProductModel>> loadLocalProducts() async {
    try {
      final String response = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error loading local products: $e");
      return [];
    }
  }

  /// Load categories from Local JSON assets
  Future<List<CategoryModel>> loadLocalCategories() async {
    try {
      final String response = await rootBundle.loadString('assets/data/category.json');
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
    return await _apiClient.request(
      path: ApiEndpoints.home,
      method: MethodType.get,
      fromJson: (json) => json,
    );
  }

  // Get Best Selling products
  Future<ApiResponse<Map<String, dynamic>>> getBestSellingProducts({String? token}) async {
    if (token != null) {
      _apiClient.setToken(token);
    }
    
    return await _apiClient.request(
      path: ApiEndpoints.bestSelling,
      method: MethodType.get,
      fromJson: (json) => json,
    );
  }

  // Get Categories
  Future<ApiResponse<Map<String, dynamic>>> getCategories() async {
    return await _apiClient.request(
      path: ApiEndpoints.categories,
      method: MethodType.get,
      fromJson: (json) => json,
    );
  }

  // Get Shop products (Optionally filtered by Category IDs and Sorted)
  Future<ApiResponse<ListResponse<ProductModel>>> getShopProducts({List<int>? categoryIds, int page = 0, String? sort}) async {
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

    return await _apiClient.request<ListResponse<ProductModel>>(
      path: ApiEndpoints.shop,
      method: MethodType.get,
      queryParameters: queryParams,
      fromJson: (json) => ListResponse<ProductModel>.fromMap(json, (pJson) => ProductModel.fromJson(pJson)),
    );
  }

  // Get Single product Details from GitHub API (with Local Fallback)
  Future<ApiResponse<ProductModel>> getProductDetails(int id) async {
    try {
      final response = await _apiClient.request<List>(
        path: '${ApiEndpoints.githubApiBase}${ApiEndpoints.githubProductModels}',
        method: MethodType.get,
        fromJson: (json) => json as List,
      );

      if (response.success && response.data != null) {
        final List productsJson = response.data!;
        final productJson = productsJson.firstWhere(
          (p) => p['id'] == id,
          orElse: () => null,
        );

        if (productJson != null) {
          return ApiResponse<ProductModel>(
            success: true,
            data: ProductModel.fromJson(productJson),
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
