import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

// This is the product card to display the images, and it's responsive

class ProductCardVertical extends StatelessWidget {
  final Product product;
  final VoidCallback onPress;

  final Function(GlobalKey)? onAddToCart;
  final bool isWishlist;

  const ProductCardVertical({
    super.key,
    required this.product,
    required this.onPress,
    this.onAddToCart,
    this.isWishlist = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);


    final GlobalKey widgetKey = GlobalKey();

    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : aaliyahLightColor,
          borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
          boxShadow: [
            BoxShadow(
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.black.withValues(alpha: 0.05)),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              key: widgetKey,
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
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
                                  placeholder: (context, url) => FadeShimmer(
                                    height: 200,
                                    width: 200,
                                    radius: 10,
                                    highlightColor: const Color(0xfff9f9f9),
                                    baseColor: const Color(0xffe6e6e6),
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
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        // Toggle favorite status
                        final isAlreadyLoved = provider.isExists(product);
                        provider.toggleFavorite(product);
                        
                        // Show Snackbar Feedback
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
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                         color: Theme.of(context).brightness == Brightness.dark ? aaliyahDarkColor.withValues(alpha: 0.8) : aaliyahLightColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          isWishlist ? Icons.delete_outline : (provider.isExists(product) ? Icons.favorite : Icons.favorite_outline_outlined),
                           color: isWishlist 
                               ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.red) 
                               : (provider.isExists(product) ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? aaliyahLightColor : aaliyahDarkColor)),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AutoSizeText(
              product.displayName.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "LKR ${product.price.replaceAll(RegExp(r'[^0-9.]'), '')}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Add to Cart Button (Bag + Plus Icon)
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    CartProvider.of(context, listen: false).addToCart(product);
                    if (onAddToCart != null) {
                      onAddToCart!(widgetKey);
                    }
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Added to Cart!',
                        message: '${product.displayName} has been added to your cart.',
                        contentType: ContentType.success,
                      ),
                    );
                    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Theme.of(context).brightness == Brightness.dark ? aaliyahLightColor : aaliyahDarkColor,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
