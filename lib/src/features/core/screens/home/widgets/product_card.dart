import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

// This is the product card to display the images, and it's responsive

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onPress;

  const ProductCard({super.key, required this.product, required this.onPress});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: onPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                            alignment: Alignment.topCenter, // Prevent head cutting
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
                      alignment: Alignment.topCenter, // Prevent head cutting
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),

            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.price.contains('Rs') ? product.price : "Rs. ${product.price}",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  provider.toggleFavorite(product);
                },
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: Icon(
                    provider.isExist(product)
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: provider.isExist(product)
                        ? Colors.red
                        : (isDarkMode ? Colors.white : Colors.black),
                    size: 20,
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
