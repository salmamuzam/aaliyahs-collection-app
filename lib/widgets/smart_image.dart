import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Smart Image Widget
/// Automatically handles online/offline image loading with proper fallbacks
class SmartImage extends StatefulWidget {
  final String imageUrl;
  final String? fallbackAssetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment alignment;

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
          return 'assets/images/profile/$filename';
        }

        // Default to products root if no category found
        return 'assets/images/shop/products/$filename';
      }
    } catch (e) {
      debugPrint('Error parsing URL: $e');
    }

    // Final fallback
    return 'assets/images/shop/products/placeholder_product.png';
  }

  @override
  Widget build(BuildContext context) {
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

      debugPrint('📦 SmartImage: Loading as Asset: $assetPath');

      return Image.asset(
        assetPath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ SmartImage: Asset Load Failure: $assetPath - $error');
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

    // Online AND it's a network URL - use CachedNetworkImage
    debugPrint('🌐 SmartImage: Loading from Network: $trimmedUrl');
    return CachedNetworkImage(
      imageUrl: trimmedUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      placeholder: (context, url) =>
          widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) {
        debugPrint('❌ SmartImage: Network Load Failure: $url - $error');
        
        // Try loading from assets as fallback
        final assetPath = _getAssetPathFromUrl(url);
        return Image.asset(
          assetPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
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
