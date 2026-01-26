import 'dart:convert';
import 'package:aaliyahs_collection_estore/src/constants/api_strings.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ProductService {
  // Get Home Data (Categories, Featured, Latest)
  Future<Map<String, dynamic>> getHomeData() async {
    var url = Uri.parse('$baseURL/home');

    try {
      debugPrint(">>> API REQUEST HOME: $url");
      http.Response response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return {"status": "success", "data": responseData['data']};
      } else {
        return {
          "status": "error", 
          "message": "Failed to fetch home data",
          "statusCode": response.statusCode
        };
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Get Best Selling Products
  Future<Map<String, dynamic>> getBestSellingProducts({String? token}) async {
    // Updated to use correct endpoint
    var url = Uri.parse('$baseURL/products/best-selling');

    try {
      debugPrint(">>> API REQUEST BEST SELLING: $url");
      Map<String, String> requestHeaders = Map.from(headers);
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      http.Response response = await http.get(url, headers: requestHeaders);

      debugPrint(">>> API RESPONSE STATUS BEST SELLING: ${response.statusCode}");

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return {"status": "success", "data": responseData['data']};
      } else {
        return {
          "status": "error", 
          "message": "Failed to fetch best selling products",
          "statusCode": response.statusCode
        };
      }
    } catch (e) {
      debugPrint(">>> API EXCEPTION BEST SELLING: $e");
      return {"status": "error", "message": e.toString()};
    }
  }

  // Get Categories
  Future<Map<String, dynamic>> getCategories() async {
    var url = Uri.parse('$baseURL/categories');

    try {
      debugPrint("Fetching categories from: $url");
      http.Response response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return {"status": "success", "data": responseData['data']};
      } else {
        return {"status": "error", "message": "Failed to fetch categories"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Get Shop Products (Optionally filtered by Category ID and Sorted)
  Future<Map<String, dynamic>> getShopProducts({int? categoryId, int page = 1, String? sort}) async {
    // Construct URL with query parameters
    String urlString = '$baseURL/shop?page=$page';
    if (categoryId != null) {
      urlString += '&selected_categories[]=$categoryId';
    }
    
    // Add sorting
    // Mapping internal sort option to API params
    if (sort != null) {
       if (sort == 'Price: Low to High') {
         urlString += '&sort=price_asc';
       } else if (sort == 'Price: High to Low') {
         urlString += '&sort=price_desc';
       }
       // Newest is default or handled otherwise, usually 'latest' or null
    }

    var url = Uri.parse(urlString);

    try {
      debugPrint(">>> API REQUEST: $url");
      http.Response response = await http.get(url, headers: headers);

      debugPrint(">>> API RESPONSE STATUS: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        
        // Support both wrapping in 'data' key or direct array returning
        var data = responseData is List ? responseData : responseData['data'];
        
        // Detailed Meta Extraction for debugging pagination
        var meta = responseData is Map ? responseData['meta'] : null;
        
        return {
          "status": "success", 
          "data": data ?? [], 
          "meta": meta
        };
      } else {
        debugPrint(">>> API ERROR BODY: ${response.body}");
        return {
          "status": "error", 
          "message": "Server Error ${response.statusCode}",
          "statusCode": response.statusCode
        };
      }
    } catch (e) {
      debugPrint(">>> API EXCEPTION: $e");
      return {"status": "error", "message": "Connection error: $e"};
    }
  }

  // Add more product methods here as needed (e.g., fetch by category)
}
