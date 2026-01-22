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
    final isDesktop = screenWidth > 600;
    final isDarkMode = mediaQuery.platformBrightness == Brightness.dark;
    final provider = CartProvider.of(context);

    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
        color: isDarkMode ? aaliyahSecondaryColor : aaliyahPrimaryColor,
        borderRadius: isDesktop
            ? BorderRadius.circular(15)
            : const BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: isDesktop
          ? _buildDesktopLayout(context, provider, isDarkMode)
          : _buildMobileLayout(context, provider, isDarkMode),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CartProvider provider,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
              ),
            ),
            Text(
              "Rs. ${provider.totalPrice()}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode
                ? aaliyahPrimaryColor
                : aaliyahSecondaryColor,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            "Checkout",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CartProvider provider,
    bool isDarkMode,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total: Rs. ${provider.totalPrice()}",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode
                ? aaliyahPrimaryColor
                : aaliyahSecondaryColor,
            minimumSize: const Size(200, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            "Checkout",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
            ),
          ),
        ),
      ],
    );
  }
}
