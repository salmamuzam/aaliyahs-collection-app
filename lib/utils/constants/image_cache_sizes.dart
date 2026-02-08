import 'package:flutter/material.dart';

/// Image Cache Size Constants
/// Provides standardized cache dimensions for different image types
/// Based on typical display sizes and device pixel ratios
class ImageCacheSizes {
  // Private constructor to prevent instantiation
  ImageCacheSizes._();

  // ============================================================================
  // PRODUCT IMAGES
  // ============================================================================
  
  /// Product card thumbnail (grid view)
  /// Typical display: 150-200dp
  /// Cache: 700px (sufficient for 3.5x retina)
  static const int productThumbnail = 700;

  /// Product detail main image
  /// Typical display: Full screen width
  /// Cache: Calculated dynamically based on screen width
  static int productDetail(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (screenWidth * devicePixelRatio).toInt();
  }

  /// Product list item (horizontal scroll)
  /// Typical display: 120-150dp
  /// Cache: 300px
  static const int productListItem = 300;

  // ============================================================================
  // PROFILE IMAGES
  // ============================================================================

  /// Small avatar (list items, comments)
  /// Typical display: 40-50dp
  /// Cache: 100px
  static const int avatarSmall = 100;

  /// Medium avatar (profile header)
  /// Typical display: 80-100dp
  /// Cache: 200px
  static const int avatarMedium = 200;

  /// Large avatar (profile detail)
  /// Typical display: 120-150dp
  /// Cache: 300px
  static const int avatarLarge = 300;

  // ============================================================================
  // BANNER IMAGES
  // ============================================================================

  /// Home banner carousel
  /// Typical display: Full width x 220dp height
  /// Cache: Calculated dynamically
  static int bannerCarousel(BuildContext context, {double height = 220}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (screenWidth * devicePixelRatio).toInt();
  }

  /// Banner height for carousel
  static int bannerCarouselHeight(BuildContext context, {double height = 220}) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (height * devicePixelRatio).toInt();
  }

  /// Promotional banner (full width)
  /// Cache: 1200px width
  static const int promotionalBanner = 1200;

  // ============================================================================
  // CATEGORY IMAGES
  // ============================================================================

  /// Category icon (grid)
  /// Typical display: 60-80dp
  /// Cache: 160px
  static const int categoryIcon = 160;

  /// Category banner
  /// Typical display: 200-300dp width
  /// Cache: 600px
  static const int categoryBanner = 600;

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Calculate cache size based on display size and pixel ratio
  static int calculateCacheSize(BuildContext context, double displaySize) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (displaySize * devicePixelRatio).toInt();
  }

  /// Get optimal cache dimensions for a given widget size
  static Map<String, int> getOptimalCacheDimensions({
    required BuildContext context,
    double? width,
    double? height,
  }) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    return {
      'width': width != null ? (width * devicePixelRatio).toInt() : 0,
      'height': height != null ? (height * devicePixelRatio).toInt() : 0,
    };
  }

  /// Get cache size for specific image type
  static int getCacheSizeForType(String imageType, BuildContext context) {
    switch (imageType.toLowerCase()) {
      case 'product_thumbnail':
        return productThumbnail;
      case 'product_detail':
        return productDetail(context);
      case 'product_list':
        return productListItem;
      case 'avatar_small':
        return avatarSmall;
      case 'avatar_medium':
        return avatarMedium;
      case 'avatar_large':
        return avatarLarge;
      case 'banner':
        return bannerCarousel(context);
      case 'category_icon':
        return categoryIcon;
      case 'category_banner':
        return categoryBanner;
      default:
        return productThumbnail; // Default fallback
    }
  }
}

/// Extension for convenient cache size access
extension ImageCacheSizeExtension on BuildContext {
  /// Get optimal cache width for current screen
  int get optimalCacheWidth {
    final screenWidth = MediaQuery.of(this).size.width;
    final devicePixelRatio = MediaQuery.of(this).devicePixelRatio;
    return (screenWidth * devicePixelRatio).toInt();
  }

  /// Get optimal cache height for current screen
  int get optimalCacheHeight {
    final screenHeight = MediaQuery.of(this).size.height;
    final devicePixelRatio = MediaQuery.of(this).devicePixelRatio;
    return (screenHeight * devicePixelRatio).toInt();
  }

  /// Calculate cache size for specific dimensions
  int cacheSize(double displaySize) {
    final devicePixelRatio = MediaQuery.of(this).devicePixelRatio;
    return (displaySize * devicePixelRatio).toInt();
  }
}
