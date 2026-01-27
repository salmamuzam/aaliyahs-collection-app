import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 35, 25, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemTitle(isDarkMode),
          const SizedBox(height: 8),
          _buildItemPrice(),
          const SizedBox(height: 24),
          _buildDescriptionHeader(isDarkMode),
          const SizedBox(height: 12),
          _buildDescriptionBody(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildItemTitle(bool isDarkMode) {
    return Text(
      product.displayName,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: isDarkMode ? Colors.white : Colors.black,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildItemPrice() {
    return Text(
      "LKR ${product.price.replaceAll(RegExp(r'[^0-9.]'), '')}",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  Widget _buildDescriptionHeader(bool isDarkMode) {
    return Text(
      "Description",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildDescriptionBody(bool isDarkMode) {
    return ReadMoreText(
      product.description,
      trimLines: 4,
      trimMode: TrimMode.Line,
      trimCollapsedText: 'Read more',
      trimExpandedText: ' Read less',
      style: TextStyle(
        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        height: 1.6,
      ),
      moreStyle: const TextStyle(color: aaliyahPrimaryColor, fontWeight: FontWeight.bold),
      lessStyle: const TextStyle(color: aaliyahPrimaryColor, fontWeight: FontWeight.bold),
    );
  }
}
