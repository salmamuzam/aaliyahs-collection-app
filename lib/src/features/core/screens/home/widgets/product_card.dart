import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';

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
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFE3E3E3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.asset(product.image, fit: BoxFit.contain),
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
              Text(
                "Rs. ${product.price}",
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
