import 'package:flutter/material.dart';

/// Image Cache Service
/// Manages image caching, memory pressure, and eviction strategies
/// Based on Flutter image loading optimization best practices
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  /// Initialize image cache with optimized settings
  void initialize() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    // Set maximum cache size based on device memory
    // Default: 1000 objects, 100MB
    // Optimized: 500 objects, 50MB for better memory management
    imageCache.maximumSize = 500;
    imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
    
    debugPrint('📸 ImageCacheService: Initialized with max ${imageCache.maximumSize} images, ${imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB');
  }

  /// Clear entire image cache
  void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    debugPrint('📸 ImageCacheService: Cache cleared');
  }

  /// Evict a specific image from cache
  Future<void> evictImage(String imageUrl) async {
    final ImageProvider provider;
    
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      provider = NetworkImage(imageUrl);
    } else {
      provider = AssetImage(imageUrl);
    }
    
    await provider.evict();
    debugPrint('📸 ImageCacheService: Evicted $imageUrl');
  }

  /// Get current cache status
  Map<String, dynamic> getCacheStatus() {
    final imageCache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': imageCache.currentSize,
      'maximumSize': imageCache.maximumSize,
      'currentSizeBytes': imageCache.currentSizeBytes,
      'maximumSizeBytes': imageCache.maximumSizeBytes,
      'liveImageCount': imageCache.liveImageCount,
      'pendingImageCount': imageCache.pendingImageCount,
    };
  }

  /// Handle memory pressure by reducing cache size
  void handleMemoryPressure() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    // Reduce cache to 50% of current maximum
    final newMaxSize = (imageCache.maximumSize * 0.5).toInt();
    final newMaxBytes = (imageCache.maximumSizeBytes * 0.5).toInt();
    
    imageCache.maximumSize = newMaxSize;
    imageCache.maximumSizeBytes = newMaxBytes;
    
    // Clear to enforce new limits
    imageCache.clear();
    
    debugPrint('📸 ImageCacheService: Memory pressure handled. New limits: $newMaxSize images, ${newMaxBytes ~/ (1024 * 1024)}MB');
  }

  /// Preload images for better UX
  Future<void> precacheImages(BuildContext context, List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        if (url.startsWith('http://') || url.startsWith('https://')) {
          await precacheImage(NetworkImage(url), context);
        } else {
          await precacheImage(AssetImage(url), context);
        }
      } catch (e) {
        debugPrint('📸 ImageCacheService: Failed to precache $url - $e');
      }
    }
    debugPrint('📸 ImageCacheService: Precached ${imageUrls.length} images');
  }
}
