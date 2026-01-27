import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/providers/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';

class CartItemCard extends StatelessWidget {
  final Product item;
  final int index;
  final CartProvider provider;

  const CartItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemImage(isDarkMode),
          const SizedBox(width: 16),
          _buildItemDetails(isDarkMode),
          _buildRemoveButton(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildItemImage(bool isDarkMode) {
    return Container(
      height: 120,
      width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        child: item.image.isEmpty
            ? const Icon(Icons.image_not_supported_outlined, color: Colors.grey)
            : item.image.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: item.image,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    memCacheWidth: 200,
                    memCacheHeight: 250,
                    placeholder: (context, url) => FadeShimmer(
                      height: 120,
                      width: 90,
                      radius: TUIConstants.cardRadius,
                      highlightColor: isDarkMode ? const Color(0xff3a3e3f) : const Color(0xfff9f9f9),
                      baseColor: isDarkMode ? const Color(0xff2d2f30) : const Color(0xffe6e6e6),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                  )
                : Image.asset(item.image, fit: BoxFit.cover, alignment: Alignment.topCenter),
      ),
    );
  }

  Widget _buildItemDetails(bool isDarkMode) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            "Rs. ${(item.priceDouble * item.quantity).toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuantityControls(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQtyBtn(Icons.remove, () => provider.decrementQtn(index), isDarkMode),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "${item.quantity}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        _buildQtyBtn(Icons.add, () => provider.incrementQtn(index), isDarkMode),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          border: Border.all(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context, bool isDarkMode) {
    return IconButton(
      onPressed: () {
        provider.removeFromCart(index);
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Removed from Cart!',
            message: '${item.displayName} has been removed from your cart.',
            contentType: ContentType.warning,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      },
      icon: Icon(
        Icons.delete_outline_rounded,
        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
        size: 22,
      ),
    );
  }
}
