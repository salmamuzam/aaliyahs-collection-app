import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/controllers/connectivity_controller.dart';
import 'package:quickalert/quickalert.dart';

import 'package:aaliyahs_collection_estore/screens/shop/cart/cart_screen.dart';
import 'package:aaliyahs_collection_estore/screens/shop/favorites/favorites_screen.dart';
import 'package:aaliyahs_collection_estore/screens/shop/home/home_screen.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/screens/profile/profile_screen.dart';

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
      Provider.of<UserController>(context, listen: false).fetchUserProfile();
      Provider.of<ProductController>(context, listen: false).fetchHomeData(); 
      
      // Listen to connectivity changes
      _setupConnectivityListener();
    });
  }

  void _setupConnectivityListener() {
    final connectivity = Provider.of<ConnectivityController>(context, listen: false);
    bool lastStatus = connectivity.isConnected;

    connectivity.addListener(() {
      if (lastStatus != connectivity.isConnected) {
        lastStatus = connectivity.isConnected;
        _showConnectivityAlert(connectivity.isConnected);
      }
    });
  }

  void _showConnectivityAlert(bool isOnline) async {
    final productProvider = Provider.of<ProductController>(context, listen: false);
    
    if (!isOnline) {
      // 1. Show OFFLINE ERROR
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "OFFLINE",
        text: "Connection lost. Switch to offline mode?",
        confirmBtnText: "Yes, Load Local",
        confirmBtnColor: aaliyahPrimaryColor,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          // 2. Show LOADING for Local Data
          QuickAlert.show(
            context: context,
            type: QuickAlertType.loading,
            title: "Loading Local...",
            text: "Setting up your offline collection.",
          );
          
          await productProvider.fetchHomeData();
          
          if (mounted) Navigator.pop(context); // Close loading
        },
      );
    } else {
      // 1. Show LOADING for Online Data
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: "SYNCING...",
        text: "Internet restored. Updating live products!",
      );

      await productProvider.fetchHomeData();

      if (mounted) {
        Navigator.pop(context); // Close loading
        
        // 2. Show SUCCESS
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "BACK ONLINE",
          text: "Everything is up to date!",
          confirmBtnColor: Colors.green,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductScreen(),
    const FavoriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
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
                  ? const Color(0xFF4CDABD).withValues(alpha: 0.24) // Light Teal (M3 Dark Spec)
                  : const Color(0xFF006A60).withValues(alpha: 0.12), // Dark Teal (M3 Light Spec)
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(
                    color: isDarkMode ? const Color(0xFF4CDABD) : const Color(0xFF001E2E), // On-Indicator Color
                    size: 24.sp,
                  );
                }
                return IconThemeData(
                  color: isDarkMode ? const Color(0xFFC3C7C7) : const Color(0xFF3F484A), // Inactive Color
                  size: 22.sp);
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
              destinations: [
                NavigationDestination(
                  icon: Consumer<NotificationController>(
                    builder: (context, provider, _) => Badge(
                      isLabelVisible: _currentIndex != 0 && provider.unreadCount > 0,
                      child: const Icon(Icons.home_outlined),
                    ),
                  ),
                  selectedIcon: const Icon(Icons.home),
                  label: "Home",
                  tooltip: "Home", // Accessory for large text scaling
                ),
                const NavigationDestination(
                  icon: Icon(Icons.store_outlined),
                  selectedIcon: Icon(Icons.store),
                  label: "Shop",
                  tooltip: "Shop",
                ),
                NavigationDestination(
                  icon: Consumer<FavoriteController>(
                    builder: (context, provider, _) => Badge(
                      isLabelVisible: _currentIndex != 2 && provider.favorites.isNotEmpty,
                      label: Text(provider.favorites.length > 99 ? "99+" : provider.favorites.length.toString()),
                      child: const Icon(Icons.favorite_outline_outlined),
                    ),
                  ),
                  selectedIcon: const Icon(Icons.favorite),
                  label: "Wishlist",
                  tooltip: "Wishlist",
                ),
                NavigationDestination(
                  icon: Consumer<CartController>(
                    builder: (context, provider, _) => Badge(
                      isLabelVisible: _currentIndex != 3 && provider.cart.isNotEmpty,
                      label: Text(provider.cart.length > 99 ? "99+" : provider.cart.length.toString()),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                  ),
                  selectedIcon: const Icon(Icons.shopping_cart),
                  label: "Cart",
                  tooltip: "Cart",
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_2_outlined),
                  selectedIcon: Icon(Icons.person),
                  label: "Profile",
                  tooltip: "Profile",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
