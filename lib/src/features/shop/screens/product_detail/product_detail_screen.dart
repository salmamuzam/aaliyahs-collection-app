import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/src/utils/device/device_utility.dart';

// Product Detail Feature Widgets
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product_detail/widgets/product_image_carousel.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product_detail/widgets/product_info_section.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product_detail/widgets/product_detail_bottom_action.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GlobalKey<CartIconKey> _cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) _runAddToCartAnimation;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.product.images.isEmpty) {
      return const Scaffold(body: Center(child: Text("No product details available")));
    }

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      body: AddToCartAnimation(
        cartKey: _cartKey,
        height: TUIConstants.cartAnimHeight,
        width: TUIConstants.cartAnimWidth,
        opacity: TUIConstants.cartAnimOpacity,
        dragAnimation: const DragToCartAnimationOptions(rotation: true),
        jumpAnimation: const JumpAnimationOptions(),
        createAddToCartAnimation: (runAnimation) => _runAddToCartAnimation = runAnimation,
        child: Stack(
          children: [
            _buildImageBackground(context),
            _buildCustomAppBar(context, isDarkMode),
            _buildContentCard(context, isDarkMode),
            _buildFavoriteButton(context),
            _buildBottomActionBar(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBackground(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: DeviceUtils.height * 0.45,
      child: ProductImageCarousel(
        product: widget.product,
        selectedIndex: _selectedImageIndex,
        onPageChanged: (index) => setState(() => _selectedImageIndex = index),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode) {
    // Best Practice: Platform-specific implementation for a native feel
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final IconData backIcon = isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back;

    return Positioned(
      top: DeviceUtils.getVerticalSize(40),
      left: DeviceUtils.getHorizontalSize(20),
      right: DeviceUtils.getHorizontalSize(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFloatingBtn(
            icon: backIcon,
            onTap: () => Navigator.pop(context),
            isDarkMode: isDarkMode,
          ),
          CartAppBarAction(cartKey: _cartKey, color: isDarkMode ? Colors.white : Colors.black),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, bool isDarkMode) {
    return Positioned.fill(
      top: DeviceUtils.height * 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ProductInfoSection(product: widget.product),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Positioned(
      top: DeviceUtils.height * 0.4 - DeviceUtils.getSize(25),
      right: 25,
      child: Consumer<FavoriteProvider>(
        builder: (context, favProvider, _) {
          final bool isFav = favProvider.isExists(widget.product);
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: aaliyahPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: aaliyahPrimaryColor,
              radius: 25,
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_outline_outlined,
                  color: Colors.white,
                ),
                onPressed: () => favProvider.toggleFavorite(widget.product),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, bool isDarkMode) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ProductDetailBottomAction(
        product: widget.product,
        onAddToCart: () => _runAddToCartAnimation(_cartKey),
      ),
    );
  }

  Widget _buildFloatingBtn({required IconData icon, required VoidCallback onTap, required bool isDarkMode}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black26 : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: isDarkMode ? Colors.white : Colors.black87),
      ),
    );
  }
}
