import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          _buildQuantitySelector(isDarkMode),
          const SizedBox(width: 20),
          _buildAddToCartButton(context),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(TUIConstants.buttonRadius),
      ),
      child: Row(
        children: [
          Tooltip(
            message: "Decrease Quantity",
            child: _buildQtyBtn(Icons.remove, () {
              if (_quantity > 1) setState(() => _quantity--);
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "$_quantity",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          Tooltip(
            message: "Increase Quantity",
            child: _buildQtyBtn(Icons.add, () {
              setState(() => _quantity++);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: Colors.grey.shade600),
      ),
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
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: const Text(
          "Add to cart",
          style: TextStyle(fontSize: 18),
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
          title: 'Added to Cart!',
          message: '${widget.product.displayName} has been added to your cart.',
          contentType: ContentType.success,
        ),
      ),
    );
  }
}
