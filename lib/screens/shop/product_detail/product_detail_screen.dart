import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/product_detail_controller.dart';
import 'package:aaliyahs_collection_estore/util/device/device_utility.dart';

// Product Detail Feature Widgets
import 'package:aaliyahs_collection_estore/screens/shop/product_detail/widgets/product_image_carousel.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product_detail/widgets/product_info_section.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product_detail/widgets/product_detail_bottom_action.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GlobalKey<CartIconKey> _cartKey = GlobalKey<CartIconKey>();
  Function(GlobalKey)? _runAddToCartAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailController>().initialize(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: aaliyahPrimaryColor),
            ),
          );
        }

        final productToDisplay = controller.product ?? widget.product;

        if (productToDisplay.images.isEmpty) {
          return const Scaffold(body: Center(child: Text("No product details available")));
        }

        // No changes needed based on current view, moving to child widgets.
        WidgetsBinding.instance.addPostFrameCallback((_) {
           context.read<ProductController>().addToRecentlyViewed(productToDisplay);
        });

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
                _buildImageBackground(context, controller, productToDisplay),
                _buildCustomAppBar(context, isDarkMode),
                _buildContentCard(context, isDarkMode, productToDisplay),
                _buildFavoriteButton(context, productToDisplay),
                _buildBottomActionBar(context, isDarkMode, productToDisplay),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageBackground(BuildContext context, ProductDetailController controller, ProductModel product) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: DeviceUtils.height * 0.45,
      child: ProductImageCarousel(
        product: product,
        selectedIndex: controller.selectedImageIndex,
        onPageChanged: (index) => controller.setSelectedImageIndex(index),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode) {
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

  Widget _buildContentCard(BuildContext context, bool isDarkMode, ProductModel product) {
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
        child: ProductInfoSection(product: product),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildFavoriteButton(BuildContext context, ProductModel product) {
    return Positioned(
      top: DeviceUtils.height * 0.4 - DeviceUtils.getSize(25),
      right: 25,
      child: Consumer<FavoriteController>(
        builder: (context, favProvider, _) {
          final bool isFav = favProvider.isExists(product);
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
                onPressed: () {
                   final isAlreadyLoved = favProvider.isExists(product);
                   favProvider.toggleFavorite(product);
                   
                   final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      duration: const Duration(seconds: 2),
                      content: AwesomeSnackbarContent(
                        title: isAlreadyLoved ? 'Removed from Wishlist!' : 'Added to Wishlist!',
                        message: isAlreadyLoved 
                           ? '${product.displayName} has been removed from your wishlist.' 
                           : '${product.displayName} has been added to your wishlist.',
                        contentType: isAlreadyLoved ? ContentType.warning : ContentType.success,
                      ),
                   );
                   ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
                },
              ),
            ),
          );
        },
      ),
    ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildBottomActionBar(BuildContext context, bool isDarkMode, ProductModel product) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ProductDetailBottomAction(
        product: product,
        onAddToCart: () {
          if (_runAddToCartAnimation != null) {
            _runAddToCartAnimation!(_cartKey);
          }
        },
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
