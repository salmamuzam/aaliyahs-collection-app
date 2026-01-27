import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ProductDetailBottomAction extends StatefulWidget {
  final Product product;
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
          _buildQtyBtn(Icons.remove, () {
            if (_quantity > 1) setState(() => _quantity--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "$_quantity",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          _buildQtyBtn(Icons.add, () {
            setState(() => _quantity++);
          }),
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
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          final CartProvider provider = Provider.of<CartProvider>(context, listen: false);
          for (int i = 0; i < _quantity; i++) {
            provider.addToCart(widget.product);
          }
          widget.onAddToCart();
          _showSnackBar(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: aaliyahPrimaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TUIConstants.buttonRadius),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Add to cart",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
          title: 'Added to Cart!',
          message: '${widget.product.displayName} has been added to your cart.',
          contentType: ContentType.success,
        ),
      ),
    );
  }
}
