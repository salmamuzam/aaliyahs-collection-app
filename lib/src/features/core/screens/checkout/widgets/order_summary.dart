import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';

class OrderSummarySection extends StatelessWidget {
  final CartProvider cartProvider;
  final CheckoutColors colors;

  const OrderSummarySection({
    super.key,
    required this.cartProvider,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Summary",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF0F172A), // Slate 900
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              ..._buildCartItems(context, isDarkMode),
              Divider(color: Colors.grey.shade300, height: 48),
              _buildPriceBreakdown(context, isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCartItems(BuildContext context, bool isDarkMode) {
    return cartProvider.cart.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black26 : const Color(0xFFFAF5FF), // Purple-50ish
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: item.image.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: item.image,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : Image.asset(item.image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B), // Slate 500
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Rs. ${item.price}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions Column (Trash + Qty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => cartProvider.removeFromCart(index),
                            child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => cartProvider.decrementQtn(index),
                                  child: Icon(Icons.remove, size: 14, color: isDarkMode ? Colors.white : Colors.black),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    "${item.quantity}",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => cartProvider.incrementQtn(index),
                                  child: Icon(Icons.add, size: 14, color: isDarkMode ? Colors.white : Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPriceBreakdown(BuildContext context, bool isDarkMode) {
    double subtotal = cartProvider.totalPrice();
    double shipping = 250.0; // Fixed shipping
    double tax = 0.0; // No tax for now, or calculate if needed
    double total = subtotal + shipping + tax;

    final labelStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B)); // Slate 500
    final valueStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)); // Slate 900

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Subtotal", style: labelStyle),
            Text("Rs. $subtotal", style: valueStyle),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Shipping", style: labelStyle),
            Text("Rs. $shipping", style: valueStyle),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Tax", style: labelStyle),
            Text("Rs. $tax", style: valueStyle),
          ],
        ),
        Divider(color: Colors.grey.shade300, height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total", 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600, 
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              "Rs. $total", 
              style: TextStyle(
                 fontSize: 16, 
                 fontWeight: FontWeight.bold, // Semibold in snippet, but bold is better for total
                 color: isDarkMode ? Colors.white : const Color(0xFF0F172A) // Can make it blue? No, snippet uses slate 900
              ),
            ),
          ],
        ),
      ],
    );
  }
}

