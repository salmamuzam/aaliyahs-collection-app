import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_cache_sizes.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

// ============================================================================
// PRODUCT CARD VERTICAL - Displays a Product in a Card Layout
// ============================================================================
// This is a reusable card that shows product information:
// - Product image
// - Product name
// - Price
// - Favorite button (heart icon)
// - Add to cart button (cart icon)
//
// Used in: Home screen, Shop screen, Search results
// ============================================================================

class ProductCardVertical extends StatefulWidget {
  final ProductModel product;         // The product data to display
  final VoidCallback onPress;         // What happens when card is tapped
  final VoidCallback? onLongPress;    // What happens when card is long pressed
  final Function(GlobalKey)? onAddToCart;  // Callback for add-to-cart animation
  final String? heroPrefix;           // Optional prefix for Hero tags to avoid collisions
  final bool isWishlist;              // True if showing on wishlist screen (shows delete icon)
  final bool isSelected;              // True if the card is currently selected

  const ProductCardVertical({
    super.key,
    required this.product,
    required this.onPress,
    this.onLongPress,
    this.onAddToCart,
    this.heroPrefix,
    this.isWishlist = false,
    this.isSelected = false,
  });

  @override
  State<ProductCardVertical> createState() => _ProductCardVerticalState();
}
class _ProductCardVerticalState extends State<ProductCardVertical> {
  ColorScheme? _contentScheme;
  String? _lastImage;
  Brightness? _lastBrightness;

  @override
  void initState() {
    super.initState();
    // Color extraction moved to didChangeDependencies to safely access Theme.of(context)
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleColorExtraction();
  }

  @override
  void didUpdateWidget(ProductCardVertical oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.image != widget.product.image) {
      _handleColorExtraction();
    }
  }

  void _handleColorExtraction() {
    if (widget.product.image.isEmpty) return;
    
    final String currentImage = widget.product.image;
    final Brightness currentBrightness = Theme.of(context).brightness;

    if (_lastImage != currentImage || _lastBrightness != currentBrightness) {
      _lastImage = currentImage;
      _lastBrightness = currentBrightness;
      _extractColor(currentBrightness);
    }
  }

  Future<void> _extractColor(Brightness brightness) async {
    if (!mounted) return;
    
    try {
      ImageProvider imageProvider;
      if (widget.product.image.startsWith('http')) {
        imageProvider = CachedNetworkImageProvider(widget.product.image);
      } else {
        imageProvider = AssetImage(widget.product.image);
      }

      // Optimization: Extract from a tiny version to save memory/time
      // and prevent 'Stream has been disposed' errors on large/slow images
      imageProvider = ResizeImage(imageProvider, width: 100);

      // Add a hard timeout to prevent hanging extractions
      final scheme = await ColorScheme.fromImageProvider(
        provider: imageProvider,
        brightness: brightness,
      ).timeout(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _contentScheme = scheme);
      }
    } on TimeoutException {
      // debugPrint('Color extraction timed out for ${widget.product.name}');
    } catch (e) {
      // Catch all to prevent 'Bad state' crashes from unhandled image stream errors
      if (e.toString().contains('Stream has been disposed')) {
         // Silently ignore this specific framework quirk
      } else {
         debugPrint('Error extracting color for product card: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if app is in dark mode
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // M3 Advanced: Use content-based scheme if available
    final effectiveScheme = _contentScheme ?? colorScheme;
    
    // Create a stable key for this widget (used for add-to-cart animation)
    final GlobalKey widgetKey = GlobalObjectKey("${widget.heroPrefix ?? ''}_${widget.product.id}");

    return Consumer<AccessibilityController>(
      builder: (context, access, _) {
        final bool reduceMotion = access.reduceMotion;
        
        return Card(
          elevation: widget.isSelected ? 0 : 1, 
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium),
            side: BorderSide(
              color: widget.isSelected ? colorScheme.primary : (isDarkMode ? colorScheme.outlineVariant : Colors.transparent),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          color: widget.isSelected 
              ? colorScheme.primaryContainer.withValues(alpha: 0.15) 
              : colorScheme.surfaceContainerLow,
          child: Stack(
            children: [
              // 1. Primary Interaction Layer (Card Content)
              InkWell(
                onTap: widget.onPress,
                onLongPress: widget.onLongPress,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        key: widgetKey,
                        child: AspectRatio(
                          aspectRatio: 0.65, // Taller/Slimmer aspect ratio for fashion
                          child: widget.product.id != 0 
                            ? Hero(
                                tag: "${widget.heroPrefix ?? ''}ProductModel_${widget.product.id ?? widget.product.name}_0",
                                child: _buildProductImage(),
                              )
                            : _buildProductImage(),
                        ),
                      ),

                      
                      SizedBox(height: DeviceUtils.m3Padding(4)),

                      Flexible(
                        child: ExcludeSemantics(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                widget.product.displayName.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' '),
                                style: Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized.copyWith(
                                  color: effectiveScheme.onSurface,
                                  height: 1.2,
                                ),
                                maxLines: 2, // Reduce max lines to preventative overflow with taller image
                                minFontSize: 8,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              SizedBox(height: DeviceUtils.m3Padding(4)),
                              
                              // Price
                              Text(
                                "LKR ${widget.product.price.replaceAll(RegExp(r'[^0-9.]'), '')}",
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: effectiveScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 6),

                              // Add to Cart Button
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: FilledButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    CartController.of(context, listen: false).addToCart(widget.product);
                                    if (widget.onAddToCart != null) widget.onAddToCart!(widgetKey);
                                  },
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: effectiveScheme.primary,
                                    foregroundColor: effectiveScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  child: const Text('Add to Cart'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Favorite Button (Secondary Action)
              if (!widget.isSelected)
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: 10,
                  end: 10,
                  child: Selector<FavoriteController, bool>(
                    selector: (context, favController) => favController.isExists(widget.product),
                    builder: (context, isFavorited, child) {
                      return Tooltip(
                        message: widget.isWishlist ? 'Remove' : (isFavorited ? 'Remove favorite' : 'Add favorite'),
                        child: IconButton.filledTonal(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.read<FavoriteController>().toggleFavorite(widget.product);
                          },
                          icon: Icon(
                            widget.isWishlist 
                              ? Icons.delete_outline_rounded 
                              : (isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                            size: 18,
                            color: widget.isWishlist 
                              ? colorScheme.error 
                              : (isFavorited ? effectiveScheme.primary : effectiveScheme.onSurfaceVariant),
                          ),
                          style: IconButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            backgroundColor: (isDarkMode ? colorScheme.surface : effectiveScheme.surfaceContainerHighest).withValues(alpha: 0.9),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 3. Selection Indicator
              if (widget.isSelected)
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: DeviceUtils.m3Padding(2),
                  start: DeviceUtils.m3Padding(2),
                  child: Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 24),
                ),

            ],
          ),
        ).animate(target: reduceMotion ? 0 : 1)
          .fadeIn(
            duration: AMotion.durationExpressiveEffectsDefault, 
            curve: AMotion.expressiveDefaultEffects,
          )
          .slideY(
            begin: 0.1,
            end: 0,
            duration: AMotion.durationExpressiveDefault,
            curve: reduceMotion ? Curves.linear : AMotion.easingEmphasized,
          );
      },
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium), // M3 Optical Roundness: 20(Card) - 8(Padding) = 12
      child: widget.product.image.isEmpty
          ? Container(
              color: Colors.grey.shade100,
              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            )
          : SmartImage(
              imageUrl: widget.product.image,
              alignment: Alignment.topCenter,
              fit: BoxFit.cover, // Ensures image covers area without distortion
              // cacheWidth/Height removed to allow full resolution / SmartImage optimal calc
              placeholder: Shimmer.fromColors(
                baseColor: const Color(0xffe6e6e6),
                highlightColor: const Color(0xfff9f9f9),
                child: Container(
                  height: 300,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium),
                  ),
                ),
              ),
              errorWidget: Container(
                color: Colors.grey.shade100,
                child: const Icon(Icons.error_outline, color: Colors.red),
              ),
            ),
    );
  }
}
