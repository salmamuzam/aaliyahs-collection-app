import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/providers/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/screens/cart/cart_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/favorites/favorites.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/home/home_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/screens/profile/profile_screen.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserProfile();
      Provider.of<ProductProvider>(context, listen: false).fetchHomeData(); 
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductScreen(),
    FavoriteScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          // Dynamic height and label behavior based on device type
          final double navHeight = sizingInformation.isMobile ? 60.h : 80.h;
          final labelBehavior = sizingInformation.isMobile 
              ? NavigationDestinationLabelBehavior.onlyShowSelected 
              : NavigationDestinationLabelBehavior.alwaysShow;

          return NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: isDarkMode
                  ? Colors.white.withValues(alpha: 0.2)
                  : aaliyahPrimaryColor.withValues(alpha: 0.2),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 24.sp,
                  );
                }
                return IconThemeData(size: 22.sp);
              }),
              labelTextStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontSize: 12.sp, // Responsive font size
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: NavigationBar(
              height: navHeight,
              selectedIndex: _currentIndex,
              labelBehavior: labelBehavior,
              animationDuration: const Duration(milliseconds: 300),
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: "Home",
                ),
                NavigationDestination(
                  icon: Icon(Icons.store_outlined),
                  selectedIcon: Icon(Icons.store),
                  label: "Shop",
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_outline_outlined),
                  selectedIcon: Icon(Icons.favorite),
                  label: "Wishlist",
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: "Cart",
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_2_outlined),
                  selectedIcon: Icon(Icons.person_2),
                  label: "Profile",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
