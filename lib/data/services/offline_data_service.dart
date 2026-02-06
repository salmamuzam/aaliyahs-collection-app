import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Offline Data Service
/// Handles loading local JSON data and managing fallback images
class OfflineDataService {
  /// Load local JSON data from assets
  Future<Map<String, dynamic>> loadLocalJson(String assetPath) async {
    try {
      debugPrint("📂 [OFFLINE SERVICE]: Loading JSON from $assetPath");
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      debugPrint("✅ [OFFLINE SERVICE]: Successfully loaded JSON from $assetPath");
      return data;
    } catch (e) {
      debugPrint("❌ [OFFLINE SERVICE]: Error loading JSON from $assetPath: $e");
      return {};
    }
  }

  /// Get image path with fallback
  /// Converts network URLs to local asset paths when offline
  String getImagePath(String imagePath, {bool isOnline = false}) {
    // If online and path is a URL, return as is
    if (isOnline && (imagePath.startsWith('http://') || imagePath.startsWith('https://'))) {
      return imagePath;
    }

    // If it's already an asset path, return as is
    if (imagePath.startsWith('assets/')) {
      return imagePath;
    }

    // Extract filename from URL if needed
    if (imagePath.contains('/')) {
      final parts = imagePath.split('/');
      final filename = parts.last;
      
      // Check common asset paths
      final possiblePaths = [
        'assets/images/shop/products/$filename',
        'assets/images/shop/categories/$filename',
        'assets/images/shop/banners/$filename',
      ];

      return possiblePaths.first; // Return first possible path as default
    }

    return imagePath;
  }

  /// Check if an asset exists
  Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert network image URL to local asset path
  String networkUrlToAssetPath(String url) {
    // Extract filename from Cloudinary or Railway URLs
    if (url.contains('cloudinary.com') || url.contains('railway.app')) {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isNotEmpty) {
        final filename = pathSegments.last;
        
        // Determine category based on URL pattern or filename
        if (url.contains('/products/')) {
          return 'assets/images/shop/products/$filename';
        } else if (url.contains('/categories/')) {
          return 'assets/images/shop/categories/$filename';
        } else if (url.contains('/banners/')) {
          return 'assets/images/shop/banners/$filename';
        }
        
        // Default to products
        return 'assets/images/shop/products/$filename';
      }
    }

    // If not a recognized URL, treat as asset path
    return url.startsWith('assets/') ? url : 'assets/images/$url';
  }

  /// Get placeholder image based on category
  String getPlaceholderImage(String category) {
    switch (category.toLowerCase()) {
      case 'abaya':
      case 'abayas':
        return 'assets/images/shop/products/placeholder_abaya.png';
      case 'dress':
      case 'dresses':
        return 'assets/images/shop/products/placeholder_dress.png';
      case 'hijab':
      case 'hijabs':
        return 'assets/images/shop/products/placeholder_hijab.png';
      case 'accessory':
      case 'accessories':
        return 'assets/images/shop/products/placeholder_accessory.png';
      default:
        return 'assets/images/shop/products/placeholder_product.png';
    }
  }
}
