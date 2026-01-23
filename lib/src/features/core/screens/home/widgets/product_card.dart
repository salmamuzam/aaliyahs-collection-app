import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

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
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final GlobalKey widgetKey = GlobalKey();

    return GestureDetector(
      onTap: onPress,
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
                    borderRadius: BorderRadius.circular(15),
                    child: product.image.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: product.image,
                            placeholder: (context, url) => FadeShimmer(
                              height: 200,
                              width: 200,
                              radius: 15,
                              highlightColor: isDarkMode
                                  ? const Color(0xff3a3e3f)
                                  : const Color(0xfff9f9f9),
                              baseColor: isDarkMode
                                  ? const Color(0xff2d2f30)
                                  : const Color(0xffe6e6e6),
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
                        border: Border.all(color: Colors.white, width: 2), // Rounded white border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Icon(
                        isWishlist ? Icons.delete_outline : (provider.isExist(product) ? Icons.favorite : Icons.favorite_border),
                        color: isWishlist 
                            ? Colors.red 
                            : (provider.isExist(product) ? Colors.red : Colors.black),
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),

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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Add to Cart Button (Bag + Plus Icon)
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  CartProvider.of(context, listen: false).toggleFavorite(product);
                  if (onAddToCart != null) {
                    onAddToCart!(widgetKey);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Added to Cart",
                        style: TextStyle(
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                      backgroundColor: isDarkMode ? Colors.white : Colors.black,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white : Colors.black, // Contrast background
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_shopping_cart,
                    color: isDarkMode ? Colors.black : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
