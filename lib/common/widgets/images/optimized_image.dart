import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized Image Widget
/// Implements best practices for image loading and caching:
/// 1. ResizeImage to decode at appropriate resolution
/// 2. Progressive loading with shimmer placeholder
/// 3. Efficient memory usage
/// 4. Automatic fallback handling
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final String? fallbackAssetPath;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool enableMemoryCache;
  final BorderRadius? borderRadius;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.fallbackAssetPath,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
    this.enableMemoryCache = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final String trimmedUrl = imageUrl.trim();
    final bool isNetworkUrl = trimmedUrl.startsWith('http://') || 
                              trimmedUrl.startsWith('https://');

    Widget imageWidget;

    if (!isNetworkUrl) {
      // Local asset image with optional resizing
      imageWidget = _buildAssetImage(trimmedUrl);
    } else {
      // Network image with caching and resizing
      imageWidget = _buildNetworkImage(trimmedUrl, context);
    }

    // Apply border radius if specified
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildAssetImage(String assetPath) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ OptimizedImage: Asset load failed: $assetPath - $error');
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildNetworkImage(String url, BuildContext context) {
    // Calculate optimal cache dimensions based on device pixel ratio
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final optimalCacheWidth = cacheWidth ?? (width != null ? (width! * devicePixelRatio).toInt() : null);
    final optimalCacheHeight = cacheHeight ?? (height != null ? (height! * devicePixelRatio).toInt() : null);

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      memCacheWidth: optimalCacheWidth,
      memCacheHeight: optimalCacheHeight,
      maxWidthDiskCache: optimalCacheWidth,
      maxHeightDiskCache: optimalCacheHeight,
      placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('❌ OptimizedImage: Network load failed: $url - $error');
        
        // Try fallback asset if provided
        if (fallbackAssetPath != null) {
          return _buildAssetImage(fallbackAssetPath!);
        }
        
        // Try to extract local path from URL
        final localPath = _extractLocalPath(url);
        if (localPath != null) {
          return _buildAssetImage(localPath);
        }
        
        return _buildErrorWidget();
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ?? Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  /// Extract local asset path from various URL formats
  String? _extractLocalPath(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        final filename = pathSegments.last;

        // Check for specific product categories in the URL
        if (url.contains('/abayas/') || url.contains('abayas')) {
          return 'assets/images/shop/products/abayas/$filename';
        } else if (url.contains('/dresses/') || url.contains('dresses')) {
          return 'assets/images/shop/products/dresses/$filename';
        } else if (url.contains('/hijabs/') || url.contains('hijabs')) {
          return 'assets/images/shop/products/hijabs/$filename';
        } else if (url.contains('/accessories/') || url.contains('accessories')) {
          return 'assets/images/shop/products/accessories/$filename';
        }

        // Standard category checks
        if (url.contains('/products/')) {
          return 'assets/images/shop/products/$filename';
        } else if (url.contains('/categories/')) {
          return 'assets/images/shop/categories/$filename';
        } else if (url.contains('/banners/')) {
          return 'assets/images/shop/banners/$filename';
        } else if (url.contains('/profile/') || url.contains('/users/') || url.contains('avatar')) {
          return 'assets/images/personalization/profile/$filename';
        }

        // Default to products root if no category found
        return 'assets/images/shop/products/$filename';
      }
    } catch (e) {
      debugPrint('Error parsing URL: $e');
    }

    return null;
  }
}

/// Extension for convenient OptimizedImage creation
extension OptimizedImageExtension on String {
  Widget toOptimizedImage({
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    String? fallbackAsset,
    int? cacheWidth,
    int? cacheHeight,
    BorderRadius? borderRadius,
  }) {
    return OptimizedImage(
      imageUrl: this,
      fallbackAssetPath: fallbackAsset,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      borderRadius: borderRadius,
    );
  }
}
