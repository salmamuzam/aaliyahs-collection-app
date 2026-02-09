import 'package:flutter/material.dart';


/// Provides standardized cache dimensions for different image types

class ImageCacheSizes {
  // Private constructor to prevent instantiation
  ImageCacheSizes._();

  // ============================================================================
  // PRODUCT IMAGES
  // ============================================================================
  

  static const int productThumbnail = 700;


  static int productDetail(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (screenWidth * devicePixelRatio).toInt();
  }

 
  static const int productListItem = 300;

  // ============================================================================
  // PROFILE IMAGES
  // ============================================================================

  
  static const int avatarSmall = 100;


  static const int avatarMedium = 200;

 
  static const int avatarLarge = 300;

  // ============================================================================
  // BANNER IMAGES
  // ============================================================================

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

 
  static const int promotionalBanner = 1200;

  // ============================================================================
  // CATEGORY IMAGES
  // ============================================================================


  static const int categoryIcon = 160;

 
  static const int categoryBanner = 600;

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================


  static int calculateCacheSize(BuildContext context, double displaySize) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (displaySize * devicePixelRatio).toInt();
  }


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
        return productThumbnail; 
    }
  }
}

extension ImageCacheSizeExtension on BuildContext {

  int get optimalCacheWidth {
    final screenWidth = MediaQuery.of(this).size.width;
    final devicePixelRatio = MediaQuery.of(this).devicePixelRatio;
    return (screenWidth * devicePixelRatio).toInt();
  }


  int get optimalCacheHeight {
    final screenHeight = MediaQuery.of(this).size.height;
    final devicePixelRatio = MediaQuery.of(this).devicePixelRatio;
    return (screenHeight * devicePixelRatio).toInt();
  }

  
  int cacheSize(double displaySize) {
    final devicePixelRatio = MediaQuery.of(this).devicePixelRatio;
    return (displaySize * devicePixelRatio).toInt();
  }
}
