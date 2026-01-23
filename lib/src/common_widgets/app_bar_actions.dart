import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/cart_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/favorites/favorites.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

class CartAppBarAction extends StatelessWidget {
  final GlobalKey<CartIconKey>? cartKey;
  final Color? color;

  const CartAppBarAction({super.key, this.cartKey, this.color});

  @override
  Widget build(BuildContext context) {
    // If cartKey is provided, it means we are using current context for animation target
    // We need to use ADD_TO_CART_ANIMATION's mechanism if strictly required, 
    // BUT the library usually just needs the KEY attached to a specific RenderBox.
    // However, AddToCartIcon is a helper from the library that handles badge + key.
    // If we want to use 'badges' package as requested for styling, we might mix them.
    // Let's use AddToCartIcon if key is present (assuming it supports custom badge)
    // OR just attach the key to a Container wrapping the Badge.

    return Consumer<CartProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            child: cartKey != null
                ? AddToCartIcon(
                    key: cartKey!,
                    icon: badges.Badge(
                      badgeContent: Text(
                        provider.cart.length.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      showBadge: provider.cart.isNotEmpty,
                      badgeAnimation: const badges.BadgeAnimation.scale(),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      ),
                    ),

                  )
                : badges.Badge(
                    badgeContent: Text(
                      provider.cart.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    showBadge: provider.cart.isNotEmpty,
                    badgeAnimation: const badges.BadgeAnimation.scale(),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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
    return Consumer<FavoriteProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
            child: badges.Badge(
              badgeContent: Text(
                provider.favorites.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              showBadge: provider.favorites.isNotEmpty,
              badgeAnimation: const badges.BadgeAnimation.scale(),
              child: Icon(
                Icons.favorite_border,
                color: color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }
}
