import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/cart_item.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';



class CartItemCard extends StatelessWidget {
  final CartItem item;
  final int index;
  final CartController provider;

  const CartItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.provider,
  });


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      margin: EdgeInsets.zero, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUIConstants.cardRadius)),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                _removeThisItem(context);
              },
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.delete_sweep_rounded, 
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(TUIConstants.cardRadius)),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Select ${item.displayName}',
                child: Checkbox(
                  value: provider.selectedItemIds.contains(item.id),
                  onChanged: (_) => provider.toggleItemSelection(item.id),
                ),
              ),
              const SizedBox(width: 4),
              _buildItemImage(context),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  label: 'Item: ${item.displayName}, Price: LKR ${(item.price * item.quantity).toStringAsFixed(2)}, Quantity: ${item.quantity}.',
                  container: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildItemDetails(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeThisItem(BuildContext context) {
    provider.removeFromCart(index);
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Removed from Cart',
        message: '${item.displayName} removed from cart',
        contentType: ContentType.warning,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Widget _buildItemImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 100,
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusSmall),
        color: colorScheme.surfaceContainer,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusSmall),
        child: SmartImage(
          imageUrl: item.image,
          alignment: Alignment.topCenter,
          errorWidget: const Icon(Icons.error_outline_rounded),
        ),
      ),
    );
  }

  Widget _buildItemDetails(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Tooltip(
            message: item.displayName,
            child: AutoSizeText(
              item.displayName,
              style: (Theme.of(context).extension<AaliyahTypography>()?.titleMediumEmphasized ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'LKR ${(item.price * item.quantity).toStringAsFixed(2)}',
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuantityControls(context),
        ],
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQtyBtn(context, Icons.remove_rounded, () => provider.decrementQtn(index), 'Decrease quantity'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8), 
          child: Text(
            '${item.quantity}',
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        _buildQtyBtn(context, Icons.add_rounded, () => provider.incrementQtn(index), 'Increase quantity'),
      ],
    );
  }

  Widget _buildQtyBtn(BuildContext context, IconData icon, VoidCallback onTap, String label) {
    return IconButton.filledTonal(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      icon: Icon(icon, size: 14),
      constraints: const BoxConstraints(
        minWidth: 28, 
        minHeight: 28,
      ),
      padding: EdgeInsets.zero,
      tooltip: label,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }


}

