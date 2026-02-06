import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aaliyahs_collection_estore/widgets/smart_image.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:aaliyahs_collection_estore/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/data/models/cart_item.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';



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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
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
              backgroundColor: const Color(0xFFE57373), // Material Red 300
              foregroundColor: Colors.white,
              icon: Icons.delete_sweep_rounded, // Distinctive icon
              label: 'Delete',
              borderRadius: BorderRadius.horizontal(right: Radius.circular(TUIConstants.cardRadius)),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemImage(isDarkMode),
              const SizedBox(width: 16),
              _buildItemDetails(isDarkMode),
              _buildRemoveButton(context, isDarkMode),
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
        title: 'Removed from Cart!',
        message: '${item.displayName} has been removed from your cart.',
        contentType: ContentType.warning,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Widget _buildItemImage(bool isDarkMode) {
    return Container(
      height: 120,
      width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        child: SmartImage(
          imageUrl: item.image,
          fit: BoxFit.cover,
          errorWidget: const Icon(Icons.error_outline),
        ),
      ),
    );
  }

  Widget _buildItemDetails(bool isDarkMode) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: item.displayName,
            child: AutoSizeText(
              item.displayName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              maxLines: 2,
              minFontSize: 12,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "LKR ${(item.price * item.quantity).toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuantityControls(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQtyBtn(Icons.remove, () => provider.decrementQtn(index), isDarkMode),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "${item.quantity}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        _buildQtyBtn(Icons.add, () => provider.incrementQtn(index), isDarkMode),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // Tactile feedback
        onTap();
      },
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          border: Border.all(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context, bool isDarkMode) {
    return IconButton(
      onPressed: () => _removeThisItem(context),
      icon: Icon(
        Icons.delete_outline_rounded,
        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
        size: 22,
      ),
    );
  }
}

