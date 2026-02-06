import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Smart Image Widget that handles:
/// 1. Online: Network images with caching
/// 2. Offline: Local asset images
/// 3. Automatic fallback based on connectivity
class SmartImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // If it's already a local asset path, use it directly
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    }

    // For network images, use connectivity-aware loading
    return FutureBuilder<List<ConnectivityResult>>(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        final isOffline = snapshot.hasData && 
            snapshot.data!.contains(ConnectivityResult.none);

        if (isOffline) {
          // Try to extract local asset path from URL
          final localPath = _extractLocalPath(imageUrl);
          if (localPath != null) {
            return Image.asset(
              localPath,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return errorWidget ?? _buildDefaultError();
              },
            );
          }
          return errorWidget ?? _buildDefaultError();
        }

        // Online: Use cached network image
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => 
              placeholder ?? _buildDefaultPlaceholder(),
          errorWidget: (context, url, error) {
            // On error, try local fallback
            final localPath = _extractLocalPath(url);
            if (localPath != null) {
              return Image.asset(
                localPath,
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (ctx, err, stack) {
                  return errorWidget ?? _buildDefaultError();
                },
              );
            }
            return errorWidget ?? _buildDefaultError();
          },
        );
      },
    );
  }

  /// Extract local asset path from various URL formats
  String? _extractLocalPath(String url) {
    // Pattern 1: GitHub Pages URL
    if (url.contains('salmamuzam.github.io/ecommerce_api/assets/')) {
      return url.split('salmamuzam.github.io/ecommerce_api/').last;
    }

    // Pattern 2: Railway/API URL with assets path
    if (url.contains('/assets/')) {
      final parts = url.split('/assets/');
      if (parts.length > 1) {
        return 'assets/${parts.last}';
      }
    }

    // Pattern 3: Already contains assets/images
    if (url.contains('assets/images/')) {
      final index = url.indexOf('assets/images/');
      return url.substring(index);
    }

    return null;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }
}
