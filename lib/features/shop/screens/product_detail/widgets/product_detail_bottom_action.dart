import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ProductDetailBottomAction extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const ProductDetailBottomAction({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailBottomAction> createState() => _ProductDetailBottomActionState();
}

class _ProductDetailBottomActionState extends State<ProductDetailBottomAction> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        DeviceUtils.m3Margin, 
        10, 
        DeviceUtils.m3Margin, 
        10 + MediaQuery.of(context).padding.bottom
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Added to prevent expansion issues
          children: [
            _buildQuantitySelector(context),
            const SizedBox(width: 12), // Reduced from 20
            _buildAddToCartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(TUIConstants.buttonRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Decrease quantity',
            button: true,
            child: Tooltip(
              message: 'Decrease quantity',
              child: _buildQtyBtn(context, Icons.remove, () {
                if (_quantity > 1) {
                  HapticFeedback.lightImpact();
                  setState(() => _quantity--);
                }
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced from 16
            child: Semantics(
              label: 'Quantity $_quantity',
              liveRegion: true,
              child: Text(
                '$_quantity',
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: 16, // Reduced from 18
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Semantics(
            label: 'Increase quantity',
            button: true,
            child: Tooltip(
              message: 'Increase quantity',
              child: _buildQtyBtn(context, Icons.add, () {
                HapticFeedback.lightImpact();
                setState(() => _quantity++);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          final CartController provider = Provider.of<CartController>(context, listen: false);
          for (int i = 0; i < _quantity; i++) {
            provider.addToCart(widget.product);
          }
          widget.onAddToCart();
          _showSnackBar(context);
        },
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Add to Cart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Added to cart',
          message: '${widget.product.displayName} added to cart',
          contentType: ContentType.success,
        ),
      ),
    );
  }
}
