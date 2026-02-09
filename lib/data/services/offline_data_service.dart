import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Handles loading local JSON data and managing fallback images
class OfflineDataService {
  /// Load local JSON data from assets
  Future<Map<String, dynamic>> loadLocalJson(String assetPath) async {
    try {
      debugPrint('[OFFLINE SERVICE]: Loading JSON from $assetPath');
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      debugPrint('[OFFLINE SERVICE]: Successfully loaded JSON from $assetPath');
      return data;
    } catch (e) {
      debugPrint('[OFFLINE SERVICE]: Error loading JSON from $assetPath: $e');
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
      
      // Determine category based on URL pattern or filename
      if (imagePath.contains('abaya')) return 'assets/images/shop/products/abayas/$filename';
      if (imagePath.contains('dress')) return 'assets/images/shop/products/dresses/$filename';
      if (imagePath.contains('hijab')) return 'assets/images/shop/products/hijabs/$filename';
      if (imagePath.contains('access')) return 'assets/images/shop/products/accessories/$filename';

      // Fallback: Check if it's a category image
      if (filename.startsWith('1766') || filename.contains('category')) {
          return 'assets/images/shop/categories/$filename';
      }

      return 'assets/images/shop/products/$filename';
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
    if (url.isEmpty) return 'assets/images/shop/products/placeholder_product.png';
    if (url.startsWith('assets/')) return url;

    try {
      final uri = Uri.parse(url);
      final filenameWithExtension = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      
  
      final filename = filenameWithExtension.replaceAll(RegExp(r'\.(jpg|jpeg|png)$'), '.webp');

      if (filename.isEmpty) return 'assets/images/shop/products/placeholder_product.webp';

 
      if (RegExp(r'^\d').hasMatch(filename)) {
        return 'assets/images/shop/products/$filename';
      }

      // 1. Check common categories in URL
      if (url.contains('/banners/')) return 'assets/images/shop/banners/$filename';
      if (url.contains('/categories/')) return 'assets/images/shop/categories/$filename';
      if (url.contains('/profile/') || url.contains('/users/') || url.contains('avatar')) {
        return 'assets/images/personalization/profile/$filename';
      }

      // 2. Specialized Product Folder Check
      if (url.contains('abaya')) return 'assets/images/shop/products/abayas/$filename';
      if (url.contains('dress')) return 'assets/images/shop/products/dresses/$filename';
      if (url.contains('hijab')) return 'assets/images/shop/products/hijabs/$filename';
      if (url.contains('access')) return 'assets/images/shop/products/accessories/$filename';

      // 3. Fallback to product root or category root if name looks like Category ID
      if (filename.startsWith('1766') || filename.contains('category')) {
          return 'assets/images/shop/categories/$filename';
      }

      return 'assets/images/shop/products/$filename';
    } catch (_) {
      return 'assets/images/shop/products/placeholder_product.webp';
    }
  }

  /// Get placeholder image based on category
  String getPlaceholderImage(String category) {
    switch (category.toLowerCase()) {
      case 'abaya':
      case 'abayas':
        return 'assets/images/shop/products/placeholder_abaya.webp';
      case 'dress':
      case 'dresses':
        return 'assets/images/shop/products/placeholder_dress.webp';
      case 'hijab':
      case 'hijabs':
        return 'assets/images/shop/products/placeholder_hijab.webp';
      case 'accessory':
      case 'accessories':
        return 'assets/images/shop/products/placeholder_accessory.webp';
      default:
        return 'assets/images/shop/products/placeholder_product.webp';
    }
  }
}
