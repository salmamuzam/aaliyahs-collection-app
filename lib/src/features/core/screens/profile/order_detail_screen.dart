import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List items = order['items'] ?? [];
    final double subtotal = double.tryParse(order['amount'].toString()) ?? 0.0;
    final double shipping = 50.0; // Mock shipping
    final double tax = subtotal * 0.15; // Mock tax 15%
    final double total = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.keyboard_arrow_left, color: isDarkMode ? Colors.white : Colors.black),
        ),
        title: Text(
          "Order Review",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // 1. Order Items
            ...items.map((item) => _buildOrderItem(item, isDarkMode)),
            const SizedBox(height: 30),

            // 2. Promo Code (Mock)
            _buildPromoCodeSection(isDarkMode),
            const SizedBox(height: 30),

            // 3. Totals
            _buildPriceRow("Subtotal", "Rs. ${subtotal.toStringAsFixed(2)}", isDarkMode),
            _buildPriceRow("Shipping Fee", "Rs. ${shipping.toStringAsFixed(2)}", isDarkMode),
            _buildPriceRow("Tax Fee", "Rs. ${tax.toStringAsFixed(2)}", isDarkMode),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Order Total", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text(
                  "Rs. ${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 4. Payment Method
            _buildActionHeader("Payment Method", isDarkMode),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network("https://cdn-icons-png.flaticon.com/512/174/174861.png", errorBuilder: (_, __, ___) => const Icon(Icons.payment)),
                ),
                const SizedBox(width: 15),
                Text(order['payment_method'] ?? "Paypal", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),

            // 5. Shipping Address
            _buildActionHeader("Shipping Address", isDarkMode),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(order['customer']['firstName'] ?? "Customer", style: const TextStyle(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 10),
                   Row(
                     children: [
                       const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                       const SizedBox(width: 10),
                       Text(order['customer']['phone'] ?? "+94 77 123 4567", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                     ],
                   ),
                   const SizedBox(height: 10),
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                       const SizedBox(width: 10),
                       Expanded(
                         child: Text(
                           "${order['customer']['address']}, ${order['customer']['city']}",
                           style: const TextStyle(color: Colors.grey, fontSize: 12),
                         ),
                       ),
                     ],
                   ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 6. Action Button (Disabled as this is a review page)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C6FFF), // Matching the blue in reference
                  disabledBackgroundColor: const Color(0xFF4C6FFF),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  "Order Placed On ${DateFormat('dd MMM yyyy').format(DateTime.parse(order['date']))}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: item['image'].toString().startsWith('http')
                  ? CachedNetworkImage(imageUrl: item['image'].toString(), fit: BoxFit.cover)
                  : Image.asset(item['image'].toString(), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item['category'] ?? "Aaliayah's",
                      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified, color: Colors.blue, size: 14),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['title'] ?? item['name'] ?? "Product Name",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Have a promo code? Enter here",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              foregroundColor: isDarkMode ? Colors.white : Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionHeader(String title, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Change",
            style: TextStyle(color: aaliyahPrimaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
