import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class ProductImageCarousel extends StatelessWidget {
  final Product product;
  final int selectedIndex;
  final Function(int) onPageChanged;

  const ProductImageCarousel({
    super.key,
    required this.product,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? Colors.grey.shade900 : const Color(0xFFFFF8E1),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: product.images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final String img = product.images[index];
              return Hero(
                tag: "product_${product.id}_$index",
                child: Center(
                  child: img.isEmpty
                      ? const Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey)
                      : CachedNetworkImage(
                          imageUrl: img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.topCenter,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                        ),
                ),
              );
            },
          ),
          _buildDotIndicators(),
        ],
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Positioned(
      bottom: 25,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          product.images.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: selectedIndex == index ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: selectedIndex == index ? aaliyahPrimaryColor : Colors.grey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
