import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/widgets/smart_image.dart';

/// Helper to display images that automatically switch to local assets when offline
class NetworkImageHelper {
  /// Builds an image widget that automatically detects if the path is local or network
  /// and strictly falls back to local assets if offline/error.
  static Widget buildImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Determine if it's a network URL
    final bool isNetwork = imagePath.startsWith('http');

    if (!isNetwork) {
      // It's already a local asset path, use Image.asset directly
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Asset load failed: $imagePath - $error');
          return errorWidget ?? _buildErrorWidget(width, height);
        },
      );
    }

    // Use SmartImage which handles the "Network -> Local Asset" fallback logic
    return SmartImage(
      imageUrl: imagePath,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? _buildPlaceholder(width, height),
      errorWidget: errorWidget ?? _buildErrorWidget(width, height),
    );
  }

  static Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  static Widget _buildErrorWidget(double? width, double? height) {
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
