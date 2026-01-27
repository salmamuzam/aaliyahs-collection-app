import 'package:flutter/material.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/cart/widgets/error_info.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/src/utils/helpers/responsive_helper.dart';

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
    final FavoriteProvider provider = FavoriteProvider.of(context);
    final List<Product> favList = provider.favorites;
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
      leading: IconButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        ),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        "My Wishlist",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      actions: [
        const FavoriteAppBarAction(),
        CartAppBarAction(cartKey: _cartKey),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFavoriteGrid(List<Product> favorites, bool isDarkMode) {
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
              description: "You haven't added any products to your favorites. Start exploring and save your favorites here!",
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
