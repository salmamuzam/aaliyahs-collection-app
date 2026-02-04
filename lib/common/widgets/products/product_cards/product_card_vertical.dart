import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/cart_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

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

class ProductCardVertical extends StatelessWidget {
  final ProductModel product;         // The product data to display
  final VoidCallback onPress;         // What happens when card is tapped
  final Function(GlobalKey)? onAddToCart;  // Callback for add-to-cart animation
  final String? heroPrefix;           // Optional prefix for Hero tags to avoid collisions
  final bool isWishlist;              // True if showing on wishlist screen (shows delete icon)

  const ProductCardVertical({
    super.key,
    required this.product,
    required this.onPress,
    this.onAddToCart,
    this.heroPrefix,
    this.isWishlist = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get favorite controller to check if product is favorited
    final provider = Provider.of<FavoriteController>(context);

    // Check if app is in dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Create a stable key for this widget (used for add-to-cart animation)
    // Using GlobalObjectKey with product ensures it's persistent for this product instance
    final GlobalKey widgetKey = GlobalObjectKey(product);

    // Card is the container for the product
    return Card(
      elevation: isDarkMode ? 0 : 2,  // Shadow (no shadow in dark mode)
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUIConstants.cardRadius)),
      clipBehavior: Clip.antiAlias,  // Clip content to rounded corners
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      
      // InkWell makes the card tappable with ripple effect
      child: InkWell(
        onTap: onPress,  // Open product detail screen when tapped
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: PRODUCT IMAGE WITH FAVORITE BUTTON
              Container(
                key: widgetKey,  // Attach key for animation
                child: Stack(  // Stack allows overlaying favorite button on image
                  children: [
                    // Product Image
                    AspectRatio(
                      aspectRatio: 1,  // Make image square (1:1 ratio)
                      child: product.id != 0 
                        ? Hero(
                            tag: "${heroPrefix ?? ''}ProductModel_${product.id ?? product.name}_0",  // Unique Hero animation tag
                            child: _buildProductImage(),
                          )
                        : _buildProductImage(),
                    ),
                    
                    // Favorite button positioned at top-right corner
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          // Check if product is already in favorites
                          final isAlreadyLoved = provider.isExists(product);
                          
                          // Add or remove from favorites
                          provider.toggleFavorite(product);
                          
                          // Show snackbar notification
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            duration: const Duration(seconds: 2),
                            content: AwesomeSnackbarContent(
                              title: isAlreadyLoved ? 'Removed from Wishlist!' : 'Added to Wishlist!',
                              message: isAlreadyLoved 
                                 ? '${product.displayName} has been removed from your wishlist.' 
                                 : '${product.displayName} has been added to your wishlist.',
                              contentType: isAlreadyLoved ? ContentType.warning : ContentType.success,
                            ),
                          );
                          ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
                        },
                        
                        // Circular button with heart icon
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? aaliyahDarkColor.withValues(alpha: 0.8) 
                              : aaliyahLightColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey.shade800 
                                : Colors.white, 
                              width: 2
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: Icon(
                            // Show delete icon on wishlist screen, heart icon elsewhere
                            isWishlist 
                              ? Icons.delete_outline 
                              : (provider.isExists(product) ? Icons.favorite : Icons.favorite_outline_outlined),
                            color: isWishlist 
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.red) 
                              : (provider.isExists(product) 
                                  ? Colors.red 
                                  : (Theme.of(context).brightness == Brightness.dark ? aaliyahLightColor : aaliyahDarkColor)),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 6),
              
              // SECTION 2: PRODUCT NAME, PRICE, AND ADD TO CART BUTTON
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name with auto-sizing text
                    AutoSizeText(
                      // Capitalize first letter of each word
                      product.displayName.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,  // Show maximum 2 lines
                      minFontSize: 8,  // Minimum font size before truncating
                      overflow: TextOverflow.ellipsis,  // Add ... if text is too long
                    ),
                    
                    const SizedBox(height: 2),
                    
                    const Spacer(),
                    
                    // Price and Add to Cart button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "LKR ${product.price.replaceAll(RegExp(r'[^0-9.]'), '')}",  // Remove non-numeric characters
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        
                        // Add to Cart button
                        InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            // Add product to cart
                            CartController.of(context, listen: false).addToCart(product);
                            
                            // Trigger add-to-cart animation if callback provided
                            if (onAddToCart != null) {
                              onAddToCart!(widgetKey);
                            }
                          },
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? aaliyahLightColor 
                              : aaliyahDarkColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: product.image.isEmpty
          ? Container(
              color: Colors.grey.shade100,
              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            )
          : product.image.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: product.image,
                  memCacheHeight: 600,
                  memCacheWidth: 400,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: const Color(0xffe6e6e6),
                    highlightColor: const Color(0xfff9f9f9),
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.error_outline, color: Colors.red),
                  ),
                )
              : Image.asset(
                  product.image,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
    );
  }
}
