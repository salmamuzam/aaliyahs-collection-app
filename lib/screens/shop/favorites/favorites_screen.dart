import 'package:flutter/material.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import 'package:aaliyahs_collection_estore/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/util/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/screens/shop/cart/widgets/error_info.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/util/helpers/responsive_helper.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final GlobalKey<CartIconKey> _cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) _runAddToCartAnimation;

  @override
  Widget build(BuildContext context) {
    final FavoriteController provider = FavoriteController.of(context);
    final List<ProductModel> favList = provider.favorites;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: AddToCartAnimation(
        cartKey: _cartKey,
        height: TUIConstants.cartAnimHeight,
        width: TUIConstants.cartAnimWidth,
        opacity: TUIConstants.cartAnimOpacity,
        dragAnimation: const DragToCartAnimationOptions(rotation: true),
        jumpAnimation: const JumpAnimationOptions(),
        createAddToCartAnimation: (runAnimation) => _runAddToCartAnimation = runAnimation,
        child: favList.isEmpty
            ? _buildEmptyFavorites(context)
            : _buildFavoriteGrid(favList, isDarkMode),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Prevents back arrow on bottom nav screens
      title: const Text("My Wishlist"),
      actions: [
        const FavoriteAppBarAction(), // Consider removing if redundant on Favorites screen
        CartAppBarAction(cartKey: _cartKey),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFavoriteGrid(List<ProductModel> favorites, bool isDarkMode) {
    return GridView.builder(
      cacheExtent: 1000.0,
      padding: const EdgeInsets.all(TUIConstants.horizontalPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.getGridColumnCount(context),
        childAspectRatio: 0.65,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return ProductCardVertical(
          product: product,
          isWishlist: true,
          heroPrefix: 'fav_',
          onPress: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
          ),
          onAddToCart: (key) => _runAddToCartAnimation(key),
        );
      },
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
        padding: EdgeInsets.all(isDesktop ? 40 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isDesktop ? 300 : 250,
              height: isDesktop ? 200 : 250,
              child: Image.asset(emptyFavoritesIllustration, fit: BoxFit.contain),
            ),
            const SizedBox(height: 40),
            ErrorInfo(
              title: "No Favorites Yet!",
              description: "You haven't added any ProductModels to your favorites. Start exploring and save your favorites here!",
              btnText: "Discover Products",
              press: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
