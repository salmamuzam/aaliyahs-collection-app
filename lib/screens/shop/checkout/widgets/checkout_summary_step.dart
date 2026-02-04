import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaliyahs_collection_estore/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';

class CheckoutSummaryStep extends StatelessWidget {
  final CartController cartController;
  final String street;
  final String city;
  final String postalCode;
  final String province;
  final String country;

  const CheckoutSummaryStep({
    super.key,
    required this.cartController,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.province,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Item Details", isDarkMode),
          const SizedBox(height: 16),
          ...cartController.cart.map((item) => _buildItemCard(item, isDarkMode)),
          const SizedBox(height: 24),
          _buildSectionTitle("Delivery Address", isDarkMode),
          const SizedBox(height: 12),
          _buildAddressCard(isDarkMode),
          const SizedBox(height: 24),
          _buildPriceRow("Total", cartController.formattedTotalPrice, isDarkMode, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 18, 
        color: isDarkMode ? Colors.white : Colors.black
      ),
    );
  }

  Widget _buildAddressCard(bool isDarkMode) {
    return Card.outlined(
      margin: EdgeInsets.zero,
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Shipping to:", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 4),
            Text(street, style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700)),
            Text("$city, $postalCode", style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700)),
            Text("$province, $country", style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item, bool isDarkMode) {
    // Handle both CartItem and ProductModel for compatibility
    final String displayName = item.displayName ?? item.name ?? '';
    final String image = item.image ?? '';
    final int quantity = item.quantity ?? 1;
    final double price = item is ProductModel 
        ? (double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0)
        : (item.price ?? 0.0);
    final double totalItemPrice = price * quantity;

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: image, 
                      width: 60, 
                      height: 60, 
                      fit: BoxFit.cover, 
                      alignment: Alignment.topCenter
                    )
                  : Image.asset(image, width: 60, height: 60, fit: BoxFit.cover, alignment: Alignment.topCenter),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "LKR ${price.toStringAsFixed(2)} × $quantity",
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, 
                      fontSize: 13, 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "LKR ${totalItemPrice.toStringAsFixed(0)}",
              style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPriceRow(String label, String value, bool isDarkMode, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
