import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/data/services/api/api_client.dart';
import 'package:aaliyahs_collection_estore/src/data/services/api/api_response.dart';
import 'package:aaliyahs_collection_estore/src/data/services/api/list_response.dart';
import 'package:aaliyahs_collection_estore/src/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/api_endpoints.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? DioClient(baseUrl: baseURL);

  // Get Home Data (Categories, Featured, Latest)
  Future<ApiResponse<Map<String, dynamic>>> getHomeData() async {
    return await _apiClient.request(
      path: ApiEndpoints.home,
      method: MethodType.get,
      fromJson: (json) => json,
    );
  }

  // Get Best Selling Products
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

  // Get Shop Products (Optionally filtered by Category IDs and Sorted)
  Future<ApiResponse<ListResponse<Product>>> getShopProducts({List<int>? categoryIds, int page = 0, String? sort}) async {
    final Map<String, dynamic> queryParams = {};
    
    if (page > 0) {
      queryParams['page'] = page;
    }
    
    if (categoryIds != null && categoryIds.isNotEmpty) {
      queryParams['selected_categories'] = categoryIds.join(',');
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

    return await _apiClient.request<ListResponse<Product>>(
      path: ApiEndpoints.shop,
      method: MethodType.get,
      queryParameters: queryParams,
      fromJson: (json) => ListResponse<Product>.fromMap(json, (pJson) => Product.fromJson(pJson)),
    );
  }
}
