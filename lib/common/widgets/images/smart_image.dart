import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';

/// Smart Image Widget
/// Automatically handles online/offline image loading with proper fallbacks
/// Implements optimization best practices:
/// - ResizeImage for memory efficiency
/// - Progressive loading with shimmer
/// - Automatic cache size management
class SmartImage extends StatefulWidget {
  final String imageUrl;
  final String? fallbackAssetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment alignment;
  final int? cacheWidth;
  final int? cacheHeight;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.fallbackAssetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  State<SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends State<SmartImage> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      _isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);
    });
  }

  String _getAssetPathFromUrl(String url) {
    if (url.isEmpty) return 'assets/images/shop/products/placeholder_product.png';
    
    // If it's already an asset path, return it
    if (url.startsWith('assets/')) {
      return url;
    }

    // If custom fallback is provided, use it
    if (widget.fallbackAssetPath != null) {
      return widget.fallbackAssetPath!;
    }

    // Extract filename from URL
    try {
      final uri = Uri.parse(url);
      final filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      
      if (filename.isEmpty) return 'assets/images/shop/products/placeholder_product.png';

      // 1. Check for specific markers in the URL
      if (url.contains('/banners/')) return 'assets/images/shop/banners/$filename';
      if (url.contains('/categories/')) return 'assets/images/shop/categories/$filename';
      if (url.contains('/profile/') || url.contains('/users/') || url.contains('avatar')) {
        return 'assets/images/personalization/profile/$filename';
      }

      // 2. Specialized Product Folder Check
      // We try to determine the subfolder. If the URL doesn't specify, we'll try to guess
      // or just return a default products/ path.
      final String? folder = _determineProductFolder(url);
      if (folder != null) {
        return 'assets/images/shop/products/$folder/$filename';
      }

      // 3. Last Resort: Check if it's a category image (common in the log)
      if (filename.startsWith('1766') || filename.contains('category')) {
          return 'assets/images/shop/categories/$filename';
      }

      // Default to products root
      return 'assets/images/shop/products/$filename';
    } catch (e) {
      return 'assets/images/shop/products/placeholder_product.png';
    }
  }

  String? _determineProductFolder(String url) {
    if (url.contains('abaya')) return 'abayas';
    if (url.contains('dress')) return 'dresses';
    if (url.contains('hijab')) return 'hijabs';
    if (url.contains('access')) return 'accessories';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate optimal cache dimensions based on device pixel ratio
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final optimalCacheWidth = widget.cacheWidth ?? (widget.width != null ? (widget.width! * devicePixelRatio).toInt() : null);
    final optimalCacheHeight = widget.cacheHeight ?? (widget.height != null ? (widget.height! * devicePixelRatio).toInt() : null);

    // A URL is only a network URL if it explicitly starts with http/https
    final String trimmedUrl = widget.imageUrl.trim();
    final bool isNetworkUrl = trimmedUrl.startsWith('http://') || 
                              trimmedUrl.startsWith('https://');

    // If it's NOT a network URL (e.g. it's an asset path), always use Image.asset
    // OR if we are confirmed offline, use asset fallback
    if (!isNetworkUrl || !_isOnline) {
      final assetPath = isNetworkUrl 
          ? _getAssetPathFromUrl(trimmedUrl)
          : trimmedUrl;

      // debugPrint('📦 SmartImage: Loading as Asset: $assetPath');

      return Image.asset(
        assetPath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        cacheWidth: optimalCacheWidth,
        cacheHeight: optimalCacheHeight,
        errorBuilder: (context, error, stackTrace) {
          // debugPrint('❌ SmartImage: Asset Load Failure: $assetPath - $error');
          // FINAL FALLBACK: Use a generic placeholder or the provided errorWidget
          return widget.errorWidget ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              );
        },
      );
    }

    // Online AND it's a network URL - use CachedNetworkImage with optimization
    // debugPrint('🌐 SmartImage: Loading from Network: $trimmedUrl');
    return CachedNetworkImage(
      imageUrl: trimmedUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      memCacheWidth: optimalCacheWidth,
      memCacheHeight: optimalCacheHeight,
      maxWidthDiskCache: optimalCacheWidth,
      maxHeightDiskCache: optimalCacheHeight,
      placeholder: (context, url) =>
          widget.placeholder ??
          Shimmer.fromColors(
            baseColor: const Color(0xFFE0E0E0),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      errorWidget: (context, url, error) {
        // debugPrint('❌ SmartImage: Network Load Failure: $url - $error');
        
        // Try loading from assets as fallback
        final assetPath = _getAssetPathFromUrl(url);
        return Image.asset(
          assetPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
          cacheWidth: optimalCacheWidth,
          cacheHeight: optimalCacheHeight,
          errorBuilder: (context, assetError, stackTrace) {
            debugPrint('❌ SmartImage: Network Fallback Asset Failure: $assetPath - $assetError');
            return widget.errorWidget ??
                Container(
                  width: widget.width,
                  height: widget.height,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
          },
        );
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 200),
    );
  }
}

/// Extension to make SmartImage usage more convenient
extension SmartImageExtension on String {
  Widget toSmartImage({
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    String? fallbackAsset,
  }) {
    return SmartImage(
      imageUrl: this,
      fallbackAssetPath: fallbackAsset,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
