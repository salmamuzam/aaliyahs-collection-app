import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';

import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/checkout_screen.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';

class CartBottomSection extends StatelessWidget {
  final CartController provider;
  final bool isInPane;

  const CartBottomSection({super.key, required this.provider, this.isInPane = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TUIConstants.horizontalPadding * 1.5,
        vertical: TUIConstants.verticalPadding * 2.5,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  provider.formattedTotalPrice,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCheckoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckoutScreen()),
          );
        },
        child: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
