import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';


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
    return SmartImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      fallbackAssetPath: fallbackAssetPath,
      placeholder: placeholder,
      errorWidget: errorWidget,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      borderRadius: borderRadius,
    );
  }
}


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
    return SmartImage(
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
