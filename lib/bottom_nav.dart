import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/cart_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/favorites/favorites.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/home_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

// This is my fixed bottom navigation bar

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 0;
  final screens = [
    // The screens
    HomeScreen(),
    ProductScreen(),
    FavoriteScreen(),
    CartScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: screens[index],
    bottomNavigationBar: NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      child: NavigationBar(
        height: 60,
        selectedIndex: index,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: Duration(seconds: 3),
        onDestinationSelected: (index) => setState(() => this.index = index),
        destinations: [
          // Home Page
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          // Product Page
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: "Shop",
          ),
          // Wishlist Page
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_outlined),
            selectedIcon: Icon(Icons.favorite),
            label: "Wishlist",
          ),
          // Cart Page
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          // Profile Page
          NavigationDestination(
            icon: Icon(Icons.person_2_outlined),
            selectedIcon: Icon(Icons.person_2),
            label: "Profile",
          ),
        ],
      ),
    ),
  );
}
