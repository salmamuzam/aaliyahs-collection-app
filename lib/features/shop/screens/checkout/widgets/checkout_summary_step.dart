import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';

class CheckoutSummaryStep extends StatelessWidget {
  final CartController cartController;
  final String street;
  final String city;
  final String postalCode;
  final String province;
  final String country;
  final bool isInPane;

  const CheckoutSummaryStep({
    super.key,
    required this.cartController,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.province,
    required this.country,
    this.isInPane = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Items'),
          const SizedBox(height: 16),
          ...cartController.cart.map((item) => _buildItemCard(context, item)),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Delivery address'),
          const SizedBox(height: 12),
          _buildAddressCard(context),
          const SizedBox(height: 24),
          _buildPriceRow(context, 'Total', cartController.formattedTotalPrice, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: (Theme.of(context).extension<AaliyahTypography>()?.titleMediumEmphasized ?? 
              Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping to:', style: Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text(street, style: TextStyle(color: colorScheme.onSurfaceVariant)),
            Text('$city, $postalCode', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            Text('$province, $country', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    final colorScheme = Theme.of(context).colorScheme;
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SmartImage(
                imageUrl: image,
                width: 60,
                height: 60,
                errorWidget: const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName, 
                    style: Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized.copyWith(color: colorScheme.onSurface, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LKR ${price.toStringAsFixed(2)} × $quantity',
                    style: GoogleFonts.robotoMono(
                      color: colorScheme.onSurfaceVariant, 
                      fontSize: 12, 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'LKR ${totalItemPrice.toStringAsFixed(0)}',
              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
