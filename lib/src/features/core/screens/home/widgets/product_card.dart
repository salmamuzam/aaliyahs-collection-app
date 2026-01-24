import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// This is the product card to display the images, and it's responsive

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onPress;

  final Function(GlobalKey)? onAddToCart;
  final bool isWishlist;

  const ProductCard({
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                      child: product.image.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: product.image,
                              memCacheHeight: 600,
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
                                child:
                                    const Icon(Icons.error_outline, color: Colors.red),
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
                        provider.toggleFavorite(product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          isWishlist ? Icons.delete_outline : (provider.isExists(product) ? Icons.favorite : Icons.favorite_border),
                          color: isWishlist ? Colors.red : (provider.isExists(product) ? Colors.red : Colors.black),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Force black
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    product.price.contains('Rs') ? product.price : "Rs. ${product.price}",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Force black
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
                        message: '${product.name} has been added to your cart.',
                        contentType: ContentType.success,
                      ),
                    );
                    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black, // Force black
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
