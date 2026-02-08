import 'package:aaliyahs_collection_estore/features/shop/screens/favorites/favorites_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/favorite_controller.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

// ============================================================================
// CART APP BAR ACTION - Shopping Cart Icon with Badge
// ============================================================================
// This widget shows the shopping cart icon in the AppBar
// It displays a red badge with the number of items in the cart
// When tapped, it opens the cart screen
// ============================================================================

class CartAppBarAction extends StatelessWidget {
  final GlobalKey<CartIconKey>? cartKey;
  final Color? color;

  const CartAppBarAction({super.key, this.cartKey, this.color});

  @override
  Widget build(BuildContext context) {
    return Selector<CartController, int>(
      selector: (_, provider) => provider.cart.length,
      builder: (context, count, child) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: AddToCartIcon(
            key: cartKey ?? GlobalKey<CartIconKey>(),
            badgeOptions: const BadgeOptions(active: false),
            icon: Semantics(
              label: count > 0 ? 'Shopping cart, ${count > 999 ? "999+" : count}' : 'Shopping cart, empty',
              button: true,
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ),
                tooltip: 'View cart',
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text(count > 999 ? '999+' : count.toString()),
                  alignment: AlignmentDirectional.topEnd,
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: color ?? colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FavoriteAppBarAction extends StatelessWidget {
  final Color? color;
  
  const FavoriteAppBarAction({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Selector<FavoriteController, int>(
      selector: (_, provider) => provider.favorites.length,
      builder: (context, count, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Semantics(
            label: count > 0 ? 'Wishlist, ${count > 999 ? "999+" : count}' : 'Wishlist, empty',
            button: true,
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              ),
              tooltip: 'View wishlist',
              icon: Badge(
                isLabelVisible: count > 0,
                // M3 Badge: Limit to 4 characters including "+"
                label: Text(count > 999 ? '999+' : count.toString()),
                // M3 Badge: Anchor at upper trailing edge of icon
                alignment: AlignmentDirectional.topEnd,
                child: Icon(
                  Icons.favorite_border_rounded,
                  color: color ?? colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
