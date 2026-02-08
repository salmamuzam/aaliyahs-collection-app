import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(context, 'Items'),
              TextButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  // Ensure we go to the Shop tab (index 1)
                  Provider.of<NavigationController>(context, listen: false).setIndex(1);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Items'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...cartController.cart.asMap().entries.map((entry) => _buildItemCard(context, entry.value, entry.key)),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Delivery Address'),
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
      margin: const EdgeInsets.only(bottom: 12), // Same bottom margin as item cards for consistency
      child: SizedBox(
        width: double.infinity, // Ensure it takes full width of the parent Column
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shipping To:', style: Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized.copyWith(color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text(street, style: TextStyle(color: colorScheme.onSurfaceVariant)),
              Text('$city, $postalCode', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              Text('$province, $country', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    // Handle both CartItem and ProductModel for compatibility
    final String displayName = item.displayName ?? item.name ?? '';
    final String image = item.image ?? '';
    final int quantity = item.quantity ?? 1;
    final double price = item is ProductModel 
        ? (double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0)
        : (item.price ?? 0.0);

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: ValueKey(item.id ?? index),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                cartController.removeFromCart(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$displayName removed from checkout'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.delete_sweep_rounded,
              label: 'Remove',
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SmartImage(
                  imageUrl: image,
                  width: 60,
                  height: 80, // Taller aspect ratio
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorWidget: const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     AutoSizeText(
                      displayName, 
                      style: (Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized ?? 
                             const TextStyle(fontWeight: FontWeight.bold)).copyWith(
                        color: colorScheme.onSurface, 
                        height: 1.3, 
                      ),
                      maxLines: 2,
                      minFontSize: 11,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'LKR ${price.toStringAsFixed(2)} × $quantity',
                      style: GoogleFonts.robotoMono(
                        color: colorScheme.onSurfaceVariant, 
                        fontSize: 13, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
