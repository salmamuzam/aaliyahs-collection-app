import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/checkout_screen.dart';

import 'package:flutter/material.dart';

// Bottom Checkout Section in Cart Screen

class CheckOutBox extends StatelessWidget {
  const CheckOutBox({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    // final isDesktop = screenWidth > 600; // unused
    final isDarkMode = mediaQuery.platformBrightness == Brightness.dark;
    final provider = CartProvider.of(context);

    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
        color: isDarkMode ? aaliyahSecondaryColor : Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(context, "Total", provider.formattedTotalPrice, isBold: true),
          const SizedBox(height: 12),
          // Assuming fixed delivery for now or calculated elsewhere, showing static based on image
          _buildSummaryRow(context, "Delivery charge", "Rs. 250.00", isBold: false), 
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
           _buildSummaryRow(context, "Sub Total", "Rs. ${(provider.totalPrice() + 250).toStringAsFixed(2)}", isBold: true),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ACC1), // Cyan/Teal color from reference
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "PROCEED TO CHECKOUT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isBold ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : Colors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : Colors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
             fontSize: 15,
          ),
        ),
      ],
    );
  }
}
