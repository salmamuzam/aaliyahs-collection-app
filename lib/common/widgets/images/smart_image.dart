import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';


/// Consolidates image logic into a single robust widget.

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
  final BorderRadius? borderRadius;
  final bool enableShimmer;

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
    this.borderRadius,
    this.enableShimmer = true,
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

    if (url.startsWith('assets/')) return url;
    if (widget.fallbackAssetPath != null) return widget.fallbackAssetPath!;

    try {
      final uri = Uri.parse(url);
      final filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      
      if (filename.isEmpty) return 'assets/images/shop/products/placeholder_product.png';

      // 1. Check for GitHub Pages URL 
      if (url.contains('salmamuzam.github.io/ecommerce_api/assets/')) {
        return url.split('salmamuzam.github.io/ecommerce_api/').last;
      }

      // 2. Check for specific markers in the URL
      if (url.contains('/banners/')) return 'assets/images/shop/banners/$filename';
      if (url.contains('/categories/')) return 'assets/images/shop/categories/$filename';
      if (url.contains('/profile/') || url.contains('/users/') || url.contains('avatar')) {
        return 'assets/images/personalization/profile/$filename';
      }

      // 3. Specialized Product Folder Check
      final lowerUrl = url.toLowerCase();
      if (lowerUrl.contains('abaya')) return 'assets/images/shop/products/abayas/$filename';
      if (lowerUrl.contains('dress')) return 'assets/images/shop/products/dresses/$filename';
      if (lowerUrl.contains('hijab')) return 'assets/images/shop/products/hijabs/$filename';
      if (lowerUrl.contains('access')) return 'assets/images/shop/products/accessories/$filename';
      
      // 3. Fallback to generic markers
      if (filename.startsWith('1766') || filename.contains('category')) {
          return 'assets/images/shop/categories/$filename';
      }

      // Default to products root
      return 'assets/images/shop/products/$filename';
    } catch (e) {
      return 'assets/images/shop/products/placeholder_product.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate optimal cache dimensions based on device pixel ratio
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio; 

    final optimalCacheWidth = widget.cacheWidth ?? 
      (widget.width != null && widget.width!.isFinite ? (widget.width! * devicePixelRatio).toInt() : null);
    final optimalCacheHeight = widget.cacheHeight ?? 
      (widget.height != null && widget.height!.isFinite ? (widget.height! * devicePixelRatio).toInt() : null);

    final String trimmedUrl = widget.imageUrl.trim();
    final bool isNetworkUrl = trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://');

    Widget imageContent;

    // SCENARIO 1: Local Asset or OFFLINE Mode
    if (!isNetworkUrl || !_isOnline) {
      final assetPath = isNetworkUrl ? _getAssetPathFromUrl(trimmedUrl) : trimmedUrl;
      
      imageContent = Image.asset(
        assetPath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        cacheWidth: !isNetworkUrl ? optimalCacheWidth : null, // Only constrain local assets if explicit
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } 
    // SCENARIO 2: Online Network Image with Caching
    else {
      imageContent = CachedNetworkImage(
        imageUrl: trimmedUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        memCacheWidth: optimalCacheWidth,
        memCacheHeight: optimalCacheHeight,
        placeholder: (context, url) => widget.enableShimmer ? _buildShimmerPlaceholder() : (widget.placeholder ?? const SizedBox.shrink()),
        errorWidget: (context, url, error) {
          // Attempt local fallback on network failure
          final assetPath = _getAssetPathFromUrl(url);
          return Image.asset(
            assetPath,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, err, stack) => _buildErrorWidget(),
          );
        },
        fadeInDuration: const Duration(milliseconds: 300),
      );
    }

  
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildShimmerPlaceholder() {
    return widget.placeholder ?? Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ?? Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24),
    );
  }
}
