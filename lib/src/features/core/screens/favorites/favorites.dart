import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/widgets/error_info.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/product_card.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product_detail/product_detail_screen.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter/material.dart';

// This is the page to store products which has been favorited

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final finalList = provider.favorites;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    var isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          ),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "My Wishlist",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          CartAppBarAction(cartKey: cartKey),
          const SizedBox(width: 8),
        ],
      ),
      body: AddToCartAnimation(
        cartKey: cartKey,
        height: 30,
        width: 30,
        opacity: 0.85,
        dragAnimation: const DragToCartAnimationOptions(
          rotation: true,
        ),
        jumpAnimation: const JumpAnimationOptions(),
        createAddToCartAnimation: (runAddToCartAnimation) {
          this.runAddToCartAnimation = runAddToCartAnimation;
        },
        child: finalList.isEmpty
            ? _buildEmptyFavorites(context, isDesktop)
            : _buildFavoriteList(finalList, isDarkMode, provider),
      ),
    );
  }

  Widget _buildFavoriteList(List<Product> favorites, bool isDarkMode, FavoriteProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return ProductCard(
          product: product,
          isWishlist: true,
          onPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          onAddToCart: (key) {
            runAddToCartAnimation(key);
          },
        );
      },
    );
  }

  // This is to show an empty favorites page if no products are added to wishlist

  Widget _buildEmptyFavorites(BuildContext context, bool isDesktop) {
    return SafeArea(
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          padding: EdgeInsets.all(isDesktop ? 40 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isDesktop ? 300 : 250,
                height: isDesktop ? 200 : 250,
                child: Image.asset(
                  emptyFavoritesIllustration,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              ErrorInfo(
                title: "No Favorites Yet!",
                description:
                    "You haven't added any products to your favorites. Start exploring and save your favorites here!",
                btnText: "Discover Products",
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BottomNavBar(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
