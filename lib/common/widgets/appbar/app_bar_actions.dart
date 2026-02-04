import 'package:aaliyahs_collection_estore/screens/shop/favorites/favorites_screen.dart';
import 'package:aaliyahs_collection_estore/screens/shop/cart/cart_screen.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/favorite_controller.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

// ============================================================================
// CART APP BAR ACTION - Shopping Cart Icon with Badge
// ============================================================================
// This widget shows the shopping cart icon in the AppBar
// It displays a red badge with the number of items in the cart
// When tapped, it opens the cart screen
// ============================================================================

class CartAppBarAction extends StatelessWidget {
  final GlobalKey<CartIconKey>? cartKey;  // Key for add-to-cart animation (where items fly to)
  final Color? color;                      // Optional custom color for the icon

  const CartAppBarAction({super.key, this.cartKey, this.color});

  @override
  Widget build(BuildContext context) {
    // Use Selector instead of Consumer for better performance
    // Selector only rebuilds when cart.length changes, not when other cart data changes
    // This is more efficient than Consumer which rebuilds on any cart change
    return Selector<CartController, int>(
      selector: (_, provider) => provider.cart.length,  // Only watch the cart count
      builder: (context, count, child) {
        // Check if app is in dark mode to adjust icon color
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final iconColor = color ?? (isDarkMode ? aaliyahLightColor : aaliyahDarkColor);
        
        return Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
          
          // GestureDetector makes the icon tappable
          child: GestureDetector(
            onTap: () {
              // Navigate to cart screen when tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            
            // AddToCartIcon is required by the add_to_cart_animation package
            // It provides the target location for the flying animation
            child: AddToCartIcon(
              key: cartKey ?? GlobalKey<CartIconKey>(),
              // Badge widget shows the count on top of the icon
              icon: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -8, end: -3),  // Position badge at top-right
                showBadge: count > 0,  // Only show badge if there are items in cart
                ignorePointer: false,
                
                // The number displayed in the badge
                badgeContent: Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                
                // Badge styling
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.red,  // Red color for notification (standard UI pattern)
                  padding: EdgeInsets.all(4),
                  elevation: 0,
                ),
                
                // Animation when badge appears/updates
                badgeAnimation: const badges.BadgeAnimation.scale(),
                
                // The cart icon itself
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: iconColor,
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// FAVORITE APP BAR ACTION - Wishlist/Favorites Icon with Badge
// ============================================================================
// This widget shows the favorites/wishlist icon in the AppBar
// It displays a badge with the number of favorited items
// When tapped, it opens the favorites screen
// ============================================================================

class FavoriteAppBarAction extends StatelessWidget {
  final Color? color;  // Optional custom color for the icon
  
  const FavoriteAppBarAction({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    // Use Selector for performance optimization
    // Only rebuilds when favorites count changes, not when other favorite data changes
    return Selector<FavoriteController, int>(
      selector: (_, provider) => provider.favorites.length,  // Only watch the favorites count
      builder: (context, count, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
          
          // GestureDetector makes the icon tappable
          child: GestureDetector(
            onTap: () {
              // Navigate to favorites screen when tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
            
            // Badge widget shows the count on top of the icon
            child: badges.Badge(
              badgeContent: Text(
                count.toString(),
                style: const TextStyle(color: aaliyahLightColor, fontSize: 10),
              ),
              showBadge: count > 0,  // Only show badge if there are favorited items
              badgeAnimation: const badges.BadgeAnimation.scale(),
              
              // The heart icon itself
              child: Icon(
                Icons.favorite_outline_outlined,
                color: color ?? (Theme.of(context).brightness == Brightness.dark ? aaliyahLightColor : aaliyahDarkColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
