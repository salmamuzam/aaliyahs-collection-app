import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/cart_screen.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/favorites/favorites.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/home_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:aaliyahs_collection_estore/provider/product_provider.dart';

// This is my fixed bottom navigation bar

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserProfile();
      Provider.of<ProductProvider>(context, listen: false).fetchBestSellingProducts();
    });
  }
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
    body: IndexedStack(
      index: index,
      children: screens,
    ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withValues(alpha: 0.2) 
              : aaliyahPrimaryColor.withValues(alpha: 0.2),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
               return IconThemeData(
                 color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
               );
            }
            return null; // Defer to default
          }),
          labelTextStyle: const WidgetStatePropertyAll(
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
