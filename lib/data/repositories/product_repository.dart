import 'package:aaliyahs_collection_estore/utils/http/dio_client.dart';
import 'package:aaliyahs_collection_estore/utils/http/http_method.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/category_model.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/review_model.dart';
import 'package:aaliyahs_collection_estore/utils/http/api_client.dart';
import 'package:aaliyahs_collection_estore/utils/http/api_response.dart';
import 'package:aaliyahs_collection_estore/utils/http/list_response.dart';
import 'package:aaliyahs_collection_estore/utils/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/utils/constants/api_endpoints.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? DioClient(baseUrl: baseURL);

  // --- LOCAL DATA INTEGRATION ---

  Future<List<ProductModel>> loadLocalProducts() async {
    try {
      final String response = await rootBundle.loadString('assets/data/shop/products.json');
      return await compute(_parseProducts, response);
    } catch (e) {
      debugPrint('Error loading local products: $e');
      return [];
    }
  }

  static List<ProductModel> _parseProducts(String responseBody) {
    try {
      final List<dynamic> data = json.decode(responseBody);
      return data.map((json) {
         try { return ProductModel.fromJson(json); } catch (e) { return null; }
      }).whereType<ProductModel>().toList();
    } catch (e) { return []; }
  }

  Future<List<CategoryModel>> loadLocalCategories() async {
    try {
      final String response = await rootBundle.loadString('assets/data/shop/category.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) { return []; }
  }

  Future<List<ReviewModel>> loadLocalReviews() async {
    try {
      final String response = await rootBundle.loadString('assets/data/shop/reviews.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading local reviews: $e');
      return [];
    }
  }

  // API Methods

  Future<ApiResponse<Map<String, dynamic>>> getHomeData() async {
    try {
      final response = await _apiClient.request(
        path: ApiEndpoints.home,
        method: MethodType.get,
        fromJson: (json) => json,
      );
      if (response.success) return response;
      throw Exception('API failed');
    } catch (e) {
      final categories = await loadLocalCategories();
      final products = await loadLocalProducts();
      return ApiResponse(data: {
        'categories': categories.map((e) => e.toJson()).toList(),
        'best_selling': products.take(5).map((e) => e.toJson()).toList(),
        'latest': products.take(5).map((e) => e.toJson()).toList(),
      });
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getBestSellingProducts({String? token}) async {
    try {
      if (token != null) _apiClient.setToken(token);
      final response = await _apiClient.request(
        path: ApiEndpoints.bestSelling,
        method: MethodType.get,
        fromJson: (json) => json,
      );
      if (response.success) return response;
      throw Exception('API failed');
    } catch (e) {
      final products = await loadLocalProducts();
      return ApiResponse(data: {
        'data': products.take(6).map((e) => e.toJson()).toList()
      });
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _apiClient.request(
        path: ApiEndpoints.categories,
        method: MethodType.get,
        fromJson: (json) => json,
      );
      if (response.success) return response;
      throw Exception('API failed');
    } catch (e) {
      final categories = await loadLocalCategories();
      return ApiResponse(data: {
        'data': categories.map((e) => e.toJson()).toList()
      });
    }
  }

  Future<ApiResponse<ListResponse<ProductModel>>> getShopProducts({List<int>? categoryIds, int page = 0, String? sort}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page > 0) queryParams['page'] = page;
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
    } catch (e) {
      var products = await loadLocalProducts();
      if (categoryIds != null && categoryIds.isNotEmpty) {
        products = products.where((p) => p.categoryId != null && categoryIds.contains(p.categoryId!)).toList();
      }
      if (sort != null) {
        if (sort == 'Price: Low to High' || sort == 'price_asc') {
          products.sort((a, b) => a.priceDouble.compareTo(b.priceDouble));
        } else if (sort == 'Price: High to Low' || sort == 'price_desc') {
          products.sort((a, b) => b.priceDouble.compareTo(a.priceDouble));
        }
      }
      final startIndex = (page > 1 ? page - 1 : 0) * 10;
      if (startIndex >= products.length) return ApiResponse(data: ListResponse(results: [], meta: {'total': products.length}));
      final endIndex = (startIndex + 10) < products.length ? (startIndex + 10) : products.length;
      return ApiResponse(data: ListResponse(
        results: products.sublist(startIndex, endIndex),
        meta: {'total': products.length, 'last_page': (products.length / 10).ceil()},
      ));
    }
  }

  Future<ApiResponse<List<ProductModel>>> getProductsFromGitHub() async {
    try {
      final response = await _apiClient.request<List>(
        path: '${ApiEndpoints.githubApiBase}${ApiEndpoints.githubProductModels}',
        method: MethodType.get,
        fromJson: (json) {
          if (json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).cast<dynamic>();
          }
          return <dynamic>[];
        },
      );

      if (response.success && response.data != null) {
        final List<ProductModel> products = response.data!.map((p) {
          final Map<String, dynamic> modifiedJson = Map<String, dynamic>.from(p);
          final String? category = modifiedJson['category']?.toString().toLowerCase();
          
          if (modifiedJson['images'] != null && modifiedJson['images'] is List) {
            modifiedJson['images'] = (modifiedJson['images'] as List)
                .map((img) => _fixImagePath(img.toString(), category))
                .toList();
          }
          return ProductModel.fromJson(modifiedJson);
        }).toList();
        return ApiResponse<List<ProductModel>>(data: products);
      }
    } catch (e) {
      debugPrint('GitHub API All Products Fetch Failed: $e');
    }
    // Fallback to local
    final products = await loadLocalProducts();
    return ApiResponse<List<ProductModel>>(data: products);
  }

  Future<ApiResponse<ProductModel>> getProductDetails(int id) async {
    try {
      final response = await _apiClient.request<List>(
        path: '${ApiEndpoints.githubApiBase}${ApiEndpoints.githubProductModels}',
        method: MethodType.get,
        fromJson: (json) {
          if (json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).cast<dynamic>();
          }
          return <dynamic>[];
        },
      );
      if (response.success && response.data != null) {
        final productJson = response.data!.firstWhere(
          (p) => p['id'].toString() == id.toString(), 
          orElse: () => null
        );
        if (productJson != null) {
          final Map<String, dynamic> modifiedJson = Map<String, dynamic>.from(productJson);
          final String? category = modifiedJson['category']?.toString().toLowerCase();

          if (modifiedJson['images'] != null && modifiedJson['images'] is List) {
            modifiedJson['images'] = (modifiedJson['images'] as List)
                .map((img) => _fixImagePath(img.toString(), category))
                .toList();
          } else if (modifiedJson['image'] != null) {
            modifiedJson['image'] = _fixImagePath(modifiedJson['image'].toString(), category);
          }
          return ApiResponse<ProductModel>(data: ProductModel.fromJson(modifiedJson));
        }
      }
    } catch (e) { debugPrint('GitHub API Detail Fetch Failed: $e'); }
    final localProducts = await loadLocalProducts();
    try {
      final product = localProducts.firstWhere((p) => p.id.toString() == id.toString());
      return ApiResponse<ProductModel>(data: product);
    } catch (e) { return ApiResponse<ProductModel>(success: false, statusMessage: 'Product not found'); }
  }

  Future<ApiResponse<List<ReviewModel>>> getProductReviews(int productId) async {
    try {
      final response = await _apiClient.request<List>(
        path: '${ApiEndpoints.githubApiBase}${ApiEndpoints.githubReviews}',
        method: MethodType.get,
        fromJson: (json) {
          if (json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).cast<dynamic>();
          }
          return <dynamic>[];
        },
      );
      if (response.success && response.data != null) {
        final productReviews = response.data!
            .where((r) => r['productId'].toString() == productId.toString())
            .map((r) => ReviewModel.fromJson(r))
            .toList();
        return ApiResponse<List<ReviewModel>>(data: productReviews);
      }
    } catch (e) { debugPrint('GitHub Review Fetch Failed: $e'); }
    final allLocalReviews = await loadLocalReviews();
    return ApiResponse<List<ReviewModel>>(data: allLocalReviews.where((r) => r.productId.toString() == productId.toString()).toList());
  }

  String _fixImagePath(String path, String? category) {
    if (!path.startsWith('assets/')) {
      return path;
    }
    
    String fixedPath = path;
    
    // 🔍 SMART CHECK: Extract the portion after 'products/' to see if it already has a subfolder
    const String prefix = 'assets/images/shop/products/';
    if (path.startsWith(prefix)) {
      String subPath = path.substring(prefix.length);
      
      // If there's no slash in the subPath, it means the category folder is missing
      if (!subPath.contains('/') && category != null) {
        // Handle common plurals used in folders
        String pluralCat = category;
        if (category == 'abaya') {
          pluralCat = 'abayas';
        } else if (category == 'dress') {
          pluralCat = 'dresses';
        } else if (category == 'hijab') {
          pluralCat = 'hijabs';
        } else if (category == 'accessory') {
          pluralCat = 'accessories';
        }
        
        fixedPath = '$prefix$pluralCat/$subPath';
      }
    }
    
    return 'https://salmamuzam.github.io/ecommerce_api/$fixedPath';
  }
}
