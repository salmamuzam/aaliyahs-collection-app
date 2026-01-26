import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/checkout_screen.dart';

import 'package:flutter/material.dart';

// Bottom Checkout Section in Cart Screen

class CheckOutBox extends StatelessWidget {
  final bool isDarkMode;
  const CheckOutBox({super.key, required this.isDarkMode});

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
        color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
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
          const SizedBox(height: 24),
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
                backgroundColor: aaliyahPrimaryColor, 
                foregroundColor: aaliyahLightColor,
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
            color: isBold ? (isDarkMode ? aaliyahLightColor : aaliyahDarkColor) : Colors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? (isDarkMode ? aaliyahLightColor : aaliyahDarkColor) : Colors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
             fontSize: 15,
          ),
        ),
      ],
    );
  }
}
